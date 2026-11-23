# FreeBSD / Proxmox から CPAN Tester になる

[English](README.md) | **[既存 VM 152 の自動化手順](ACTIVATE-EXISTING.ja.md)** | [設計](ARCHITECTURE.md) | [運用・トラブル対応](OPERATIONS.md)

**2026-11-23 の最新状態・次回の続き：** [作業引き継ぎ（最新の正本）](HANDOFF-2026-11-23.ja.md)。SSH の応答を独自 nftables 規則が遮断していることを特定し、[ホスト発 SSH の修正手順](HOST-SSH.ja.md)を追加しました。以下の構築手順・「未確認」一覧は作成時点の説明であり、実機の最終状態は引き継ぎページを参照してください。

これは実際に構築した **Proxmox VE + FreeBSD 15.1 + Perl 5.42.3 + CPAN::Reporter::Smoker** 環境を、第三者が再現できるようにまとめたガイドです。**まずローカルにテストレポートを生成し、その後に本人の判断で CPAN Testers への投稿へ進みます。** Proxmox は任意で、FreeBSD VM 単独でも手順を始められます。

## 重要な安全対策

CPAN のビルドやテストでは、他人がアップロードした任意のコードが動きます。必ず **破棄可能な専用 VM** で実行してください。スナップショットを取り、ホストの共有フォルダ・本番の認証情報を持ち込まず、ネットワークと CPU/ディスクを制限します。**本番環境では実行しません。** テストレポート自体にも環境変数やパスなどが含まれ得るため、公開前に確認が必要です。

## 1. FreeBSD に必要なものを入れる

以下は FreeBSD VM **内の root** で実行します（Proxmox ホストではありません）。

~~~sh
pkg update
pkg install sudo perl5 p5-CPAN-Reporter p5-CPAN-Reporter-Smoker p5-Test-Reporter
pw useradd cpansmoke -m -s /bin/sh
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/logs
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/reports
install -d -o cpansmoke -g cpansmoke -m 0700 /home/cpansmoke/reports/hold
~~~

既に cpansmoke ユーザーが存在する場合は useradd を省略します。Perl のモジュールを検査：

~~~sh
sudo -n -H -u cpansmoke /usr/local/bin/perl -MCPAN::Reporter::Smoker -MTest::Reporter -e 'print "modules OK\n"'
~~~

## 2. CPAN とレポーターを初期設定する

~~~sh
sudo -H -u cpansmoke /usr/local/bin/perl -MCPAN -e shell
~~~

CPAN の対話設定を行い、CPAN シェルで：

~~~text
o conf init test_report
o conf commit
quit
~~~

次に、**/home/cpansmoke/.cpanreporter/config.ini** で File transport を設定します。対話設定で作られた他の項目は保持し、下記を設定・確認してください。

~~~ini
email_from = your-email@example.org
transport = File /home/cpansmoke/reports
send_report = yes
send_duplicates = no
command_timeout = 1200
~~~

メールアドレスは本人のものに置き換えます。**transport = File** のとき **send_report = yes** は「ローカルのファイルを保存する」という意味です。外部サーバーには送られません。CPAN 側の test_report も有効である必要があります。設定ウィザードが Metabase に言及しても、この段階では直接送信を有効化しません。

~~~sh
sudo -n -H -u cpansmoke /bin/sh -c 'grep -E "^[[:space:]]*(transport|send_report|send_duplicates|command_timeout)[[:space:]]*=" "$HOME/.cpanreporter/config.ini"'
~~~

## 3. まず1件だけ実テストする

~~~sh
sudo -n -H -u cpansmoke /usr/bin/env \
  PERL_CR_SMOKER_RUNONCE=1 \
  /usr/local/bin/perl -MCPAN::Reporter::Smoker \
  -e 'start(list => [q{NEILB/Text-Diff-1.46.tar.gz}], install => 0, set_term_title => 0)'
~~~

- **RUNONCE=1** は1巡で終了するための指定、**list** はテスト対象を限定する指定です。
- **PERL_CR_SMOKER_SHORTCUT=1** を付けるとテスト開始前に終了するので、実テストでは指定しません。
- **already tested** は同じ対象のテスト履歴が存在し、スキップされたという意味です。新しいテストの成功を意味しません。

結果を確認：

