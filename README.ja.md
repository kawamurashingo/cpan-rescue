# CPAN Rescue

[English](README.md) | **日本語**

**CPAN Rescue は、実際のソフトウェアをメンテナンスすることで、メンテナを育てるプロジェクトです。**

> **初めて参加する方へ：** [最初の CPAN Rescue コントリビューションはこちら →](FIRST_CONTRIBUTOR.ja.md)  
> PAUSE アカウントや CPAN へのリリース経験は不要です。一番小さなタスクなら30〜60分ほどで試せます。

CPAN にはメンテナンスを必要としている有用なディストリビューションが数多くあります。一方で、オープンソースのメンテナになるための参入障壁は、想像以上に高いものです。

CPAN Rescue は、この2つの課題をつなぎます。

参加者は、実在するディストリビューションのメンテナンスを通して学びます。現状調査、不具合の再現、回帰テストの追加、CI やメタデータの改善、下流への影響評価、リリース準備、そして適切な場合には最終的な保守責任の引き継ぎまで、実際の作業に取り組みます。

このプロジェクトは、放置された、または十分にメンテナンスされていない Perl ディストリビューションを救済し続けます。ただし、採用（adoption）そのものが第一の目的ではありません。

**目的は、メンテナを増やすことです。**

## 仕組み

CPAN Rescue では、実際のメンテナンス作業を、保守責任を担えるようになるまでの道筋として使います。

参加するために、ディストリビューションを採用したり、長期的な責任を引き受けたりする必要はありません。責任は、本人が望み、安全に引き受けられるだけの十分な文脈を得たときにのみ段階的に増えていきます。

