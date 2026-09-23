# CPAN Rescue の長期ビジョン

CPAN Rescue は、古い Perl モジュールをいくつか救うためだけの活動ではない。

長期的には、オープンソースを「作る」だけでなく、社会が依存しているソフトウェアを継続的に見つけ、理解し、保守し、次の世代へ引き継ぐための **OSS の保守インフラ** になり得る。

## OSS の保守インフラ

オープンソースの世界では、新しいソフトウェアを作る仕組みは充実している。一方で、長年使われ続けているソフトウェアを誰が保守し、誰が引き継ぐのかについては、個々の maintainer の善意や時間に依存する部分が大きい。

しかし、広く依存されているソフトウェアの保守は、本来もっと継続的な活動であってよい。

CPAN Rescue が目指せるのは、単に abandoned distribution を adoption することではなく、

- 保守が弱くなっているソフトウェアを見つける
- 現在も使われているかを確認する
- downstream impact を理解する
- 現在の環境で問題を再現する
- 小さく安全な修正と regression test を作る
- upstream と協力する
- 必要なら stewardship を引き継ぐ
- release 後も downstream を確認する
- 次の maintainer に責任を渡せる状態を作る

という一連の流れそのものを、再利用可能な保守の仕組みにすることだ。

これは CPAN だけに閉じた考え方ではない。PyPI、npm、RubyGems、crates.io、Maven など、長く使われる package ecosystem には同じ問題がある。

CPAN Rescue は、そのための小さな実験場になれる。

## AI が候補を見つけ、人間が責任を持って保守する

将来、すべての distribution を人間が目視で調査する必要はない。

AI や自動化された scanner は、

- reverse dependencies
- CPAN River 上の位置
- 最終 release からの期間
- maintainer / ownership の状態
- CPAN Testers の failure
- 現行 Perl での testability
- downstream distribution や OS package での継続利用
- repository activity

などの公開情報から、保守上の注意が必要な候補を継続的に探すことができる。

ただし、AI の役割は「勝手に直して release すること」ではない。

> **AI が候補を見つけ、人間が責任を持って保守する。**

AI はレーダーとして働く。

「この distribution は重要かもしれない」「ここに regression の兆候がある」「この downstream impact を確認した方がよい」と、人間が調査すべき場所を示す。

そして人間が、

- evidence を確認する
- existing behavior を理解する
- compatibility を判断する
- upstream maintainer と話す
- patch を review する
- release の責任を持つ

という役割を担う。

自動化の目的は、人間から責任を取り除くことではない。

**人間が責任を持つべき場所を、より早く、より正確に見つけられるようにすること**である。

## Rescue Radar

この考え方の一つの具体形が Rescue Radar である。

```text
package ecosystems
       |
       v
 automated observation / AI
       |
       v
 possible maintenance risk
       |
       v
 evidence gathering
       |
       v
 human review
       |
       v
 small, conservative maintenance
       |
       v
 upstream / stewardship / release
       |
       v
 downstream verification
```

Radar は単純な「古い package ランキング」ではない。

古いこと自体は問題ではない。安定していて変更を必要としないソフトウェアもある。

重要なのは、**impact、maintenance risk、actual breakage、continued use の evidence を組み合わせて見ること**である。

そして候補を検出した理由を説明可能にしておく。

人間が「なぜこれを見る必要があるのか」を理解できない自動判定は、保守インフラとしては弱い。

## 成功した Rescue は目立たない

この活動の成功は、adoption 数や commit 数だけでは測れない。

理想的な未来では、ある developer が何年後かに古いシステムを更新し、依存している package を install する。

そして普通に動く。

その developer は、その package が何年か前に maintenance risk に陥っていたことを知らないかもしれない。

誰かが regression test を追加したことも、downstream test をしたことも、ownership を引き継いだことも知らないかもしれない。

それでよい。

> **誰も「Rescue された」と気づかないくらい、OSS が普通に長生きする。**

それが保守インフラとしての成功である。

橋や水道と同じように、正常に動いているときのインフラは意識されにくい。

OSS の保守も、いつかそういう存在になれるかもしれない。

## CPAN Rescue が試せること

CPAN Rescue は小さいからこそ、この未来を実験できる。

まず CPAN で、

1. 本当に保守が必要な software を見つける方法を学ぶ
2. conservative maintenance の手順を磨く
3. downstream impact の測り方を学ぶ
4. 新しい maintainer が安全に経験を積める道を作る
5. stewardship と handoff を普通のものにする
6. AI / automation を「判断者」ではなく「レーダー」として使う
7. その方法を他の ecosystem でも再利用できる形にする

ということを積み重ねる。

CPAN Rescue の対象は CPAN だが、ここで学べることは CPAN より大きい。

## Long-term direction

最終的に目指したいのは、より多くの package を所有することではない。

より多くの software が、

- 誰か一人の善意だけに依存せず
- 問題が深刻になる前に発見され
- downstream impact を理解した上で安全に修正され
- 新しい maintainer が参加でき
- 必要なら責任を次の人へ渡せる

状態になることである。

つまり、

> **software を救うプロジェクトから、software が長生きできる仕組みへ。**

CPAN Rescue は、その仕組みを小さく作り、実際の maintenance を通して学ぶ場所でありたい。
