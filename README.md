# CPAN Rescue

**CPAN Rescue grows maintainers by maintaining real software.**

Many useful CPAN distributions need maintenance. At the same time, becoming an open-source maintainer has a surprisingly high barrier to entry.

CPAN Rescue connects these two problems.

Contributors learn maintenance by working on real distributions: investigating current state, reproducing bugs, adding regression tests, improving CI and metadata, evaluating downstream impact, preparing releases, and eventually taking stewardship when appropriate.

The project still rescues abandoned and under-maintained Perl distributions, but adoption is not the primary goal.

**The goal is to create more maintainers.**

## How it works

CPAN Rescue uses real maintenance work as a path into stewardship.

A contributor does not need to adopt a distribution or make a long-term commitment in order to participate. Responsibility grows only when the contributor wants it and has enough context to take it on safely.

The proposed maintainer path is tracked in [#28](https://github.com/kawamurashingo/cpan-rescue/issues/28):

1. **Explorer** — investigate a candidate, reproduce a problem, or document the current state.
2. **Contributor** — add a regression test, focused bug fix, CI repair, or metadata improvement.
3. **Release Contributor** — help prepare and validate release artifacts, downstream tests, and post-release results.
4. **Co-maintainer** — share ongoing maintenance responsibility with an experienced maintainer.
5. **Maintainer / Steward** — independently maintain and release a distribution when appropriate.

This is a path, not a ranking. Stopping after any stage is a valid contribution.

## Why real maintenance?

Maintenance is a skill that is difficult to learn from toy projects.

A maintainer needs to learn how to:

- understand existing behavior before changing it;
- distinguish upstream failures from regressions;
- write focused regression tests;
- preserve compatibility;
- work with upstream authors and existing users;
- understand CPAN/PAUSE ownership and release mechanics;
- build and inspect the actual distribution artifact;
- assess downstream impact;
- use CPAN Testers and downstream testing as release feedback;
- make conservative decisions when many other distributions depend on the code;
- hand responsibility to another maintainer when circumstances change.

CPAN Rescue provides real distributions where those skills can be learned with review and bounded responsibility.

## Good first maintenance

The first contribution should be small enough to understand and finish without accepting ownership of a distribution.

Good first maintenance tasks may include:

- verifying the current CPAN release and source baseline;
- reproducing and documenting a known problem;
- adding regression coverage for existing behavior;
- repairing or adding conservative CI;
- inspecting generated metadata;
- testing a release tarball in a clean environment;
- running and classifying downstream tests.

The first set of contributor-friendly tasks is being developed in [#29](https://github.com/kawamurashingo/cpan-rescue/issues/29).

These are real maintenance tasks, not simulated exercises. Each should have a concrete outcome, a validation method, clear prerequisites, and a reviewer or mentoring path.

## Responsibility and handoff

Becoming a maintainer should not mean accepting an indefinite obligation.

CPAN Rescue treats maintenance as stewardship rather than permanent ownership. Contributors should be able to increase responsibility gradually, and maintainers should be able to hand responsibility to someone else cleanly.

Mentoring, responsibility boundaries, and handoff policy are being defined in [#30](https://github.com/kawamurashingo/cpan-rescue/issues/30).

For high-impact distributions, especially XS modules or distributions high in the CPAN River, mentoring and review should become more conservative as potential downstream impact increases.

## Impact

CPAN Rescue began by demonstrating that conservative rescue work can be carried through to real upstream and CPAN outcomes.

Current results:

- **1 upstream PR merged**
- **1 additional upstream PR awaiting review**
- **2 distributions adopted**
- **1 post-adoption maintenance release published to CPAN**
- **Devel::CallChecker 0.010 released under `SHINGO` after own-suite, metadata, signature, and downstream validation**
- **Devel::CallChecker stewardship covers a low-level XS compatibility module with a historical adoption snapshot of 13 direct and 81 direct-or-indirect CPAN dependents**
- Regression coverage added without unnecessary production-code changes

These results now serve a second purpose: the rescue workflow is becoming a practical curriculum that can be taught and handed to other maintainers.

## Active rescues

| Distribution | Status | Tracking | Upstream work |
| --- | --- | --- | --- |
| Dist::CheckConflicts | Waiting for upstream | [#1](https://github.com/kawamurashingo/cpan-rescue/issues/1) | [doy/dist-checkconflicts#13](https://github.com/doy/dist-checkconflicts/pull/13) remains open, awaiting upstream review |
| Log::Any::Adapter::Screen | Adopted | [#2](https://github.com/kawamurashingo/cpan-rescue/issues/2) | Regression-test [PR #4](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/pull/4) merged; [upstream issue #5](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/issues/5) is awaiting repository-maintenance guidance |
| Devel::CallChecker | Released | [#3](https://github.com/kawamurashingo/cpan-rescue/issues/3) | [kawamurashingo/Devel-CallChecker](https://github.com/kawamurashingo/Devel-CallChecker); 0.010 released 2026-09-19 |
| DBD::ODBC | Adoption requested / patch ready | [#25](https://github.com/kawamurashingo/cpan-rescue/issues/25) | MetaCPAN explicitly marks it up for adoption; `SHINGO` sent the adoption request. Modern Linux CI is restored and [DBD-ODBC PR #1](https://github.com/kawamurashingo/DBD-ODBC/pull/1) fixes the DBI 1.647+ DBIXS feature-gate regression with green coverage across Perl 5.38/5.40 and DBI 1.646/1.647/1.648/1.653. Next trigger: adoption/PAUSE response; then review permissions, upstream the focused patch, and prepare the smallest defensible release. |
| Dist::Zilla::Plugin::MetaProvides family | Candidate | [#27](https://github.com/kawamurashingo/cpan-rescue/issues/27) | Confirmed ADOPTME family; plan is core → Package → Class → FromFile, with downstream validation |

## First completed stewardship example

On 2026-09-15, CPAN Rescue reached its first two successful adoptions:

- **Log::Any::Adapter::Screen** — PERLANCAR agreed to transfer the first-come indexing permission to `SHINGO`.
- **Devel::CallChecker** — PAUSE admin Neil Bowers transferred the first-come indexing permission to `SHINGO` after reviewing a maintenance plan that explicitly accounts for its CPAN River position.

`Devel::CallChecker` is a low-level compatibility layer around Perl call-checker APIs used by XS code. At adoption time, PAUSE admin Neil Bowers identified 13 direct dependent distributions and 81 distributions relying on it directly or indirectly.

Before 0.010, direct dependents were exercised against the release candidate across representative Perl versions, with zero candidate regressions relative to the reviewed 0.009 baselines. Devel::CallChecker 0.010 was released on 2026-09-19 and successfully indexed by PAUSE.

This workflow — baseline reconstruction, conservative changes, artifact validation, downstream testing, release, and post-release review — is the kind of real stewardship experience CPAN Rescue aims to make teachable.

## What makes a good incubation distribution?

A useful distribution for maintainer incubation should have real maintenance value while allowing responsibility to be divided into understandable steps.

Good candidates typically have several of these characteristics:

- Existing downstream users or reverse dependencies
- Long periods without maintenance or an explicit `ADOPTME` status
- A stable, useful API worth preserving
- A focused bug, missing regression coverage, CI problem, or metadata issue
- Work that can be split into contributor-sized tasks
- A scope small enough to understand and test thoroughly
- Evidence of continued use, such as active downstream distributions or OS packages
- A CPAN River position whose downstream impact can be understood and tested responsibly
- A plausible path from supervised contribution to independent stewardship

Not every rescue candidate needs to become an adoption candidate, and not every contributor needs to become its maintainer.

## Maintenance workflow

The existing conservative maintenance workflow remains the technical foundation:

1. Identify a distribution with active downstream users and weak or missing maintenance.
2. Confirm the current CPAN release, source repository, reverse dependencies, and maintainer status.
3. Reproduce the problem and understand existing behavior before changing anything.
4. Prefer a small first contribution: regression test, focused bug fix, CI repair, or metadata cleanup.
5. Run the full test suite on a current Perl release and document the Perl version and test environment.
6. Assess CPAN River position and plan downstream testing proportional to potential impact.
7. Submit an upstream PR, or request adoption when the distribution is explicitly available for adoption and someone is ready for stewardship.
8. Before releases, test direct dependents when practical; use developer releases for significant or compatibility-sensitive changes.
9. After releases, review CPAN Testers results and investigate regressions before proceeding further.
10. Document enough of the work that another maintainer can understand and eventually inherit it.

## Maintenance and mentoring principles

- Preserve existing APIs and behavior unless a change is clearly justified.
- Prefer small, reviewable patches over broad rewrites.
- Add regression tests for behavioral fixes.
- Distinguish existing upstream failures from regressions introduced by a patch.
- Keep temporary investigation and CI experiments out of upstream PRs.
- Document what was tested and on which Perl version.
- Treat adoption as an ongoing maintenance responsibility, not a badge.
- Do not use adoption count as a success metric.
- Avoid adopting more distributions than available maintainers can responsibly support.
- Give contributors meaningful work before asking for ownership.
- Make responsibility explicit and bounded.
- Treat mentoring and review as part of maintenance work.
- Make handoff a normal part of stewardship.
- Treat CPAN River position as part of release risk.
- For high-impact distributions, test direct dependents against proposed releases and use developer releases for significant changes.
- Review CPAN Testers results after releases and investigate downstream regressions promptly.

## Rescue dashboard

The Active rescues table remains the canonical distribution dashboard. Each tracking issue should keep a `**Status:**` line near the top and record ownership/adoption state, upstream links, testing evidence, downstream impact, release details, and the next concrete action.

The rescue dashboard answers **what needs maintenance**.

The maintainer path answers **who can learn to maintain it, and what responsibility they are ready to take next**.

## Measuring success

CPAN Rescue will continue to record technical outcomes such as:

- upstream PRs merged;
- distributions adopted;
- maintenance releases published;
- bugs and regressions fixed;
- reverse dependencies benefiting from maintained distributions;
- downstream compatibility results.

But the primary long-term question is now:

**Are more people becoming capable, confident maintainers?**

As the incubation model develops, the project should also track:

- contributors completing real maintenance tasks;
- contributors participating in release validation;
- co-maintainers joining distributions;
- new maintainers making independent releases;
- stewardship successfully handed from one maintainer to another.

These should describe experience and responsibility, not create a contributor leaderboard.

## Current project-development priorities

1. [#28 — Define the CPAN Rescue maintainer path](https://github.com/kawamurashingo/cpan-rescue/issues/28)
2. [#29 — Create the first good-first-maintenance tasks](https://github.com/kawamurashingo/cpan-rescue/issues/29)
3. [#30 — Document mentoring, responsibility, and maintainer handoff policy](https://github.com/kawamurashingo/cpan-rescue/issues/30)
4. Continue existing rescue work conservatively while using it to validate the incubation model.
5. Turn the proven maintenance-release workflow into reusable contributor documentation.

## Goal

**Make maintaining CPAN worth doing — and make becoming a maintainer achievable.**
