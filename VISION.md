# Long-term Vision for CPAN Rescue

CPAN Rescue is not only an effort to rescue a handful of old Perl modules.

In the long term, it can become part of the **maintenance infrastructure for open source software**: a way to continuously discover, understand, maintain, and hand forward the software that society already depends on.

## Maintenance infrastructure for open source

The open source world has excellent machinery for creating new software. But the question of who maintains software that has been used for years—and who takes responsibility when its original maintainer can no longer do so—still depends heavily on individual maintainers' time and goodwill.

Software that is widely depended upon deserves a more continuous model of maintenance.

The goal of CPAN Rescue does not have to be simply adopting abandoned distributions. It can make the maintenance process itself reusable:

- find software whose maintenance is weakening
- verify that it is still in use
- understand its downstream impact
- reproduce problems in current environments
- create small, safe fixes with regression tests
- work with upstream maintainers
- take on stewardship when necessary
- verify downstream behavior after a release
- leave the project in a state where responsibility can be handed to the next maintainer

This idea is not limited to CPAN. Long-lived package ecosystems such as PyPI, npm, RubyGems, crates.io, and Maven face versions of the same problem.

CPAN Rescue can be a small laboratory for learning how to solve it.

## AI finds candidates; humans take responsibility

In the future, humans should not need to inspect every distribution manually.

AI and automated scanners can continuously look for signs that a package may need maintenance attention, using public signals such as:

- reverse dependencies
- position in the CPAN River
- time since the last release
- maintainer and ownership status
- CPAN Testers failures
- testability on current Perl versions
- continued use in downstream distributions and OS packages
- repository activity

But the role of AI is not to silently fix packages and publish releases on its own.

> **AI finds candidates; humans take responsibility for maintenance.**

AI should act as radar.

It can point out that a distribution may be important, that there are signs of a regression, or that downstream impact deserves investigation.

Humans then:

- verify the evidence
- understand existing behavior
- make compatibility decisions
- communicate with upstream maintainers
- review patches
- take responsibility for releases

The purpose of automation is not to remove human responsibility.

It is to **help humans find, earlier and more accurately, the places where responsible maintenance is needed**.

## Rescue Radar

One concrete expression of this idea is a Rescue Radar.

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

The Radar should not be a simple ranking of "old packages."

Age alone is not a problem. Stable software may require no changes for many years.

What matters is combining evidence about **impact, maintenance risk, actual breakage, and continued use**.

The system should also explain why it detected a candidate.

An automated decision that humans cannot understand is a weak foundation for maintenance infrastructure.

## A successful rescue is almost invisible

The success of this work should not be measured only by the number of adoptions or commits.

Imagine a developer, years from now, upgrading an old system and installing one of its dependencies.

It simply works.

That developer may never know that the package had once been at maintenance risk.

They may never know that someone added a regression test, checked downstream users, took over stewardship, or made a careful release.

That is fine.

> **Open source should live long enough that nobody needs to notice it was rescued.**

That is what success looks like for maintenance infrastructure.

Like bridges or water systems, infrastructure is often least visible when it is working well.

Open source maintenance could become that kind of infrastructure too.

## What CPAN Rescue can explore

Because CPAN Rescue is small, it is a good place to experiment with this future.

Within CPAN, we can learn how to:

1. identify software that genuinely needs maintenance
2. develop practices for conservative maintenance
3. measure and understand downstream impact
4. give new maintainers a safe path to gain experience
5. make stewardship and handoff normal parts of an open source project's life
6. use AI and automation as radar rather than as the final decision-maker
7. make these practices reusable in other ecosystems

CPAN Rescue works on CPAN, but what we learn here can be larger than CPAN.

## Long-term direction

The goal is not to own more packages.

The goal is for more software to reach a state where:

- it does not depend indefinitely on the goodwill of a single person
- maintenance risks can be discovered before they become serious
- fixes are made conservatively with downstream impact understood
- new maintainers can participate
- responsibility can be handed forward when necessary

In other words:

> **From a project that rescues software to infrastructure that helps software live longer.**

CPAN Rescue can be a place to build that infrastructure on a small scale, and learn from real maintenance work as we go.
