# はじめての CPAN Rescue

[English](FIRST_CONTRIBUTOR.md) | **日本語**

CPAN Rescue は、実際のソフトウェアをメンテナンスすることで、メンテナを育てるプロジェクトです。

このページは、「CPAN メンテナになると約束するほどではないけれど、本物の CPAN メンテナンスを一度やってみたい」という人のための最短ルートです。

## こんな人向けです

次のような人なら参加できます。

- ターミナルから Perl を実行できる
- Git と GitHub の基本が分かる
- CPAN distribution がどうメンテナンスされているか興味がある
- CPAN へのリリース経験はなくてもよい

PAUSE アカウントは必要ありません。distribution を引き取る必要もありません。継続して参加すると約束する必要もありません。

## まずはここから

一番小さな最初の一歩は、次のタスクです。

**[#37 — Good First Rescue: Log::Any::Adapter::Screen を現行 Perl で検証する](https://github.com/kawamurashingo/cpan-rescue/issues/37)**

目安は **30〜60分** です。

やることは意図的に小さくしてあります。

1. upstream の distribution をチェックアウトする
2. 現行の Perl でテストスイートを実行する
3. OS、Perl のバージョン、実行したコマンド、PASS/FAIL の結果を Issue に記録する

Pull Request は不要です。CPAN へのリリースも不要です。Issue に残した「再現可能なメンテナンスの証拠」そのものが成果です。

参加するには、#37 に「やってみたい」とコメントしてください。質問して大丈夫です。レビューとメンタリングもタスクの一部です。

## 終わったらどうなる？

最初のタスクをやってみて面白かったら、そこで終了してもいいですし、もう少し大きなメンテナンス作業へ進むこともできます。

- [#33 — Log::Any::Adapter::Screen 0.141 のリリース基準を再構築する](https://github.com/kawamurashingo/cpan-rescue/issues/33) — Explorer、約1〜3時間
- [#34 — 保守的な Perl CI matrix を構築する](https://github.com/kawamurashingo/cpan-rescue/issues/34) — Contributor、GitHub Actions に慣れている人で約1〜3時間
- [#39 — CPAN Rescue 候補を1つ選び、現行 Perl でテスト可能か調査する](https://github.com/kawamurashingo/cpan-rescue/issues/39) — Explorer、約1〜2時間

先へ進む義務はありません。Maintainer Path は責任を増やせるようにするための道筋であって、全員に昇格を求めるものではありません。

## 何を学べる？

最初のタスクでは、本物のメンテナンス作業を小さく切り出して経験します。信頼できる baseline の作り方、再現可能な証拠の残し方、環境の問題と distribution の問題の切り分け、保守的な変更のレビュー、そして次のメンテナが判断できる形で結果を伝える方法などです。

対象は本物の distribution で、判断も本物のメンテナンス判断です。模擬演習ではありません。

## CPAN Rescue が約束すること

- 成果が明確で、範囲の限定されたタスクを用意します
- どこまでがあなたの責任かを明確にします
- 初心者向けタスクでは PAUSE やリリース権限を要求しません
- レビューとメンタリングを行います
- 質問することを歓迎します
- module の adoption や長期参加を求めません
- 有用なメンテナンス作業を記録し、貢献として扱います

手順で分からないところがあったら、それも重要なフィードバックです。「自分で全部分からないといけない」と思わず、Issue で聞いてください。

## Maintainer Path

続けたい場合は、次のような道筋があります。

**Explorer → Contributor → Release Contributor → Co-maintainer → Maintainer / Steward**

どの段階でも止まれます。次へ進むのは、プロジェクトが無料の労働力を必要としているからではなく、本人がより大きな責任を持ちたいと思い、それまでのスキルを身につけたときです。

メンテナ育成の実験全体は [#36](https://github.com/kawamurashingo/cpan-rescue/issues/36) で追跡しています。

## やってみますか？

[#37](https://github.com/kawamurashingo/cpan-rescue/issues/37) を開いて、「やってみたい」とコメントしてください。まずは今使える環境からで大丈夫です。

CPAN メンテナンスへようこそ。
