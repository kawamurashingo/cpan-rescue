# CPAN Rescue

CPAN Rescue is a practical effort to help maintain important Perl distributions that are abandoned, under-maintained, or missing modern maintenance infrastructure.

The project focuses on conservative maintenance: fixing real bugs, adding regression tests, preserving compatibility, improving CI and metadata, and adopting distributions when appropriate.

The goal is not to rewrite mature modules. It is to keep useful pieces of the Perl ecosystem working reliably.

## Impact

CPAN Rescue is still young. Current results:

- **1 upstream PR merged**
- **1 additional upstream PR awaiting review**
- **1 distribution adoption request in progress**
- Regression coverage added without unnecessary production-code changes

Impact numbers will grow as tracked work reaches upstream merge, adoption, and CPAN release.

## Active rescues

| Distribution | Status | Tracking | Upstream work |
| --- | --- | --- | --- |
| Dist::CheckConflicts | Waiting for upstream | [#1](https://github.com/kawamurashingo/cpan-rescue/issues/1) | [doy/dist-checkconflicts#13](https://github.com/doy/dist-checkconflicts/pull/13) |
| Log::Any::Adapter::Screen | Merged upstream | [#2](https://github.com/kawamurashingo/cpan-rescue/issues/2) | [perlancar/perl-Log-Any-Adapter-Screen#4](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/pull/4) |
| Devel::CallChecker | Adoption requested | [#3](https://github.com/kawamurashingo/cpan-rescue/issues/3) | PAUSE adoption request sent to `modules@perl.org` |

### First upstream success

The regression-test contribution for **Log::Any::Adapter::Screen** was merged upstream on 2026-08-21.

The change adds coverage for `log_level`, `min_level`, precedence behavior, the default warning level, and level-detection methods. No production code was changed.

This distribution remains tracked until the merged work is included in a CPAN release.

## What makes a good rescue candidate?

Priority goes to distributions where maintenance can have useful downstream impact without introducing unnecessary risk.

Good candidates typically have several of these characteristics:

- Existing downstream users or reverse dependencies
- Long periods without maintenance or an explicit `ADOPTME` status
- A stable, useful API worth preserving
- A focused bug, missing regression coverage, CI problem, or metadata issue
- A scope small enough to understand and test thoroughly
- Evidence of continued use, such as active downstream distributions or OS packages

The aim is quality and downstream value, not the number of distributions adopted.

## Workflow

1. Identify a distribution with active downstream users and weak or missing maintenance.
2. Confirm the current CPAN release, source repository, reverse dependencies, and maintainer status.
3. Reproduce the problem and understand existing behavior before changing anything.
4. Prefer a small first contribution: regression test, focused bug fix, CI repair, or metadata cleanup.
5. Run the full test suite on a current Perl release and document the environment.
6. Submit an upstream PR, or request adoption when the distribution is explicitly available for adoption.
7. Follow the work through merge, CPAN release, and downstream verification where practical.

## Maintenance principles

- Preserve existing APIs and behavior unless a change is clearly justified.
- Prefer small, reviewable patches over broad rewrites.
- Add regression tests for behavioral fixes.
- Distinguish existing upstream failures from regressions introduced by a patch.
- Keep temporary investigation and CI experiments out of upstream PRs.
- Document what was tested and on which Perl version.
- Treat adoption as an ongoing maintenance responsibility, not a badge.
- Avoid adopting more distributions than can be maintained responsibly.

## Status vocabulary

- **Candidate** — worth investigating
- **In progress** — actively being researched or patched
- **Waiting for upstream** — PR submitted and awaiting review
- **Merged upstream** — upstream PR merged; waiting for a CPAN release
- **Adoption requested** — PAUSE/maintainer adoption process in progress
- **Adopted** — maintenance permissions obtained
- **Released** — maintenance work shipped to CPAN

The canonical status is the `**Status:**` line at the top of each tracking issue and the table above.

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
