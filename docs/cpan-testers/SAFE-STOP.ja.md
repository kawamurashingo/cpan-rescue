# CPAN Smoker の停止処理を安全にする

[English](SAFE-STOP.md) · [既存 VM の自動化](ACTIVATE-EXISTING.ja.md)

**現状：参考実装。シェル構文を確認済みですが、VM 152 への適用・実動作はまだ未検証です。** 現在正常稼働している rc.d を無断で置き換えず、検証してから導入します。

問題の原因は FreeBSD の標準 `rc.subr` が SIGTERM 後に対象 PID の終了を待つことです。CPAN の依存モジュールが多数動いていると、停止が長引きます。さらに標準の restart 処理は stop の結果に関係なく start まで進むので、安全策が必要です。

追加した [停止保護付き rc.d 候補](scripts/cpansmoker-guarded) は、次の方針です。

1. `daemon -P` による監視 PID にだけ SIGTERM を送る。
2. 最大 **90秒** 待って終了できなければエラーを返す。**SIGKILL は自動送信しない。**
3. 監視 PID が消えても、専用 `cpansmoke` ユーザーのプロセスが残っていたら失敗扱い。
4. 残存プロセスがある間は start を拒否。restart も stop が失敗したら中止。
5. File transport、既存の .rpt、ログローテーション、`daemon -H -R 60` はそのまま使う。

この方式は「90秒でテストを強制終了する」という意味ではありません。**停止を待つ操作が無期限にならない仕組み**です。失敗時には原因調査が必要です。専用アカウントに他の用途のプロセスがある場合は、保守的に起動を拒否します。

## 実機への適用順序

まず Proxmox で現状を確認：

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /bin/sh -c 'grep -E "^(command_args|pidfile|procname)=" /usr/local/etc/rc.d/cpansmoker; /usr/sbin/sysrc cpansmoker_enable'
~~~

現行 rc.d をバックアップし、レビュー済みの候補を FreeBSD VM にコピーして、シェル構文を検証してから置き換えます。**メンテナンス時間帯にのみ**停止を試します。

~~~sh
# 以下は FreeBSD VM の root で実行。/tmp/cpansmoker-guarded は
# 事前に検証済みのファイルを置いた場所を表します。
rc=/usr/local/etc/rc.d/cpansmoker
cp -p "$rc" "$rc.before-guarded-stop"
sh -n /tmp/cpansmoker-guarded
install -o root -g wheel -m 0555 /tmp/cpansmoker-guarded "$rc"
service cpansmoker onestatus
service cpansmoker onestop
~~~

`onestop` がエラーなら **onestart / onerestart / VM 再起動をしません**。残存プロセスと監視 PID を調査してください。成功した場合に限って `onestart` を実行して、複数 Smoker が起動していないことを確認します。

問題時は `/usr/local/etc/rc.d/cpansmoker.before-guarded-stop` から復元できますが、元のスクリプトは停止待ちが長引く可能性があることに注意してください。

その後、別のメンテナンス時間に VM の再起動と自動復帰を試します。**VM 151 へのレポート投稿自動化は別工程**です。
