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

## 実機検証：90秒タイムアウト（2026-11-22）

VM 152 に候補 rc.d を適用して `service cpansmoker onestop` を試した。事前の supervisor は PID **23755**。コマンドは **90秒で停止待ちを打ち切り、終了コード1** を返し、`No SIGKILL sent.` を明示した。停止後も supervisor **23755** が稼働し、Attean の CPAN テスト PID **23806** と子 PID **40338** が残っていた。

**検証済み：停止待ちの時間上限と失敗時の非強制終了。未検証：正常停止・停止後の単一起動・VM 再起動。** 原因確認前に `onestart`、`restart`、再起動、追加のシグナルを送らない。監視 PID、Smoker 本体 PID、テスト PID のプロセス状態・親子関係・wait channel を読み取り専用で診断する。

## 実機検証：孤立した CPAN プロセスの調査と Smoker 復旧（2026-11-22）

90秒タイムアウト後、`ps` で supervisor **23755** が `piperd`（パイプ読み込み待ち）になっており、Smoker 本体 **23756** は終了、Attean の CPAN 処理 **23806** は孤立して PPID=1 となっていることを確認。

`fstat` により、supervisor **23755** の FD 7（pipe `ffffffe00511ed5c0` ↔ `ffffffe00511ed718`）と Attean **23806** の FD 1/2/4 が、**同じパイプの両端を保持している**ことを確認した。このため、子孫テストがログ用パイプを保持し続け、supervisor の終了を妨げていたと説明できる。

孤立した Attean PID **23806** に対し、PPID・実行ユーザー・コマンドを照合した後に **SIGTERM のみ**送った。続く確認では supervisor PID **23755**、Smoker PID **23756**、Attean PID **23806** がすべて消え、`ps -U cpansmoke` も空、`service cpansmoker onestatus` は `not running` を返した。

その後 `service cpansmoker onestart` に成功。新しい supervisor **43462**、Smoker 本体 **43463** が稼働し、CPAN インデックスの取得と走査を再開した。これは **孤立プロセスの手動解消後の単一起動**が成功した実績であり、自動的な正常停止・再起動を証明するものではない。

**今後の課題：** 子孫がログパイプを継承したまま孤立しても安全に終了できる停止方法、VM 再起動後の自動起動、および VM 151 でのレポート投稿の検証。稼働中の Smoker に対する追加の停止実験を、無計画に繰り返さない。
