# 既存の FreeBSD VM 152 で自動スモークテストを有効化する

[テスター構築ガイド](README.ja.md) | [English](ACTIVATE-EXISTING.md)

**前提**：VM 152 では cpansmoke ユーザー、CPAN::Reporter::Smoker、File transport、rc.d サービス、daemon による監視がすでに導入済み。rc.d の onestart/onestop/onestatus/onerestart は既存環境で成功しています。

**変更するのは、runner の「固定 list の解除」と OS 起動時の有効化のみ。** VM 151 の送信環境、レポート履歴、Metabase 設定、Perl のパッケージを変更しません。

この手順は **Proxmox ホスト（root@pve）上**で実行します。QEMU Guest Agent が VM 152 で使用できることが前提です。

## 1. Runner を安全に更新し、手動起動で確認

この更新コマンドは、既存 runner を **.preauto** として初回だけバックアップし、公開済みの**固定コミット**から runner だけを取得します。rc.d スクリプトは書き換えません。サービスが動作中なら先に停止します。URL は常に固定コミットを指し、後日更新される main とは独立です。

~~~sh
qm guest exec 152 -- /bin/sh -c '
  set -eu
  runner=/usr/local/libexec/cpansmoker-run
  tmp=$(/usr/bin/mktemp /tmp/cpansmoker-run.XXXXXX)

  /usr/bin/fetch -q -o "$tmp" \
    https://raw.githubusercontent.com/kawamurashingo/cpan-rescue/a1d9d6386085349601c9b7f11afc18d8f37b94b9/docs/cpan-testers/scripts/cpansmoker-run

  /bin/sh -n "$tmp"
  /usr/bin/grep -Fq "unset PERL_CR_SMOKER_SHORTCUT" "$tmp"
  /usr/bin/grep -Fq "unset PERL_CR_SMOKER_RUNONCE" "$tmp"
  /usr/bin/grep -Fq "start(install => 0, set_term_title => 0)" "$tmp"

  test -f "$runner"
  test -f /usr/local/etc/rc.d/cpansmoker

  if /usr/sbin/service cpansmoker onestatus >/dev/null 2>&1; then
    /usr/sbin/service cpansmoker onestop
  fi
  if /usr/sbin/service cpansmoker onestatus >/dev/null 2>&1; then
    echo "ERROR: service still running; not replacing runner"
    exit 1
  fi

  if [ ! -e "$runner.preauto" ]; then
    /bin/cp -p "$runner" "$runner.preauto"
  fi

  /usr/bin/install -o root -g wheel -m 0555 "$tmp" "$runner"
  /bin/rm -f "$tmp"

  /usr/sbin/service cpansmoker onestart
  /usr/sbin/service cpansmoker onestatus
'
~~~

**このコマンドは実際に無制限の対象リストでテストを開始します。** 専用 VM と空き容量を確認してから実行してください。既存の File transport なら外部送信には切り替わりません。

ログ：

~~~sh
qm guest exec 152 -- /usr/bin/tail -n 80 /home/cpansmoke/logs/cpansmoker.log
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

成功判定は「サービスが起動する」だけではなく、ログに **Starting CPAN::Reporter::Smoker**、固定 list 以外の対象への処理、レポート生成や履歴の変化が確認できることです。最初の CPAN インデックス走査には時間がかかります。

## 2. 起動時に自動実行

**手動起動とログを確認できた後**、次の1行を Proxmox から実行します。

~~~sh
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable=YES
~~~

これで FreeBSD の次回起動時に **service cpansmoker start** が呼ばれます。**現在のサービスを start する操作ではありません**（上記 onestart で起動済み）。

状態を確認：

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable
~~~

## 停止・切り戻し

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestop
qm guest exec 152 -- /usr/sbin/sysrc cpansmoker_enable=NO
~~~

旧 runner に戻す場合（上記で停止した後）：

~~~sh
qm guest exec 152 -- /bin/sh -c '
  set -eu
  r=/usr/local/libexec/cpansmoker-run
  test -f "$r.preauto"
  /bin/cp -p "$r.preauto" "$r"
  /bin/sh -n "$r"
'
~~~

これで**自動的な CPAN のテスト開始・継続**が対象です。**VM 151 へのファイル転送・CPAN Testers への自動投稿は別工程**で、この手順には含みません。

注意：**qm guest exec の exitcode 0 は起動コマンドの成功であり、すべての CPAN ディストリビューションのテスト成功を意味しません。** ログと .rpt の生成結果を確認してください。

## 構築実績の更新（2026-11-22）

実際の FreeBSD VM 152 で次を確認しました。

- 固定ディストリビューション設定を外したあと、CPAN インデックスの取得と `Smoker: scanning and sorting index` がログに記録された。
- `service cpansmoker onestatus` は `cpansmoker is running as pid 3664.` を返した（確認時の PID であり恒久的な番号ではない）。
- `sysrc cpansmoker_enable=YES` を実行し、再照会で `cpansmoker_enable: YES` を確認した。

**未検証：** 再起動後の自動復帰、新規ディストリビューションのテスト完了と新しいレポート、長時間の無人運用。ローカル File transport のままで、VM 151 への自動送信はこのステップの対象外です。

次の無停止確認（Proxmox ホストから）：

~~~sh
qm guest exec 152 -- /usr/sbin/service cpansmoker onestatus
qm guest exec 152 -- /usr/bin/tail -n 100 /home/cpansmoke/logs/cpansmoker.log
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

