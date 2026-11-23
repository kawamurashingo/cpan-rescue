# Proxmox ホストからだけ SSH 接続できるようにする

[English](HOST-SSH.md) | [最新の実機記録](HANDOFF-2026-11-23.ja.md) | [導入ガイド](README.ja.md)

## 原因と変更範囲

2026-11-23、両 FreeBSD VM の `sshd` は IPv4 の `*:22` で待受し、IP・経路も正しかった一方、Proxmox ホストから TCP/22 はタイムアウトした。ホストの独自 nftables 規則で、`cpan151_filter input` の `iifname "vmbr1" drop`、`cpan152_filter input` の `iifname "vmbr2" drop` が **ホスト発 SSH の応答も破棄**していた。`pve-firewall disabled/stopped` や iptables の ACCEPT ポリシーだけでは、この独自規則を確認できない。

次の条件をすべて満たす受信パケットだけを、既存の input drop より前で許可する。

| 条件 | VM 151 | VM 152 |
| --- | --- | --- |
| ホストの受信インターフェース | `vmbr1` | `vmbr2` |
| 送信元 → 宛先 IPv4 | `10.151.0.2` → `10.151.0.1` | `10.152.0.2` → `10.152.0.1` |
| TCP 送信元ポート | `22` | `22` |
| conntrack 状態・方向 | `established` / `reply` | `established` / `reply` |

`ct direction reply` は、ホストから開始した接続の応答であることを要求する。VM 発の新規接続、VM 間の転送、他の TCP ポートの応答には許可を追加しない。既存の forward/NAT 規則と DNS/HTTP/HTTPS の制限を維持する。**ping の応答も引き続き遮断される**ので、SSH 経路は TCP/22 で確認する。

これは通信経路の修正であり、SSH 認証やレポート転送の完成ではない。ホスト鍵の確認・専用鍵・権限制限・転送の完全性検証は次の段階で行う。

## 1. 永続設定の候補を生成する（実機は変更しない）

以下は **Proxmox ホストの root** で、本リポジトリのルートから実行する。既存構成専用の手順であり、新規環境用のファイアウォール全体を生成するものではない。

~~~sh
perl docs/cpan-testers/scripts/prepare-host-ssh.pl \
  --vm-id 151 --input /root/cpan151.nft --output /root/cpan151.nft.host-ssh.next
perl docs/cpan-testers/scripts/prepare-host-ssh.pl \
  --vm-id 152 --input /root/cpan152.nft --output /root/cpan152.nft.host-ssh.next

diff -u /root/cpan151.nft /root/cpan151.nft.host-ssh.next
diff -u /root/cpan152.nft /root/cpan152.nft.host-ssh.next
~~~

差分は各ファイルの **input chain の drop 直前に追加する1行だけ**であることを確認する。`diff` の終了コード 1 は差分ありを表す。候補は 0600 で排他的に新規作成し、元ファイル・実行中の規則は変更しない。既存の出力ファイル、想定外の input chain、既に修正済みの入力は拒否する。

元ファイルをバックアップする。表示された保存先を控える。

~~~sh
cpan_backup_dir=$(mktemp -d /root/cpan-host-ssh-backup.XXXXXX)
cp -p /root/cpan151.nft /root/cpan152.nft "$cpan_backup_dir/"
nft list ruleset > "$cpan_backup_dir/ruleset-before.nft"
printf 'Backup: %s\n' "$cpan_backup_dir"
~~~

## 2. 実行中の input chain に2行だけ追加する

まず既存の chain と、差分の構文を確認する。

~~~sh
nft -a list chain inet cpan151_filter input
nft -a list chain inet cpan152_filter input
nft --check --file docs/cpan-testers/nftables/host-ssh-replies.nft
~~~

両 input chain が記録どおりで、`cpan-rescue-host-ssh-151` / `cpan-rescue-host-ssh-152` のコメントがまだなく、構文検査が成功した場合に **1回だけ**適用する。片方だけ既にあるなど記録と異なる場合は、適用前に内容を照合する。

