# Phase 6 Verification Evidence

This document records evidence for the final release-candidate verification of QuizForge. It is intentionally evidence-driven: items are marked complete only after a corresponding command, GitHub Actions check, or documented manual review has actually succeeded.

## Audit identity

- Branch: `audit/phase-6-verification-2026-08-19`
- Pull request: `#9` — `ci: complete Phase 6 hardening and release-candidate audit`
- Base commit at audit start: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Audit date: 2026-08-19
- Maintainer commit-email target: `sanskarin@outlook.in`
- Release-candidate status: **BLOCKED — verification is not complete**

## Code/configuration audit completed in this phase

- [x] Localization message identifiers were audited and Dart-keyword collisions removed.
- [x] Primary quiz, creator, question-bank, import/export, statistics, and settings UI were moved to externalized English localization resources.
- [x] Large-text behavior was corrected so the app does not reduce a larger OS text scale.
- [x] Review bookmark state refresh behavior was corrected.
- [x] Settings updates now mutate in-memory state only after persistence succeeds.
- [x] Active-profile selection now loads target data and persists the target preference before mutating visible controller state.
- [x] Profile creation/deletion now use rollback-aware persistence ordering and preserve original stack traces when failures are rethrown.
- [x] Controller regression tests cover failed settings saves, failed profile switching, failed profile creation activation, and failed active-profile deletion preference persistence.
- [x] Import payload size and question-count limits were added.
- [x] Question ids/content/choices/answers/tags/explanations/time limits gained explicit bounds and canonical duplicate checks.
- [x] CSV parsing now rejects structurally invalid quote placement and trailing data after a closing quoted field.
- [x] Accessibility, import, settings, private-room, scoring, controller, and primary quiz-journey regression tests were expanded.
- [x] A deterministic repository-local Markdown link checker was added to CI and local quality scripts.
- [x] CI captures the Flutter-generated `pubspec.lock` as a short-lived artifact when dependency resolution executes, allowing lockfile review without hand-authoring it.
- [x] The tagged release workflow requires a committed lockfile, uses `flutter pub get --enforce-lockfile`, verifies the lockfile is unchanged, and runs the documentation-link gate.
- [x] Quality/build/security workflows gained superseded-run cancellation where applicable.
- [x] OSV scanning was added to relevant pull-request dependency changes.
- [x] Obsolete self-mutating bootstrap workflows were removed from the maintained branch.
- [x] Release workflow generates localization output before analysis/tests/builds.
- [x] README, setup, development, testing, CI, release, question-bank format, screenshot, roadmap, and changelog documentation were synchronized with the maintained branch.

## Required automated gates

These remain unchecked until the **final** pull-request head completes successfully. A queued, pending, cancelled, or superseded run is not a pass.

- [ ] Dependency installation succeeds and produces/reuses the expected lockfile.
- [ ] Flutter localization generation succeeds.
- [ ] Dart formatting check succeeds for `lib`, `test`, and `tool`.
- [ ] Repository-local Markdown link validation succeeds.
- [ ] Flutter analyzer succeeds with no errors.
- [ ] Unit/widget/integration/application tests succeed.
- [ ] Android build succeeds.
- [ ] Web build succeeds.
- [ ] Windows build succeeds on a Windows runner.
- [ ] Linux build succeeds on a Linux runner.
- [ ] macOS build succeeds on a macOS runner.
- [ ] iOS no-codesign build succeeds on a macOS runner.
- [ ] Dependency Review succeeds.
- [ ] OSV dependency scan succeeds.
- [ ] Secret Scan succeeds.

## GitHub Actions observation

On source/documentation head `cc730b84c92cbf694d62f03064f30bdd5eafc6cd`, the following pull-request runs were observed on 2026-08-19. They had **not completed successfully**, so none is recorded as passing evidence:

| Workflow | Run id | Observed status |
| --- | ---: | --- |
| CI | `32221756338` | pending |
| Build Gate | `32221756335` | queued |
| Platform Build Matrix | `32221756332` | queued |
| Dependency Review | `32221756374` | queued |
| OSV Vulnerability Scan | `32221756662` | queued |
| Secret Scan | `32221756319` | queued |

Earlier CI run `32221531069` for head `62d536941b12e8b5ae18903038ad1f5bf96d5e12` was later observed as **cancelled** after newer commits superseded it. That cancellation is expected from the workflow concurrency policy and is not counted as a pass or product failure.

This evidence document and later handoff commits themselves create newer pull-request heads. The release decision must always use the latest PR head and its corresponding final runs rather than any historical run ids in this table.

## Tooling limitation during this audit session