### 実テストの進捗（2026-11-22 09:12 JST 以降）

追加の実機ログで、`Smoker: found 44947 distributions on CPAN` と `Smoker: testing Mogura-0.01 [1/44947]` を確認しました。固定リストから外れ、CPAN の候補を自動選択してテストを開始できています。ログには `Result: PASS` が複数ありますが、これは最終的な .rpt が保存された証拠ではありません。

同時点の状態は `cpansmoker is running as pid 3664.`、ディスク使用率 6%、空き容量 49 GB でした。**未確認**：Mogura-0.01 の最終レポート生成、VM 再起動後の自動復帰、長期間の運転、送信 VM への自動転送。44,947件すべてのテスト完了を意味する数字ではありません。

レポート確認（Proxmox ホストから）：

~~~sh
qm guest exec 152 -- /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
~~~

### 自動レポート生成を確認（2026-11-22）

VM 152 で固定 `list` を外した Smoker が `Mogura-0.01 [1/44947]`、続いて `SNMP-Info-3.985003 [2/44947]` を自動選択しました。ローカル File transport の `/home/cpansmoke/reports/` に**新しく生成されたレポート**を確認しました。

出力末尾20件の例：**PASS 19件・FAIL 1件**。その中には次が含まれています。

- `fail.Mogura-0.01.*.rpt`
- `pass.DBD-SQLite-1.78.*.rpt`
- `pass.Mojolicious-9.54.*.rpt`
- `pass.Module-Build-0.4234.*.rpt`

依存モジュールのテストも実施・記録されています。**FAIL はテスター本体の異常を意味しません**。失敗原因の判断にはレポート本文が必要です。また「PASS 19 / FAIL 1」は**表示された末尾20ファイルの内訳**であり、累積件数ではありません。

**確認済み：** CPAN の対象自動選択、ビルド／テスト、PASS/FAIL のローカルレポート保存、サービス稼働、`cpansmoker_enable=YES` 設定。

**未確認：** VM 再起動後の自動復帰、長期安定稼働、VM 151 経由での CPAN Testers への外部送信。テスト環境は File transport を継続します。

### レポート集計（2026-11-22、確認時点）

VM 152 の `/home/cpansmoke/reports` を再帰的に数えた結果：**PASS 33 / FAIL 1 / UNKNOWN 2 / NA 0、合計 36 件**。サービスは PID 3664 で稼働中。VM の root ファイルシステムは **57 GB 中 3.3 GB 使用（6%）、空き 49 GB** でした。

これは**ローカルに保存されているファイルの件数**であり、全 CPAN のテスト完了数や外部送信数ではありません。FAIL/UNKNOWN の原因は必要に応じて各 .rpt の内容で調べます。

VM 152 の自動巡回とローカル PASS/FAIL/UNKNOWN レポート生成は確認済み。**VM 再起動後の自動復帰・長期運転・VM 151 を使った自動投稿は未検証**です。

### 次の運用改善：ログローテーション（停止前の事前確認）

テストの C/XS コンパイルでログが短時間に増えるため、FreeBSD 標準の **newsyslog** を使います。公開した [rc.d の参考実装](scripts/cpansmoker) には、SIGHUP で出力ログを開き直す **daemon -H** を追加しました。[newsyslog 設定例](newsyslog.conf.d/cpansmoker.conf) は **10 MiB 超で最大7世代**・所有者 cpansmoke・600 権限です。**newsyslog の定期実行間隔（通常1時間）ごとに判定**され、厳密な 10 MiB 上限ではありません。保存済み **.rpt** は対象外です。

**稼働中の daemon に -H は後から反映できません。** 現在の VM で rc.d の実ファイルと既存 newsyslog 設定を読み取って確認してから、メンテナンス時に一度だけ Smoker を停止・起動します。**-H のない daemon のまま newsyslog を有効化しないでください**（ローテーション後も元ファイルを掴む可能性）。停止中のテストは中断され得ます。

設定と安全な検証の順番は [OPERATIONS.md](OPERATIONS.md#log-rotation-for-continuous-cpan-smoke-testing) を参照。続いて再起動後の自動復帰試験を行います。

### ログローテーションの実動作確認（2026-11-22）

FreeBSD VM 152 の既存 rc.d に `/usr/sbin/daemon -f -H -R 60` を設定し、Smoker を再起動。監視デーモン **PID 23755**、Smoker 本体 **PID 23756** が稼働し、CPAN インデックスの走査を再開しました。

`/usr/local/etc/newsyslog.conf.d/cpansmoker.conf` を読み込む dry-run が成功した後、対象を `/home/cpansmoke/logs/cpansmoker.log` のみに限定して `newsyslog -F -P -v` を実行しました。

**観測結果：**

- 旧ログは `cpansmoker.log.0` に保存（約 5.8 MB）。
- 新ログは `cpansmoker.log` として作成（確認時点で 8.6 KB）。
- newsyslog は監視デーモン PID **23755** に SIGHUP を通知。
- ローテーション後も `service cpansmoker onestatus` は **PID 23755 で稼働中**を返した。

以上により、**サービスを停止しないログローテーション**を実証しました。新しいログがその後も継続して伸びるか、次回の定期 newsyslog 実行、FreeBSD VM 再起動後の自動復帰は別途確認事項です。外部 CPAN Testers への投稿は File transport のローカル保存とは別工程です。
