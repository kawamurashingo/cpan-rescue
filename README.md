# CPAN Rescue

CPAN Rescue is a practical effort to help maintain important Perl distributions that are abandoned, under-maintained, or missing modern maintenance infrastructure.

The project focuses on conservative maintenance: fixing real bugs, adding regression tests, preserving compatibility, improving CI and metadata, and adopting distributions when appropriate.

The goal is not to rewrite mature modules. It is to keep useful pieces of the Perl ecosystem working reliably.

## Impact

CPAN Rescue is still young. Current results:

- **1 upstream PR merged**
- **1 additional upstream PR awaiting review**
- **2 distributions adopted**
- **1 post-adoption maintenance release published to CPAN**
- **Devel::CallChecker 0.010 released under `SHINGO` after own-suite, metadata, signature, and downstream validation**
- **Devel::CallChecker stewardship covers a low-level XS compatibility module with a historical adoption snapshot of 13 direct and 81 direct-or-indirect CPAN dependents**
- Regression coverage added without unnecessary production-code changes

The impact is intentionally measured in maintained downstream reliability rather than adoption count alone. For infrastructure distributions, CPAN River position and compatibility risk are part of the result.

## Active rescues

| Distribution | Status | Tracking | Upstream work |
| --- | --- | --- | --- |
| Dist::CheckConflicts | Waiting for upstream | [#1](https://github.com/kawamurashingo/cpan-rescue/issues/1) | [doy/dist-checkconflicts#13](https://github.com/doy/dist-checkconflicts/pull/13) |
| Log::Any::Adapter::Screen | Adopted | [#2](https://github.com/kawamurashingo/cpan-rescue/issues/2) | [perlancar/perl-Log-Any-Adapter-Screen#4](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/pull/4); first-come permission transferred to `SHINGO` |
| Devel::CallChecker | Released | [#3](https://github.com/kawamurashingo/cpan-rescue/issues/3) | 0.010 released 2026-09-19; first post-adoption maintenance release |

### First upstream success

The regression-test contribution for **Log::Any::Adapter::Screen** was merged upstream on 2026-08-21.

The change adds coverage for `log_level`, `min_level`, precedence behavior, the default warning level, and level-detection methods. No production code was changed.

The distribution has now been adopted, with first-come indexing permission transferred to PAUSE ID `SHINGO`. The next step is to verify the current distribution state and prepare a conservative maintenance release.

### First adoptions

On 2026-09-15, CPAN Rescue reached its first two successful adoptions:

- **Log::Any::Adapter::Screen** — PERLANCAR agreed to transfer the first-come indexing permission to `SHINGO`.
- **Devel::CallChecker** — PAUSE admin Neil Bowers transferred the first-come indexing permission to `SHINGO` after reviewing a maintenance plan that explicitly accounts for its CPAN River position.

`Devel::CallChecker` is a low-level compatibility layer around Perl call-checker APIs used by XS code. At adoption time, PAUSE admin Neil Bowers identified 13 direct dependent distributions and 81 distributions relying on it directly or indirectly. This makes the maintenance work infrastructure stewardship rather than feature development: a regression can propagate well beyond users who knowingly install `Devel::CallChecker`.

For that reason, its release process treats downstream compatibility as a release requirement. Before 0.010, direct dependents were exercised against the release candidate across representative Perl versions, with zero candidate regressions relative to the reviewed 0.009 baselines. Devel::CallChecker 0.010 was released on 2026-09-19 and successfully indexed by PAUSE. CPAN Testers results will be reviewed for regressions before further production changes. The objective is to keep a mature piece of Perl infrastructure boring, compatible, and available to the software above it.

## What makes a good rescue candidate?

Priority goes to distributions where maintenance can have useful downstream impact without introducing unnecessary risk.

Good candidates typically have several of these characteristics:

- Existing downstream users or reverse dependencies
- Long periods without maintenance or an explicit `ADOPTME` status
- A stable, useful API worth preserving
- A focused bug, missing regression coverage, CI problem, or metadata issue
- A scope small enough to understand and test thoroughly
- Evidence of continued use, such as active downstream distributions or OS packages
- A CPAN River position whose downstream impact can be understood and tested responsibly

The aim is quality and downstream value, not the number of distributions adopted.

## Workflow

1. Identify a distribution with active downstream users and weak or missing maintenance.
2. Confirm the current CPAN release, source repository, reverse dependencies, and maintainer status.
3. Reproduce the problem and understand existing behavior before changing anything.
4. Prefer a small first contribution: regression test, focused bug fix, CI repair, or metadata cleanup.
5. Run the full test suite on a current Perl release and document the environment.
6. Assess CPAN River position: identify direct and indirect dependents and plan downstream testing proportional to the potential impact.
7. Submit an upstream PR, or request adoption when the distribution is explicitly available for adoption.
8. Before releases, test direct dependents when practical; use developer releases for significant or compatibility-sensitive changes.
9. After releases, review CPAN Testers results and investigate regressions before proceeding further.
10. Follow the work through merge, CPAN release, and downstream verification where practical.

## Maintenance principles

- Preserve existing APIs and behavior unless a change is clearly justified.
- Prefer small, reviewable patches over broad rewrites.
- Add regression tests for behavioral fixes.
- Distinguish existing upstream failures from regressions introduced by a patch.
- Keep temporary investigation and CI experiments out of upstream PRs.
- Document what was tested and on which Perl version.
- Treat adoption as an ongoing maintenance responsibility, not a badge.
- Avoid adopting more distributions than can be maintained responsibly.
- Treat CPAN River position as part of release risk: the more downstream distributions rely on a module, the more conservative the release process should be.
- For high-impact distributions, test direct dependents against proposed releases and use developer releases for significant changes.
- Review CPAN Testers results after releases and investigate downstream regressions promptly.

## Status vocabulary

- **Candidate** — worth investigating
- **In progress** — actively being researched or patched
- **Waiting for upstream** — PR submitted and awaiting review
- **Merged upstream** — upstream PR merged; waiting for a CPAN release
- **Adoption requested** — PAUSE/maintainer adoption process in progress
- **Adopted** — maintenance permissions obtained
- **Released** — maintenance work shipped to CPAN

The canonical status is the `**Status:**` line at the top of each tracking issue and the table above. For completed rescues, the tracking issue also records release/indexing details and post-release follow-up.

## Measuring impact

As the project grows, CPAN Rescue will track outcomes such as:

- Upstream PRs merged
- Distributions adopted
- Maintenance releases published to CPAN
- Bugs and regressions fixed
- Reverse dependencies benefiting from maintained distributions
- Downstream packaging and compatibility where relevant

These metrics are intended to show maintenance impact rather than activity for its own sake.

## Labels

Repository-default labels are currently used for work type:

- `bug` — behavioral bug fixes
- `enhancement` — tests, maintenance improvements, adoption, CI, or metadata work

Status is kept separately from work type so a task can move from Candidate to Released without changing what kind of work it is.

## Goal

Make CPAN a little easier to trust and maintain, one distribution at a time.
