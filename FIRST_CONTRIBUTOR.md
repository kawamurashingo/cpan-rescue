# Your first CPAN Rescue contribution

**English** | [日本語](FIRST_CONTRIBUTOR.ja.md)

CPAN Rescue grows maintainers by maintaining real software.

This page is the shortest path for someone who wants to try real CPAN maintenance without committing to becoming a CPAN maintainer.

## Who this is for

You are a good fit if you:

- can run Perl from a terminal;
- know the basics of Git and GitHub;
- are curious about how CPAN distributions are maintained; and
- do **not** need to have released anything to CPAN before.

You do not need a PAUSE account. You do not need to adopt a distribution. You do not need to promise to keep contributing.

## Start here

For the smallest first step, take:

**[#37 — Good First Rescue: verify Log::Any::Adapter::Screen on modern Perl](https://github.com/kawamurashingo/cpan-rescue/issues/37)**

Expected time: about **30–60 minutes**.

The task is deliberately small:

1. Check out the upstream distribution.
2. Run its test suite on a modern Perl.
3. Record the OS, Perl version, command, and PASS/FAIL result in the issue.

A pull request is not required. A CPAN release is not required. The useful outcome is the maintenance evidence you leave in the issue.

To claim it, comment on #37 that you would like to try it. Questions are welcome; review and mentoring are part of the task.

## What happens after that?

If you enjoyed the first task, you can stop there or try a larger piece of maintenance work:

- [#33 — Reconstruct the Log::Any::Adapter::Screen 0.141 release baseline](https://github.com/kawamurashingo/cpan-rescue/issues/33) — Explorer, about 1–3 hours.
- [#34 — Establish a conservative Perl CI matrix](https://github.com/kawamurashingo/cpan-rescue/issues/34) — Contributor, about 1–3 hours if you are comfortable with GitHub Actions.
- [#39 — Inspect one CPAN Rescue candidate for modern testability](https://github.com/kawamurashingo/cpan-rescue/issues/39) — Explorer, about 1–2 hours.

There is no required progression. The maintainer path exists to make increasing responsibility possible, not mandatory.

## What you will learn

The first tasks are meant to expose real maintenance work in small pieces: establishing a trustworthy baseline, recording reproducible evidence, distinguishing environment problems from distribution problems, reviewing changes conservatively, and communicating findings so another maintainer can act on them.

These are real distributions and real maintenance decisions. They are not simulated exercises.

## What CPAN Rescue promises you

- A bounded task with a concrete outcome.
- Clear responsibility boundaries.
- No PAUSE or release credentials for beginner tasks.
- Review and mentoring.
- Questions are expected.
- No obligation to adopt a module or become a long-term maintainer.
- Credit for useful maintenance work.

If something in the instructions is confusing, that is useful feedback too. Please say so in the issue instead of assuming you are supposed to figure everything out alone.

## The maintainer path

If you decide to continue, the broader path is:

**Explorer → Contributor → Release Contributor → Co-maintainer → Maintainer / Steward**

You can stop at any stage. Moving forward should happen because you want more responsibility and have demonstrated the previous skills, not because the project needs free labor.

The overall maintainer-incubation experiment is tracked in [#36](https://github.com/kawamurashingo/cpan-rescue/issues/36).

## Ready?

Open [#37](https://github.com/kawamurashingo/cpan-rescue/issues/37), comment that you would like to try it, and start with the environment you already have.

Welcome to CPAN maintenance.
