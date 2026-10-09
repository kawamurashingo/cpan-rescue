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