メンテナへの道筋と責任方針は [MAINTAINER_PATH.md](MAINTAINER_PATH.md) に文書化し、[#28](https://github.com/kawamurashingo/cpan-rescue/issues/28) で追跡しています。

1. **Explorer（探索者）** — 候補を調査し、問題を再現したり、現在の状態を記録したりする。
2. **Contributor（コントリビュータ）** — 回帰テスト、限定的なバグ修正、CI 修復、メタデータ改善などを行う。
3. **Release Contributor（リリース・コントリビュータ）** — リリース成果物、下流テスト、リリース後の結果の準備・検証を手伝う。
4. **Co-maintainer（共同メンテナ）** — 経験あるメンテナと継続的なメンテナンス責任を共有する。
5. **Maintainer / Steward（メンテナ / スチュワード）** — 適切な場合に、独立してディストリビューションを保守・リリースする。

これはランキングではなく、進み方の一例です。どの段階で止めても、有効な貢献です。

## なぜ実際のメンテナンスなのか

メンテナンスは、練習用の小さなプロジェクトだけでは学びにくいスキルです。

メンテナには、次のようなことを学ぶ必要があります。

- 変更する前に既存の挙動を理解する
- upstream にもともと存在する失敗と、自分の変更による回帰を区別する
- 焦点を絞った回帰テストを書く
- 互換性を維持する
- upstream の作者や既存ユーザーと協働する
- CPAN/PAUSE の ownership とリリースの仕組みを理解する
- 実際のディストリビューション成果物をビルドして確認する
- 下流への影響を評価する
- CPAN Testers や下流テストをリリースのフィードバックとして使う
- 多くの他ディストリビューションが依存している場合に保守的な判断をする
- 状況が変わったときに、他のメンテナへ責任を引き継ぐ

CPAN Rescue は、こうしたスキルを、レビュー付き・責任範囲を限定した形で学べる実在のディストリビューションを提供します。

## 最初のメンテナンスに向いた作業

最初の貢献は、ディストリビューションの ownership を引き受けなくても理解・完了できる程度に小さいことが理想です。

最初のメンテナンス作業としては、たとえば次のようなものがあります。

- 現在の CPAN リリースとソースの基準点を確認する
- 既知の問題を再現し、記録する
- 既存挙動に対する回帰テストを追加する
- 保守的な CI を修復・追加する
- 生成されたメタデータを確認する
- クリーンな環境でリリース tarball をテストする
- 下流テストを実行して分類する

最初のコントリビュータ向けタスクは、すでに参加できる状態です。**実際の CPAN メンテナンスを試してみたい場合は、ここから始めてください。**

- [#37 — Log::Any::Adapter::Screen を現行 Perl で検証する](https://github.com/kawamurashingo/cpan-rescue/issues/37) — 初心者向け、約30〜60分。PR は不要です。
- [#33 — Log::Any::Adapter::Screen 0.141 のリリース基準を再構築する](https://github.com/kawamurashingo/cpan-rescue/issues/33) — Explorer、約1〜3時間。
- [#34 — 保守的な Perl CI matrix を構築する](https://github.com/kawamurashingo/cpan-rescue/issues/34) — Contributor、GitHub Actions に慣れている人で約1〜3時間。
- [#39 — CPAN Rescue 候補を1つ選び、現行 Perl でテスト可能か調査する](https://github.com/kawamurashingo/cpan-rescue/issues/39) — Explorer、約1〜2時間。

参加したいタスクの Issue に「やってみたい」とコメントしてください。PAUSE アカウントも、adoption の約束も、将来メンテナになるという約束も必要ありません。質問することも作業の一部であり、メンテナによるレビューとメンタリングを含みます。

タスク設計は [#29](https://github.com/kawamurashingo/cpan-rescue/issues/29)、最初の外部コントリビュータによる一連の育成実験は [#36](https://github.com/kawamurashingo/cpan-rescue/issues/36) で追跡しています。

これらは模擬演習ではなく、本物のメンテナンス作業です。それぞれに具体的な成果物、検証方法、明確な責任範囲、レビューまたはメンタリングへの導線があります。

## 責任と引き継ぎ

メンテナになることが、期限のない義務を引き受けることを意味してはいけません。

CPAN Rescue では、メンテナンスを永久的な ownership ではなく stewardship（預かって守る責任）として捉えます。参加者は責任を段階的に増やせるべきですし、メンテナは必要に応じて他の人へきれいに引き継げるべきです。

メンタリング、責任範囲、引き継ぎ方針は [#30](https://github.com/kawamurashingo/cpan-rescue/issues/30) で定義中です。

特に XS モジュールや CPAN River の上流に位置する高影響なディストリビューションでは、潜在的な下流影響が大きいほど、メンタリングとレビューもより保守的であるべきです。

## 実績

CPAN Rescue は、保守的な救済作業を、実際の upstream や CPAN 上の成果までつなげられることを示すところから始まりました。

現在の成果:

- **upstream PR 1件マージ済み**
- **追加の upstream PR 1件がレビュー待ち**
- **2ディストリビューションを採用**
- **採用後のメンテナンスリリースを1件 CPAN に公開**
- **Devel::CallChecker 0.010 を `SHINGO` からリリース。自体のテストスイート、メタデータ、署名、下流検証を実施**
- **Devel::CallChecker の stewardship は、採用時点で直接依存13件、直接または間接依存81件だった低レベル XS 互換モジュールを対象としている**
- 不要な本体コード変更を行わずに回帰テストを追加

これらの成果には、今ではもう1つの役割があります。救済ワークフローそのものを、他のメンテナに教えたり引き継いだりできる実践的なカリキュラムへ育てることです。

## 進行中の救済

この表は実作業用のタスクボードです。**まず「次のアクション」を見てください。** 次に何をすればよいかが具体的に書かれているべきです。「待ち」は、その出来事が起きるまで有効な作業がないことを意味します。

| ディストリビューション | 状態 | 次のアクション | 待ち | 追跡 |
| --- | --- | --- | --- | --- |
| Dist::CheckConflicts | Adoption 申請済み、upstream PR オープン | PAUSE または upstream から返答が来たら、権限を確認するか PR フィードバックに対応し、その後に保守的なリリース基準を確立する | PAUSE の adoption/co-maint 返答、または [PR #13](https://github.com/doy/dist-checkconflicts/pull/13) の upstream レビュー | [#1](https://github.com/kawamurashingo/cpan-rescue/issues/1) |
| Log::Any::Adapter::Screen | 採用済み | リポジトリ保守のガイダンスに従い、次のメンテナンス変更を決める | [upstream issue #5](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/issues/5) への返答・ガイダンス | [#2](https://github.com/kawamurashingo/cpan-rescue/issues/2) |
| Devel::CallChecker | 0.010 リリース済み | リリース後の結果を監視し、回帰が現れた場合のみ調査する | — | [#3](https://github.com/kawamurashingo/cpan-rescue/issues/3) |
| DBD::ODBC | WHINDS により採用済み、協力方針の返答待ち | Wesley Hinds の保守・リリース方針を待つ。歓迎されれば、焦点を絞った DBIXS 互換修正を upstream へ送り、既存の upstream 作業を補完する範囲で CI に貢献する。現メンテナが望む支援内容を把握した後、[#40](https://github.com/kawamurashingo/cpan-rescue/issues/40) で持続可能性・資金面を再検討する | Wesley Hinds の返答 | [#25](https://github.com/kawamurashingo/cpan-rescue/issues/25), [#40](https://github.com/kawamurashingo/cpan-rescue/issues/40) |
| Dist::Zilla::Plugin::MetaProvides family | 候補 | まず core distribution から始め、基準状態を再現し、下流検証方法を定義してから Package → Class → FromFile へ進む | — | [#27](https://github.com/kawamurashingo/cpan-rescue/issues/27) |

### このボードの使い方

CPAN Rescue の作業を再開するときは、具体的な **次のアクション** があり、未解決の **待ち** 依存がない行を選びます。調査の詳細や証拠は追跡 issue に残し、この README は短く保ち、**今どこにいるか、次に何をするか、何を待っているか** だけを答える場所にします。

## 最初に完了した stewardship の例

2026-09-15、CPAN Rescue は最初の2件の adoption 成功に到達しました。

- **Log::Any::Adapter::Screen** — PERLANCAR が first-come indexing permission を `SHINGO` に移譲することに同意しました。
- **Devel::CallChecker** — PAUSE admin の Neil Bowers が、CPAN River 上の位置を明示的に考慮したメンテナンス計画をレビューしたうえで、first-come indexing permission を `SHINGO` に移譲しました。

`Devel::CallChecker` は、XS コードから使われる Perl の call-checker API 向け低レベル互換レイヤーです。採用時、PAUSE admin の Neil Bowers は、直接依存13ディストリビューション、直接または間接依存81ディストリビューションを確認しました。

0.010 の前に、代表的な Perl バージョン上でリリース候補に対して直接依存をテストし、レビュー済みの 0.009 基準と比較して候補による回帰がゼロであることを確認しました。Devel::CallChecker 0.010 は 2026-09-19 にリリースされ、PAUSE に正常に index されました。

このワークフロー — 基準状態の再構築、保守的な変更、成果物の検証、下流テスト、リリース、リリース後のレビュー — は、CPAN Rescue が教えられる形にしたい「実際の stewardship 経験」の一例です。

## Incubation に向いたディストリビューションとは

メンテナ育成に向いたディストリビューションには、実際のメンテナンス価値があり、責任を理解可能な段階に分けられることが望まれます。

よい候補には、一般に次の特徴がいくつかあります。

- 現在も下流ユーザーや reverse dependency がいる
- 長期間メンテナンスされていない、または明示的に `ADOPTME` 状態である
- 維持する価値のある安定した有用 API がある
- 焦点を絞れるバグ、欠けている回帰テスト、CI 問題、メタデータ問題などがある
- コントリビュータ単位の小さなタスクに分割できる
- 十分に理解・テストできる程度のスコープである
- 活発な下流ディストリビューションや OS パッケージなど、継続利用の証拠がある
- CPAN River 上の位置と下流影響を責任をもって理解・検証できる
- 監督付きの貢献から独立した stewardship へ進む道筋が考えられる

すべての rescue 候補を adoption 候補にする必要はなく、すべての contributor がそのメンテナになる必要もありません。

## メンテナンスのワークフロー

既存の保守的なメンテナンスワークフローが、技術面の基盤です。

1. 下流ユーザーが存在し、メンテナンスが弱い、または欠けているディストリビューションを特定する。
2. 現在の CPAN リリース、ソースリポジトリ、reverse dependency、メンテナ状態を確認する。
3. 変更する前に問題を再現し、既存挙動を理解する。
4. 最初の貢献は小さくする。回帰テスト、限定的なバグ修正、CI 修復、メタデータ整理などを優先する。
5. 現行 Perl リリースでフルテストスイートを実行し、Perl バージョンとテスト環境を記録する。
6. CPAN River 上の位置を評価し、潜在的影響に比例した下流テスト計画を立てる。
7. upstream PR を送る。または、そのディストリビューションが明示的に adoption 可能で、誰かが stewardship を担う準備ができている場合に adoption を申請する。
8. リリース前には、実用的な範囲で直接依存をテストする。重大または互換性に敏感な変更では developer release を使う。
9. リリース後は CPAN Testers の結果を確認し、回帰があれば先に調査する。
10. 他のメンテナが理解し、最終的に引き継げる程度に作業を文書化する。

## メンテナンスとメンタリングの原則

- 明確な理由がない限り、既存 API と挙動を維持する。
- 大規模な書き換えより、小さくレビュー可能なパッチを優先する。
- 挙動修正には回帰テストを追加する。
- upstream に既存の失敗と、自分のパッチによる回帰を区別する。
- 一時的な調査や CI 実験を upstream PR に混ぜない。
- 何を、どの Perl バージョンでテストしたか記録する。
- adoption を勲章ではなく、継続的なメンテナンス責任として扱う。
- adoption 件数を成功指標にしない。
- 利用可能なメンテナが責任をもって支えられる以上の数を adoption しない。
- ownership を求める前に、意味のある作業を contributor に提供する。
- 責任を明示し、範囲を限定する。
- メンタリングとレビューもメンテナンス作業の一部として扱う。
- 引き継ぎを stewardship の通常の一部とする。
- CPAN River 上の位置をリリースリスクの一部として扱う。
- 高影響なディストリビューションでは、提案リリースに対して直接依存をテストし、重大な変更では developer release を使う。
- リリース後は CPAN Testers の結果を確認し、下流回帰を速やかに調査する。

## Rescue dashboard

Active rescues の表を、引き続き正式なディストリビューション・ダッシュボードとします。各追跡 issue では、先頭付近に `**Status:**` 行を置き、ownership/adoption 状態、upstream リンク、テスト証拠、下流影響、リリース詳細、次の具体的アクションを記録します。

rescue dashboard が答えるのは、**何をメンテナンスする必要があるか** です。

maintainer path が答えるのは、**誰がそれをメンテナンスする力を身につけられるか、そして次にどの責任を担える状態なのか** です。

## 成功をどう測るか

CPAN Rescue は、今後も次のような技術的成果を記録します。

- upstream PR のマージ
- adoption されたディストリビューション
- 公開されたメンテナンスリリース
- 修正されたバグや回帰
- メンテナンスされたディストリビューションから恩恵を受ける reverse dependency
- 下流互換性の検証結果

ただし、長期的な中心課題は次です。

**より多くの人が、能力と自信を備えたメンテナになっているか？**

incubation モデルが発展するにつれて、次の点も追跡していきます。

- 実際のメンテナンス作業を完了した contributor
- リリース検証に参加した contributor
- ディストリビューションに加わった co-maintainer
- 独立してリリースした新しい maintainer
- stewardship が別の maintainer へ正常に引き継がれた例

これらは経験と責任を表すためのもので、contributor のランキングを作るためのものではありません。

## 現在のプロジェクト開発優先事項

1. [#28 — CPAN Rescue の maintainer path を定義する](https://github.com/kawamurashingo/cpan-rescue/issues/28)
2. [#29 — 最初の good-first-maintenance タスクを作る](https://github.com/kawamurashingo/cpan-rescue/issues/29)
3. [#30 — メンタリング、責任、maintainer handoff 方針を文書化する](https://github.com/kawamurashingo/cpan-rescue/issues/30)
4. incubation モデルの検証に活用しながら、既存の rescue 作業を保守的に継続する。
5. 実証済みの maintenance-release ワークフローを、再利用可能な contributor 向けドキュメントにする。
6. [#40 — DBD::ODBC の持続可能なメンテナンスと資金調達を検討する](https://github.com/kawamurashingo/cpan-rescue/issues/40): 高影響な CPAN 基盤ソフトウェアが、スポンサーによる技術支配を招かずにメンテナンス能力へ資金を供給できる方法を探る具体例として DBD::ODBC を使う。
7. [#41 — 高影響 CPAN の rescue / sustainability ポートフォリオを作る](https://github.com/kawamurashingo/cpan-rescue/issues/41): rescue、co-maintenance、資金調達、移行候補の根拠付き shortlist を維持し、範囲を限定した最初のタスクができたものだけ専用 rescue issue に昇格させる。

## 持続可能なメンテナンス

メンテナを増やすことは、誰かが責任を引き受けた後も、そのメンテナンスを持続可能にすることを含みます。

下流や本番環境で大きく使われている基盤ディストリビューションでは、ボランティアだけでは、継続性、互換性テスト、レビュー能力、緊急時のメンテナンスを十分に確保できないことがあります。そのため CPAN Rescue では、メンテナ主導の技術的ガバナンスを守りながら、助成金、継続的スポンサーシップ、財政ホスティングなど、共有メンテナンス能力に資金を提供する方法も検討できます。

最初の具体例が DBD::ODBC です。[Issue #40](https://github.com/kawamurashingo/cpan-rescue/issues/40) で議論を追跡しています。出発点は、メンテナ本人の同意、現在のメンテナンス需要、本番利用の証拠、CI/互換性要件、小規模な資金提供パイロットが有用かどうかです。

目標は、すべての rescue を資金付きプロジェクトにすることではありません。資金がいつ適切なのか、スポンサーによる支配やメンテナへの過剰な義務を生まずに、どうすれば一人への依存を減らせるかを学ぶことです。

## ゴール

**CPAN のメンテナンスを、取り組む価値のあるものにする。そして、メンテナになることを現実的に達成可能なものにする。**
