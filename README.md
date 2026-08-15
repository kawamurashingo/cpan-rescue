# CPAN Rescue

CPAN Rescue is a small, practical effort to help maintain important Perl distributions that are abandoned, under-maintained, or missing modern maintenance infrastructure.

The focus is conservative maintenance: fix real bugs, add regression tests, keep compatibility with current Perl releases, improve CI and metadata, and adopt distributions when appropriate.

## Status board

| Distribution | Status | Tracking | Upstream work |
| --- | --- | --- | --- |
| Dist::CheckConflicts | Waiting for upstream | [#1](https://github.com/kawamurashingo/cpan-rescue/issues/1) | [doy/dist-checkconflicts#13](https://github.com/doy/dist-checkconflicts/pull/13) |
| Log::Any::Adapter::Screen | Waiting for upstream | [#2](https://github.com/kawamurashingo/cpan-rescue/issues/2) | [perlancar/perl-Log-Any-Adapter-Screen#4](https://github.com/perlancar/perl-Log-Any-Adapter-Screen/pull/4) |
| Devel::CallChecker | Adoption requested | [#3](https://github.com/kawamurashingo/cpan-rescue/issues/3) | PAUSE adoption request sent to `modules@perl.org` |

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

Until custom workflow labels or a GitHub Project are added, the canonical status is the `**Status:**` line at the top of each tracking issue and the table above.

## Labels

Repository-default labels are currently used for work type:

- `bug` — behavioral bug fixes
- `enhancement` — tests, maintenance improvements, adoption, CI, or metadata work

Status is kept separately from work type so a task can move from Candidate to Released without changing what kind of work it is.

## Goal

Make CPAN a little easier to trust and maintain, one distribution at a time.