~~~sh
sudo -n -H -u cpansmoke /usr/bin/find /home/cpansmoke/reports -type f -name '*.rpt' -print
sudo -n -H -u cpansmoke /usr/local/bin/perl \
  ./docs/cpan-testers/scripts/check-reports.pl /home/cpansmoke/reports
~~~

後者は clone した本リポジトリのルートから実行するか、スクリプトを絶対パスに変更してください。このスクリプトはファイルを**読み込むだけで送信しません**。

元の環境では **File-Marker-0.14 / Algorithm-Diff-1.201 / Text-Diff-1.46** の3件の PASS レポートを保存し、Test::Reporter で再読込できました。保留用の **reports/hold/** は運用上のステージング場所であり、File transport の必須構成ではありません。

## 4. 自動運転（任意）

実テストとレポート確認の後でのみ実施します。FreeBSD の root で、clone した本リポジトリのルートから：

~~~sh
install -m 0555 docs/cpan-testers/scripts/cpansmoker-run /usr/local/libexec/cpansmoker-run
install -m 0555 docs/cpan-testers/scripts/cpansmoker /usr/local/etc/rc.d/cpansmoker
sh -n /usr/local/libexec/cpansmoker-run
sh -n /usr/local/etc/rc.d/cpansmoker
service cpansmoker onestart
service cpansmoker onestatus
tail -n 80 /home/cpansmoke/logs/cpansmoker.log
service cpansmoker onestop
~~~

付属の rc.d は動作済みの方式を整理した**参考実装**です。元の VM からの完全コピーではなく、独立した FreeBSD 新規環境での動作はまだ検証していません。必ず **start/status/stop** を確認してから自動起動します。

~~~sh
sysrc cpansmoker_enable=YES
service cpansmoker start
~~~

停止・無効化は **service cpansmoker stop** および **sysrc cpansmoker_enable=NO**。自動運転用の runner では固定対象の list を外し、CPAN の候補を巡回します。**daemon -R 60** は Smoker 子プロセスが終了した際の再起動待ち時間で、60秒ごとのテストではありません。

## 5. 本当に CPAN Testers へ投稿するには

**.rpt の生成成功は投稿成功とは別です。** 投稿には本人の Metabase プロファイルと適切な transport 設定が必要です。公式の [CPAN::Reporter](https://metacpan.org/pod/CPAN::Reporter) を参照してください。

- 単独 VM の場合：本人の判断で **p5-Test-Reporter-Transport-Metabase** と **p5-Metabase-Fact** を導入し、**metabase-profile** で本人のプロファイルを作り、**~/.cpanreporter/metabase_id.json** を 0600 で保存し、投稿する環境の transport を **Metabase** に切り替えます。既存レポートの無条件の再送はしません。
- 分離構成の場合：**VM 152 はテストだけ**（File transport）、**VM 151 は送信だけ**（認証情報を保持）とします。レポートを SHA-256 で検証してから送信し、送信済み台帳で重複送信を防ぎます。詳細は [ARCHITECTURE.md](ARCHITECTURE.md)。

**認証用 JSON、個人情報、実際の .rpt、テストログを Git に登録しないこと。** レポートは公開前に環境情報を点検します。

## Proxmox VE から操作する場合（任意）

QEMU Guest Agent が動いていることを確認してください。VM 152 は例なので、自分の VM ID に置き換えます。

~~~sh
qm guest exec 152 -- /usr/local/bin/sudo -n -H -u cpansmoke \
  /usr/local/bin/perl -MCPAN::Reporter::Smoker -e 'print "Perl OK\n"'
qm guest exec 152 -- /usr/bin/tail -n 80 /home/cpansmoke/logs/cpansmoker.log
~~~

**qm guest exec の exitcode 0 は、デーモン化後の Perl のテスト終了を保証しません。** PID・ログ・レポートを確認します。

## 確認済み／未確認

**確認済み**：FreeBSD 15.1 / Perl 5.42.3、非 root ユーザー、File transport、3件の PASS レポート保存と再読込、履歴による重複テスト回避、元環境での rc.d サービス操作・daemon の再起動。

**未確認**：この公開手順を新規 VM へ通しで再現したこと、同梱 rc.d の別環境での動作、汎用化した VM 間転送・送信キューの完全自動化、長期無人運転。ここは成功済みと装いません。