The execution environment used for repository editing did not provide a local Flutter/Dart toolchain, and direct container network cloning was unavailable. Therefore local `flutter pub get`, localization generation, formatting, analyzer, tests, and platform builds could not be truthfully recorded as executed in that environment. GitHub Actions is the available verification environment for these gates.

This is an evidence limitation, not a reason to waive any gate.

## Dependency lockfile status

- [ ] `pubspec.lock` is generated, reviewed, and committed from a supported Flutter environment.

A temporary write-capable one-shot workflow used earlier in the audit was removed rather than leaving unnecessary `contents: write` automation in the repository. The maintained CI workflow now follows a safer bootstrap path: normal read-only CI runs `flutter pub get` and uploads the generated `pubspec.lock` as a short-lived workflow artifact. Once a successful CI run exists, that exact generated artifact can be reviewed and committed through the normal branch/PR flow.

The tagged release workflow will refuse to package a release without a non-empty committed lockfile and enforced locked dependency resolution. Do **not** hand-author the application lockfile.

## Required manual/release-host checks

- [ ] Clean checkout setup follows `docs/setup.md` without undocumented steps.
- [ ] Generated platform runners are reproducible from documented commands.
- [ ] Drift persistence is exercised on Android and Web builds as applicable.
- [ ] Web refresh/reload preserves expected local data in the built release artifact.
- [ ] Keyboard navigation and focus visibility are manually checked on desktop/web.
- [ ] Representative screen-reader checks are completed.
- [ ] Large-text behavior is manually checked with both app and OS scaling.
- [ ] Reduced-motion behavior is manually reviewed.
- [ ] Light/dark contrast and non-color-only status indicators are reviewed.
- [ ] Real screenshots listed in `docs/screenshots/README.md` are captured from the verified release candidate.
- [ ] External documentation URLs are manually spot-checked where release-critical; repository-local links are now covered by automation.
- [ ] Final repository/history secret review is completed after the final head is fixed.

## Database verification

- [x] Schema is explicitly versioned as version 1.
- [x] Database creation is covered by in-memory SQLite integration tests in source control.
- [x] Foreign keys are enabled at open time.
- [x] Multi-step attempt/question persistence uses transactions where needed.
- [x] Profile-controller persistence ordering has dedicated in-memory regression tests around preference failures and rollback behavior.
- [ ] Database creation is exercised inside applicable platform builds/release candidates.
- [ ] Historical migration test exists — **not applicable yet because no schema version greater than 1 has been released**. The first schema increment must introduce a real migration and old-version-to-new-version test.

## Evidence log

| Date | Check | Result | Evidence |
| --- | --- | --- | --- |
| 2026-08-19 | Repository state inspected before Phase 6 audit | PASS | Base commit `d8c27cc81f678b1e49c17670c3d1efeab3d044d3` |
| 2026-08-19 | Fresh audit branch created from inspected `main` | PASS | `audit/phase-6-verification-2026-08-19` |
| 2026-08-19 | Active verification PR created | PASS | PR `#9` |
| 2026-08-19 | Superseded audit PRs closed | PASS | PRs `#6`, `#7`, and `#8` closed as superseded |
| 2026-08-19 | Obsolete self-mutating bootstrap workflows removed from audit branch | PASS | Focused `ci:` deletion commits on PR #9 |
| 2026-08-19 | Import resource limits and question validation bounds added with regression tests | PASS (source audit) | Phase 6 focused source/test commits |
| 2026-08-19 | Settings persistence ordering fixed | PASS (source audit) | Controller/settings repository changes plus regression tests |
| 2026-08-19 | Profile selection/create/delete failure ordering hardened | PASS (source audit) | `c2a9bea`, `0f49519`, `33d2008`, `a4a974b`, `9a52597`, `8a14a9f`, `00fcbdc`, `0af9f84` |
| 2026-08-19 | Strict malformed-CSV quote handling added | PASS (source audit) | `2f2313e`, `f96086b` |
| 2026-08-19 | Deterministic local Markdown-link gate added | PASS (source/config audit) | `920c71f`, `3f89f14`, local-script/CI/release follow-up commits |
| 2026-08-19 | Final-head automated verification | PENDING | Latest GitHub Actions runs must complete successfully |
| 2026-08-19 | Release-candidate lockfile | BLOCKED | `pubspec.lock` not yet generated/reviewed from successful Flutter CI/environment evidence |
| 2026-08-19 | Manual accessibility/screenshots/platform interaction review | PENDING | Requires verified built application on representative targets |

## Release decision rule

QuizForge must not be described as production/release verified and must not be tagged as a verified release candidate until every applicable blocker above has passed on the final commit. Any failed automated gate must be fixed with a focused commit and regression coverage where appropriate, then all affected gates must be re-run. Pending/cancelled infrastructure is recorded as such rather than converted into a success claim.