~~~sh
nft --file docs/cpan-testers/nftables/host-ssh-replies.nft
nft -a list chain inet cpan151_filter input
nft -a list chain inet cpan152_filter input
~~~

差分は `insert rule` 2件のバッチで、既存のテーブル・規則を削除しない。新しい規則の下に元の drop が残ることを確認する。

## 3. TCP/22 と遮断を両方確認する

ホスト → 両 VM は接続成功が期待値。

~~~sh
timeout 5 nc -n -z -v -w 3 10.151.0.2 22
timeout 5 nc -n -z -v -w 3 10.152.0.2 22
~~~

VM → 自身のホスト IP と VM → 相手 VM は、TCP/22 の接続失敗が期待値。Guest Agent が応答することを確認してから、**1コマンドずつ**実行する。

~~~sh
timeout 12 qm guest exec 151 -- /usr/bin/nc -n -z -v -w 3 10.151.0.1 22
timeout 12 qm guest exec 152 -- /usr/bin/nc -n -z -v -w 3 10.152.0.1 22
timeout 12 qm guest exec 151 -- /usr/bin/nc -n -z -v -w 3 10.152.0.2 22
timeout 12 qm guest exec 152 -- /usr/bin/nc -n -z -v -w 3 10.151.0.2 22
~~~

`qm` 自体の終了コードだけで判断せず、JSON の `exited=1`、ゲストの `exitcode`、`err-data` 等を確認する。`nc` の存在も確認する。コマンド不存在、Guest Agent タイムアウト、PID だけの応答は遮断の証明にならない。応答不明時は後続の Guest Agent コマンドを投入しない。

この確認は各方向の TCP/22 の到達性に限定される。外部公開サイトへの到達、SSH 認証、全プロトコルの隔離、OS 再起動後の復帰を検証済みとは記録しない。

## 4. 成功した後に永続設定を置き換える

専用の `cpan151-network.service` / `cpan152-network.service` は、それぞれ `/usr/local/sbin/cpan151-network-up` / `/usr/local/sbin/cpan152-network-up` から `/root/cpan151.nft` / `/root/cpan152.nft` を初期ロードする。**テーブルが既にある場合は再ロードを省略する**実装なので、サービス再起動で規則を更新しようとしない。

バックアップ・差分・疎通を確認後、同じディレクトリの候補を元ファイルへ置換する。

~~~sh
mv /root/cpan151.nft.host-ssh.next /root/cpan151.nft
mv /root/cpan152.nft.host-ssh.next /root/cpan152.nft
~~~

この時点で起動時の入力ファイルも更新されるが、**実機の再起動検証は別途**行う。`nftables.service` を新しく有効化する必要はない。Smoker の停止・VM の再起動・レポート投稿もこの手順には含まない。

## 戻す場合

`nft -a list chain ... input` で、今回追加した **該当コメントの handle** を確認し、その規則だけ削除する。handle は実機出力を使い、過去の値を流用しない。

~~~text
nft delete rule inet cpan151_filter input handle <151の追加規則のhandle>
nft delete rule inet cpan152_filter input handle <152の追加規則のhandle>
~~~

永続ファイルを置換済みなら、控えたバックアップ内の各ファイルも元へ戻す。全 ruleset の flush や他の規則の削除は行わない。

## 開発時の検証

候補生成の回帰テストは Perl のコアモジュールだけで実行できる。

~~~sh
prove -v docs/cpan-testers/tests/*.t
~~~

Linux の network namespace 統合テストは、破棄可能な CI 実行環境で root と `iproute2` / `nftables` を使う。新規 namespace 内だけで変更し、元の TCP/22 タイムアウト、修正後の通信、他ポートと VM 発通信の遮断、永続候補からの再構築を検証する。

~~~sh
bash docs/cpan-testers/tests/host-ssh-network.sh
~~~

参照：[nftables conntrack](https://wiki.nftables.org/wiki-nftables/index.php/Matching_connection_tracking_stateful_metainformation)、[nftables 構文](https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes)。
