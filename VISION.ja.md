# CPANを越えて：Open Source Rescue のビジョン

CPAN Rescue は CPAN から始まる。しかし、そこで扱っている問題は Perl 固有のものではない。

成熟した package ecosystem には、今も多くの software から依存されている一方で、以前ほど十分な保守を受けられなくなった software が少しずつ蓄積していく。これは CPAN だけでなく、PyPI、npm、RubyGems、crates.io、Maven などでも起こり得る。

だから長期的な構想は、Perl module を救うことより大きい。

> **ecosystem を越えて、OSS が長く生きられるための保守インフラを作る。**

CPAN は、その方法を実際の maintenance を通して開発し、試す最初の場所である。思想の終着点ではない。

## 問題は CPAN 固有ではない

OSS には、新しい software を作り、公開し、配布するための優れた仕組みがある。一方で、別の問いに対するインフラはまだ弱い。

**最初の活発な開発期間が終わった後、重要な software をどう維持するのか。**

古い package は abandoned とは限らない。成熟しているだけかもしれない。maintainer の使える時間が減っただけかもしれない。そして長い間まったく問題なく動いていても、language runtime、compiler、OS、dependency、security expectation などの変化によって、ある日 maintenance が必要になることがある。

その間も downstream の software は何年も依存し続ける。

これは CPAN 固有の lifecycle ではない。長く続く OSS ecosystem 全体の問題である。

必要なのは、繰り返し使える方法だ。

- 保守が弱くなっている software を見つける
- 現在も使われているか確認する
- downstream impact を理解する
- 「古いが安定している software」と「本当に対応が必要な software」を区別する
- 現在の環境で実際の問題を再現する
- regression test を伴う小さく保守的な修正を行う
- existing upstream maintainer と協力する
- 必要なら stewardship を引き継ぐ
- release 後に downstream を確認する
- 将来また責任を handoff できる状態を作る

個々の package を誰が所有するかより、このプロセスを再利用可能にすることの方が重要である。

## CPAN Rescue は実験場

CPAN Rescue は、この考え方の最初の実装である。

CPAN には実際の ecosystem、dependency、長く使われている distribution、maintainer、downstream user がいる。だから「責任ある Rescue には何が必要なのか」を現実の maintenance を通して学べる。

そこで得た方法を、将来ほかの ecosystem に翻訳できる形にしていきたい。

```text
             Open Source Rescue
                    |
       +------------+------------+
       |            |            |
      CPAN         PyPI         npm       ...
       |            |            |
       +------------+------------+
                    |
             共通する保守の考え方
                    |
       discovery / evidence / review
       stewardship / handoff / verification
```

tool や用語は ecosystem ごとに違う。しかし根底にある maintenance の問題には共通する部分がある。

## AI が候補を見つけ、人間が責任を持って保守する

ecosystem 全体を人間だけで常時確認することは難しい。

そこで AI や automated scanner が **maintenance radar** として働ける。

ecosystem に応じて、

- reverse dependencies / dependency graph
- ecosystem 内での impact
- 最後の meaningful maintenance からの期間
- maintainer / ownership status
- CI や ecosystem test の failure
- current runtime との compatibility
- downstream での継続利用
- OS package での利用
- repository activity
- regression / breakage report

などを観測する。

使える signal は ecosystem ごとに違う。しかし原則は同じである。

> **AI が候補を見つけ、人間が責任を持って保守する。**

AI は「調べる価値がある場所」と、その根拠を示す。

AI が無条件に自律的な maintainer になることを目指すわけではない。

existing behavior を理解し、compatibility を判断し、upstream と対話し、patch を review し、stewardship を引き受けるべきか判断し、release に責任を持つのは人間である。

自動化は責任をなくすためのものではない。

**人間が責任を持つべき場所を見つけるためのもの**である。

## Rescue Radar

将来的な Rescue Radar は、複数の ecosystem を観測できるかもしれない。

```text
 CPAN     PyPI     npm     RubyGems     crates.io     ...
   \       |       /          |            /
            v
      ecosystem observations
            |
            v
        Rescue Radar
            |
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

古い software が壊れているとは限らない。何年も変更されていないのは、単に十分安定しているからかもしれない。

重要なのは、

**impact + maintenance risk + actual breakage + continued use**

という evidence を組み合わせることである。

そして、なぜその候補が検出されたのかを説明できなければならない。

Rescue Radar は人間の判断を置き換えるものではなく、人間の判断を助けるものだからだ。

## 成功した Rescue は目立たない

この活動の成功は、adoption、commit、pull request、release の数だけでは測れない。

何年後か、ある developer が古い system を更新するとする。その dependency tree の奥には、元の maintainer がずっと前に活動を離れた package がある。

developer は dependency を install する。

普通に動く。

かつて誰かが regression に気づき、test を書き、upstream に連絡し、compatibility を修復し、downstream を確認し、別の maintainer へ stewardship を渡したことを、その developer は知らない。

それでよい。

> **誰も「Rescue された」と気づかないくらい、OSS が普通に長生きする。**

正常に動いているインフラは、普段あまり意識されない。

OSS maintenance も、そういうインフラになれる。

## CPAN から何を学べるか

CPAN Rescue は小さく始めながら、もっと広い問いを試すことができる。

1. 本当に maintenance が必要な software をどう発見するか
2. abandonment と mature stability をどう区別するか
3. downstream impact をどう測るか
4. conservative maintenance とは何か
5. 新しい maintainer が安全に経験を積むにはどうするか
6. stewardship と handoff はどうあるべきか
7. 人間の責任を置き換えず、AI をどこに使えるか
8. どの signal や practice が ecosystem を越えて再利用できるか

答えを Perl 固有のものにする必要はない。

CPAN Rescue の成果は CPAN distribution が健全になることだけではなく、他の community が自分たちの ecosystem に適用できる **portable maintenance model** を作ることでもあり得る。

## Long-term direction

目標は、より多くの package を所有することではない。

巨大な一つの Rescue 組織を作ることでもない。

Rescue を **repeatable, distributed, transferable** なものにして、それぞれの community が共通する考え方や tool を使いながら、自分たちの ecosystem を保守できる状態を目指す。

software が、一人の maintainer の活動期間を越えて生きられること。

maintenance risk が emergency になる前に発見できること。

新しい maintainer が stewardship に参加できること。

責任を次の人へ渡せること。

AI が maintenance の必要な場所を見つけ、人間が判断と責任を担うこと。

つまり、

> **一つの ecosystem の package を救う活動から、OSS 全体で使える保守文化とインフラへ。**

CPAN Rescue は CPAN から始まる。

しかし、このビジョンは CPAN では終わらない。
