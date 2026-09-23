# Mentoring, responsibility, and handoff

CPAN Rescue treats maintenance as stewardship, not permanent ownership. Responsibility should grow deliberately, and stepping back should be a normal supported outcome.

## Responsibility levels

### Explorer
May investigate, reproduce failures, compare releases/source, and record evidence. No release authority or production-behavior changes are implied.

Evidence: reproducible commands, environment details, findings, and a clear next step.

### Contributor
May propose focused tests, CI, metadata, documentation, or bug fixes. Production-behavior changes require review and a demonstrated problem.

Evidence: a reviewable issue/PR, regression evidence where relevant, and test results.

### Release Contributor
May prepare and validate release candidates, generated metadata, tarballs, downstream tests, and post-release evidence. This role does not imply PAUSE upload authority.

Evidence: exact source/artifact identity, build/test environment, checks performed, and results.

### Co-maintainer
Shares ongoing triage and maintenance with an established maintainer. Repository/PAUSE permissions should match the work actually being delegated.

Evidence: reviewed maintenance decisions across more than one task, clear communication, and demonstrated conservative judgment.

### Maintainer / Steward
May independently make maintenance and release decisions for distributions where appropriate permissions and project context have been established. Stewardship includes making handoff possible.

## Review expectations

Work can be independent when it is observational or easily reversible: baseline investigation, reproductions, documentation, CI experiments on a branch, and test-only changes.

Maintainer review is required before merging production-behavior changes, changing compatibility promises, changing canonical repository/release metadata, or publishing a release.

Use stronger review for XS code, security-sensitive boundaries, high CPAN River impact, broad API/behavior changes, or uncertain downstream effects. In those cases prefer focused regression evidence, representative downstream testing, and developer releases when appropriate.

A contributor should never need release credentials merely to validate a release artifact.

## Mentoring

A task should state its expected outcome, prerequisites, validation method, responsibility boundary, and where to ask questions. Questions and documentation gaps are useful maintenance evidence, not contributor failure.

Mentors/reviewers should explain decisions that depend on project history or release knowledge that is not obvious from the repository. Review should focus on safety and reproducibility rather than stylistic gatekeeping.

## Maintenance record

For contributor/incubation tasks, record enough public evidence to make the work portable:

- contributor and distribution;
- maintainer-path stage and task scope;
- issue/PR/commit or other evidence;
- relevant environments and tools;
- maintenance skills demonstrated;
- reviewer/mentor;
- explicit responsibility boundary;
- coarse contributor and reviewer effort ranges when useful.

Do not turn this record into points, certification, speed comparisons, or a leaderboard.

## Handoff / offboarding checklist

A maintainer who wants to step back should, where applicable:

1. Record the current release, source branch, known regressions, open release work, and important downstream risks.
2. Make the canonical repository and issue tracker unambiguous.
3. Document the release procedure sufficiently for another maintainer to reproduce it.
4. Identify outstanding issues/PRs and distinguish urgent work from optional modernization.
5. Coordinate repository collaborator/ownership changes.
6. Coordinate PAUSE first-come/co-maint permissions through the appropriate process.
7. Transfer or document CI/release dependencies and any non-secret configuration requirements.
8. Ensure secrets and personal credentials are not copied into project documentation or handed over informally.
9. Introduce the incoming maintainer to relevant upstream/downstream contacts when useful.
10. Record the handoff publicly and state who is responsible after the transition.

If no successor is available, document the maintenance state and seek co-maintenance/adoption rather than silently disappearing where practical.

## Principle

No contributor is obligated to advance to the next stage. No maintainer is obligated to remain indefinitely. A healthy stewardship model makes both entry and exit explicit, reviewable, and unsurprising.
