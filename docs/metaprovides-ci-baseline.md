# MetaProvides CI baseline — observed results (2026-10-04)

Source: [GitHub Actions run #15](https://github.com/kawamurashingo/cpan-rescue/actions/runs/37166747298) for [PR #50](https://github.com/kawamurashingo/cpan-rescue/pull/50), commit `e2467a895b52b0607d7cbc3186f2fba6c46cc986`.

The workflow **failed overall**: 14 of 19 jobs succeeded and 5 failed. This is a record of observed CI results, not a claim that the entire matrix is green.

| Scope | Passed | Failed | Notes |
| --- | ---: | ---: | --- |
| CPAN release baseline (Perl 5.40, 5.42) | 2 | 0 | Exact released artifact tests succeeded |
| Downstream candidate | 6 | 0 | Candidate checks succeeded |
| Downstream baseline | 6 | 4 | GETTY and RSRCHBOY failed on both Perl versions |
| Historical maintenance build | 0 | 1 | `dzil build` exited 2; investigate under #49 |

## Failure triage

- **Author::GETTY (5.40 and 5.42):** dependency installation failed. One observed cause was failing `API::Docker` tests, leaving `Dist::Zilla::Plugin::Docker::API` and other plugins unavailable.
- **RSRCHBOY (5.40 and 5.42):** dependency installation failed; `MetaCPAN::Client` tests failed and several Dist::Zilla plugin dependencies remained unavailable.
- **Modern maintenance build:** the `Attempt historical flattened dist.ini build` step failed with exit code 2. Further diagnosis belongs in [#49](https://github.com/kawamurashingo/cpan-rescue/issues/49).

These failures do **not by themselves** demonstrate a regression in the MetaProvides distribution. They also must not be silently treated as passing checks.

## Scope decision

Keep the published-release baseline and downstream compatibility experiments visible in CI. Track the historical `dzil build` modernization independently in #49, rather than making the baseline workflow depend on an unfinished author-tooling migration.

The GETTY/RSRCHBOY failures remain failing checks until their dependency problems are resolved or their role in the CI matrix is explicitly reconsidered. Do not mark them successful with `continue-on-error` merely to turn the workflow green.

## CI policy after issue #54 triage

The required pull-request baseline matrix covers the three downstream bundles with successful baseline and candidate runs: `Author::ETHER`, `DROLSKY`, and `Starter` (Perl 5.40 and 5.42). The two historically failing bundles (`Author::GETTY` and `RSRCHBOY`) are **not silently ignored**: they are retained in `.github/workflows/metaprovides-historical-downstream.yml` as an explicitly named, manually dispatched informational workflow. Its jobs still fail normally when dependency installation fails. Trigger it from GitHub Actions when revisiting compatibility; record outcomes in #54. This separation does not mean GETTY or RSRCHBOY compatibility is proven.

## Follow-up triage — 2026-10-18 (historical run #17)

[GitHub Actions run #17](https://github.com/kawamurashingo/cpan-rescue/actions/runs/38003548422) on 2026-10-09 completed **14 passed / 4 failed** among 18 jobs. The exact CPAN release tests (Perl 5.40, 5.42), all six candidate jobs, and the six ETHER/DROLSKY/Starter baseline jobs passed. The four failures were GETTY and RSRCHBOY *baseline dependency installation* on both Perl versions, not execution of MetaProvides-specific regression tests.

| Historical bundle | Perl 5.40: observed dependency failure | Perl 5.42: observed dependency failure |
| --- | --- | --- |
| Author::GETTY | `API::Docker` failed its own tests, leaving `Dist::Zilla::Plugin::Docker::API` unavailable ([job](https://github.com/kawamurashingo/cpan-rescue/actions/runs/38003548422/job/114067016248)). | `API::Docker 0.004` failed tests (including `t/dist_source.t`, 231/233 failed), blocking Docker::API; separately `MetaCPAN::Client` failed and `Dist::Zilla::Plugin::GitHub::CreateRelease` could not install ([job](https://github.com/kawamurashingo/cpan-rescue/actions/runs/38003548422/job/114067016315)). |
| RSRCHBOY | `MetaCPAN::Client` test failure was observed; `Twitter`, `SchwartzRatio`, `ContributorsFromGit` remained uninstalled ([job](https://github.com/kawamurashingo/cpan-rescue/actions/runs/38003548422/job/114067016254)). | `MetaCPAN::Client 2.044000` failed live API-dependent tests (including `t/api/author.t`); `SurgicalPkgVersion`, `Twitter`, `SchwartzRatio`, `ContributorsFromGit` remained uninstalled ([job](https://github.com/kawamurashingo/cpan-rescue/actions/runs/38003548422/job/114067016138)). |

Do **not** interpret the missing-plugin lists as proof each plugin is itself broken: `cpanm` also skips or aborts transitive dependency paths after earlier failures. In particular, the `MetaCPAN::Client` failure includes assertions dependent on current remote API data, and `API::Docker` fails tests within its own distribution. The logs do not establish whether those historical plugin bundles would work after their author/release-tool dependencies are repaired.

**Disposition for #54:** keep the current, already-merged separation rather than bypassing dependency tests. `metaprovides-baseline.yml` requires the three validated bundles; `metaprovides-historical-downstream.yml` is a separately dispatched informational check that retains real failed job conclusions. No blanket `--notest`, no `continue-on-error`, and no runtime/module changes were introduced by this documentation update. Re-run the informational workflow after an upstream dependency fix or a deliberate targeted test-only workaround, and record a new run rather than claiming compatibility now.
