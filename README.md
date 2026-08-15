# CPAN Rescue

CPAN Rescue is a small, practical effort to help maintain important Perl distributions that are abandoned, under-maintained, or missing modern maintenance infrastructure.

The focus is conservative maintenance: fix real bugs, add regression tests, keep compatibility with current Perl releases, improve CI and metadata, and adopt distributions when appropriate.

## Current work

| Distribution | Status | Upstream work |
| --- | --- | --- |
| Dist::CheckConflicts | Waiting for upstream review | https://github.com/doy/dist-checkconflicts/pull/13 |
| Log::Any::Adapter::Screen | Waiting for upstream review | https://github.com/perlancar/perl-Log-Any-Adapter-Screen/pull/4 |
| Devel::CallChecker | Adoption requested | PAUSE adoption request sent to modules@perl.org |

## Workflow

1. Find a distribution with active downstream users and weak or missing maintenance.
2. Confirm the current CPAN release, source repository, reverse dependencies, and maintainer status.
3. Prefer a small first contribution: regression test, focused bug fix, CI repair, or metadata cleanup.
4. Run the full test suite on a current Perl release before proposing changes.
5. Submit an upstream PR, or request adoption when the distribution is explicitly available for adoption.
6. Track follow-up work here until the change is merged or a maintenance release is published.

## Principles

- Preserve existing APIs unless a change is clearly justified.
- Prefer small, reviewable patches.
- Add tests for every behavioral fix.
- Distinguish existing upstream failures from regressions introduced by a patch.
- Keep temporary CI or investigation changes out of upstream PRs.
- Document what was tested and on which Perl version.

## Status vocabulary

- **Candidate** — worth investigating
- **In progress** — actively being researched or patched
- **Waiting for upstream** — PR submitted and awaiting review
- **Adoption requested** — PAUSE/maintainer adoption process in progress
- **Adopted** — maintenance permissions obtained
- **Released** — maintenance work shipped to CPAN

## Goal

Make CPAN a little easier to trust and maintain, one distribution at a time.
