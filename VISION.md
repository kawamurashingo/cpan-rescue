# Beyond CPAN: A Vision for Open Source Rescue

CPAN Rescue begins with CPAN, but the problem it addresses is not specific to Perl.

Every mature package ecosystem eventually accumulates software that is still depended upon but no longer receives the maintenance attention it once did. This happens in CPAN, PyPI, npm, RubyGems, crates.io, Maven, and elsewhere.

The long-term idea is therefore larger than rescuing Perl modules:

> **Build maintenance infrastructure that helps open source software live longer, across ecosystems.**

CPAN is where we can develop and test the practice. It is not where the idea has to end.

## The problem is ecosystem-wide

Open source has excellent machinery for creating and distributing new software. It has much less infrastructure for answering another question:

**What happens to important software after its original burst of development is over?**

A package may be mature rather than abandoned. Its maintainer may simply have less time. It may work perfectly until a language runtime, compiler, operating system, dependency, or security expectation changes.

Meanwhile, other software can continue depending on it for years.

This is not a CPAN-specific lifecycle. It is a property of long-lived open source ecosystems.

What we need is a repeatable way to:

- discover software whose maintenance is weakening
- verify that it is still used
- understand downstream impact
- distinguish stable old software from software that actually needs attention
- reproduce real problems in current environments
- create small, conservative fixes with regression tests
- work with existing upstream maintainers
- take on stewardship when necessary
- verify downstream behavior after releases
- make future handoff possible

The reusable process is more important than ownership of any particular package.

## CPAN Rescue as a laboratory

CPAN Rescue is the first implementation of this idea.

CPAN gives us a real ecosystem, real dependency relationships, real aging distributions, real maintainers, and real downstream users. That makes it a useful place to learn what responsible rescue actually requires.

The aim is to discover practices that can eventually be translated into other ecosystems.

For example:

```text
             Open Source Rescue
                    |
       +------------+------------+
       |            |            |
      CPAN         PyPI         npm       ...
       |            |            |
       +------------+------------+
                    |
          shared maintenance ideas
                    |
       discovery / evidence / review
       stewardship / handoff / verification
```

The tools and terminology will differ between ecosystems. The underlying maintenance problem often will not.

## AI finds candidates; humans take responsibility

At ecosystem scale, humans cannot inspect every package continuously.

AI and automated scanners can act as **maintenance radar**, using signals appropriate to each ecosystem:

- reverse dependencies and dependency graphs
- package ecosystem impact
- time since meaningful maintenance activity
- maintainer or ownership status
- CI and ecosystem test failures
- compatibility with current runtimes
- continued downstream usage
- operating-system packaging
- repository activity
- known regressions or breakage reports

The exact signals are ecosystem-specific. The principle is not.

> **AI finds candidates; humans take responsibility for maintenance.**

AI should identify places worth investigating and explain the evidence behind them.

It should not become an unquestioned autonomous maintainer.

Humans remain responsible for understanding behavior, judging compatibility, communicating with upstream, reviewing patches, deciding whether stewardship is appropriate, and taking responsibility for releases.

Automation does not remove responsibility.

It helps humans find where responsible maintenance is needed.

## Rescue Radar

A general Rescue Radar could observe multiple ecosystems:

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

A Radar should not simply rank packages by age.

Old software is not necessarily broken software. Mature software can remain unchanged for years precisely because it works.

Useful detection combines evidence about:

**impact + maintenance risk + actual breakage + continued use**

And every candidate should come with an explanation of *why* it was surfaced.

Explainability matters because Rescue Radar is meant to support human judgment, not replace it.

## A successful rescue is almost invisible

The success of this work should not be measured only by adoptions, commits, pull requests, or releases.

Imagine a developer years from now upgrading a system. Somewhere deep in its dependency tree is a package whose original maintainer moved on long ago.

The developer installs the dependencies.

Everything works.

They never need to know that somebody noticed a regression years earlier, wrote a test, contacted upstream, repaired compatibility, verified downstream users, or handed stewardship to another maintainer.

That is success.

> **Open source should live long enough that nobody needs to notice it was rescued.**

Healthy infrastructure is often invisible when it works.

Open source maintenance can become that kind of infrastructure.

## What we can learn from CPAN

CPAN Rescue can start small while asking questions that apply much more broadly:

1. How do we identify software that genuinely needs maintenance?
2. How do we distinguish abandonment from mature stability?
3. How do we measure downstream impact?
4. What does conservative maintenance look like?
5. How can new maintainers safely gain experience?
6. How should stewardship and handoff work?
7. Where can AI help without replacing human responsibility?
8. Which signals and practices transfer between package ecosystems?

The answers do not have to remain Perl-specific.

A useful outcome of CPAN Rescue would be not only healthier CPAN distributions, but a **portable maintenance model** that other communities can adapt to their own ecosystems.

## Long-term direction

The goal is not to accumulate ownership of packages.

The goal is not even to build one enormous rescue organization.

The goal is to make rescue **repeatable, distributed, and transferable** so that communities can maintain their own ecosystems using shared ideas and tools.

Software should be able to outlive the availability of any one maintainer.

Maintenance risks should be discoverable before they become emergencies.

New maintainers should have paths into stewardship.

Responsibility should be transferable.

AI should help us see the maintenance work that needs attention, while humans remain accountable for the decisions.

In other words:

> **From rescuing packages in one ecosystem to building a maintenance culture and infrastructure that can work across open source.**

CPAN Rescue starts with CPAN.

The vision does not stop there.
