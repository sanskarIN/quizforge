# Phase 6 Verification Evidence

This document records evidence for the final release-candidate verification of QuizForge. It is intentionally evidence-driven: items are marked complete only after a corresponding command or GitHub Actions check has actually succeeded.

## Audit branch

- Branch: `audit/phase-6-verification-2026-08-19`
- Base commit at audit start: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Audit date: 2026-08-19
- Maintainer commit-email target for normal local Git commits: `sanskarin@outlook.in`

## Required automated gates

- [ ] Dependency installation succeeds.
- [ ] Flutter localization generation succeeds.
- [ ] Dart formatting check succeeds.
- [ ] Flutter analyzer succeeds with no errors.
- [ ] Unit/widget/integration tests succeed.
- [ ] Android build succeeds.
- [ ] Web build succeeds.
- [ ] Windows build succeeds on Windows runner.
- [ ] Linux build succeeds on Linux runner.
- [ ] macOS build succeeds on macOS runner.
- [ ] iOS no-codesign build succeeds on macOS runner.
- [ ] Dependency review succeeds for this PR.
- [ ] OSV dependency scan succeeds.
- [ ] Secret scan succeeds.

## Required manual/release-host checks

- [ ] Clean checkout setup follows `docs/setup.md` without undocumented steps.
- [ ] Generated platform runners are reproducible from documented commands.
- [ ] `pubspec.lock` is generated and reviewed in a supported Flutter environment before the release candidate is tagged.
- [ ] Drift persistence is exercised on Android and Web release/debug builds as applicable.
- [ ] Keyboard navigation and focus visibility are manually checked on desktop/web.
- [ ] Representative screen-reader checks are completed.
- [ ] Large-text and reduced-motion settings are manually reviewed.
- [ ] Real screenshots listed in `docs/screenshots/README.md` are captured from a verified build.

## Evidence log

| Date | Check | Result | Evidence |
| --- | --- | --- | --- |
| 2026-08-19 | Repository state inspected before Phase 6 audit | PASS | Base commit recorded above |
| 2026-08-19 | Fresh audit branch created from latest inspected `main` | PASS | `audit/phase-6-verification-2026-08-19` |

## Release decision rule

QuizForge must not be described as production/release verified until all blocker items above that are applicable to the claimed platform set have passed. Any failed automated gate must be fixed with a focused commit and regression coverage where appropriate, then re-run before the release candidate is created.
