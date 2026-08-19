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
- [x] Primary quiz, creator, question-bank, import/export, statistics, settings, onboarding, About, and error UI were moved toward externalized English localization resources.
- [x] Large-text behavior now clamps the existing system `TextScaler` to a minimum rather than replacing stronger or nonlinear operating-system scaling.
- [x] Reduced-motion settings preserve the operating-system disable-animation request.
- [x] Review and question-bank bookmark state changes refresh safely and report persistence failures without raw exception content.
- [x] Settings updates mutate in-memory state only after persistence succeeds.
- [x] Active-profile selection loads target profile state and persists the target preference before mutating visible controller state.
- [x] Profile creation/deletion use rollback-aware persistence ordering and preserve original stack traces when failures are rethrown.
- [x] Cross-store local-data reset attempts each managed store, clears stale memory, reloads durable state, and only then reports a reset failure.
- [x] Noncritical preference/derived-statistic startup failures use safe fallbacks while core database initialization remains fatal.
- [x] Successful primary writes are not incorrectly reported as failed only because a later progress/leaderboard refresh fails.
- [x] Import payload size and question-count limits were added.
- [x] Question ids/content/choices/answers/tags/explanations/time limits gained explicit bounds and canonical duplicate checks.
- [x] JSON and CSV accepted-answer arrays reject blank/normalized duplicates before conversion to sets can hide them.
- [x] CSV parsing rejects structurally invalid quote placement and trailing data after a closing quoted field.
- [x] Creator draft validation keeps duplicate accepted-answer and invalid numeric-time errors visible until corrected.
- [x] Clipboard read/write failures in question-bank exchange are handled safely without logging clipboard payloads.
- [x] Quiz result construction rejects impossible negative timelines and copies evaluations into an unmodifiable list.
- [x] Seeded quiz ordering uses a documented SDK-independent deterministic generator with a known-order regression fixture.
- [x] Starter question-bank integrity tests verify domain validity, unique ids/fingerprints, supported question types, and representative categories.
- [x] Database integration tests verify transaction rollback for invalid question batches and invalid attempt-answer foreign keys.
- [x] Controller tests cover startup fallback, settings/profile persistence failures, create/delete rollback, partial-reset recovery, and a simulated restart boundary.
- [x] Root app-shell tests cover onboarding routing, completion, direct dashboard entry, and onboarding preference-load failure behavior.
- [x] The dedicated About page is reachable from the main app bar and has navigation coverage.
- [x] A deterministic repository-local Markdown link checker was added to CI and local quality scripts.
- [x] CI captures the Flutter-generated `pubspec.lock` as a short-lived artifact when dependency resolution executes, allowing lockfile review without hand-authoring it.
- [x] The tagged release workflow requires a committed lockfile, uses `flutter pub get --enforce-lockfile`, verifies the lockfile is unchanged, and runs the documentation-link gate.
- [x] Quality/build/security workflows cancel superseded runs where applicable.
- [x] OSV scanning covers relevant pull-request dependency changes.
- [x] Obsolete self-mutating bootstrap workflows were removed from the maintained branch.
- [x] Release workflow generates localization output before analysis/tests/builds.
- [x] README, architecture, data lifecycle, accessibility, setup, development, testing, CI, release, question-bank format, repository settings, screenshots, roadmap, changelog, and continuation documentation were synchronized with the maintained branch.

## Required automated gates

These remain unchecked until the **final** pull-request head completes successfully. A queued, pending, cancelled, superseded, or not-yet-indexed run is not a pass.

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

The audit branch receives frequent focused commits. Workflow concurrency intentionally cancels superseded runs. The most recent fully indexed source/documentation checkpoint inspected before this evidence update was `4ba65f1fa91fa3eafc79ea20d858fd43665f7128`, where these pull-request workflows were observed without successful completion:

| Workflow | Run id | Observed status |
| --- | ---: | --- |
| CI | `32223595282` | pending |
| Build Gate | `32223595285` | queued |
| Platform Build Matrix | `32223595289` | queued |
| Dependency Review | `32223595287` | queued |
| OSV Vulnerability Scan | `32223595573` | queued |
| Secret Scan | `32223595284` | queued |

A later source checkpoint, `a7140d512b03cf11fe33a5589e929341a36c55f1`, had no associated pull-request workflow runs returned by the GitHub connector at the moment it was checked. That means the runs were not yet observable through this interface; it is **not** passing evidence.

Earlier runs were also observed as cancelled after newer commits superseded them. Cancellation due to concurrency is expected and is not counted as a pass or a product failure.

This evidence update and later handoff commits themselves create newer pull-request heads. The release decision must always use the latest PR head and its corresponding completed final runs rather than historical run ids in this table.

## Tooling limitation during this audit session

The execution environment used for repository editing did not provide a local Flutter/Dart toolchain, and direct container network cloning was unavailable. Therefore local `flutter pub get`, localization generation, formatting, analyzer, tests, and platform builds could not be truthfully recorded as executed in that environment. GitHub Actions is the available verification environment for these gates.

This is an evidence limitation, not a reason to waive any gate.

## Dependency lockfile status

- [ ] `pubspec.lock` is generated, reviewed, and committed from a supported Flutter environment.

A temporary write-capable one-shot workflow used earlier in the audit was removed rather than leaving unnecessary `contents: write` automation in the repository. The maintained CI workflow follows a safer bootstrap path: read-only CI runs `flutter pub get` and uploads the generated `pubspec.lock` as a short-lived workflow artifact. Once a successful CI run reaches that step, that exact generated artifact can be downloaded, reviewed, and committed through the normal branch/PR flow.

The tagged release workflow refuses to package a release without a non-empty committed lockfile and enforced locked dependency resolution. Do **not** hand-author the application lockfile.

## Required manual/release-host checks

- [ ] Clean checkout setup follows `docs/setup.md` without undocumented steps.
- [ ] Generated platform runners are reproducible from documented commands.
- [ ] Drift persistence is exercised on Android and Web builds as applicable.
- [ ] Web refresh/reload preserves expected local data in the built release artifact.
- [ ] Keyboard navigation and focus visibility are manually checked on desktop/web.
- [ ] Representative screen-reader checks are completed.
- [ ] Large-text behavior is manually checked with both application and OS scaling, including nonlinear scaling where the platform exposes it.
- [ ] Reduced-motion behavior is manually reviewed.
- [ ] Light/dark contrast and non-color-only status indicators are reviewed.
- [ ] Real screenshots listed in `docs/screenshots/README.md` are captured from the exact verified release candidate.
- [ ] External documentation URLs are manually spot-checked where release-critical; repository-local links are covered by automation once the final CI gate passes.
- [ ] Final repository/history secret review is completed after the final head is fixed.
- [ ] Store signing/provisioning is completed outside the public repository where applicable.

## Database verification

- [x] Schema is explicitly versioned as version 1.
- [x] Database creation is covered by in-memory SQLite integration tests in source control.
- [x] Foreign keys are enabled at open time.
- [x] Multi-step attempt/question persistence uses transactions where needed.
- [x] Integration tests verify rollback when a later question-batch item is invalid.
- [x] Integration tests verify attempt rollback when an answer row violates its question foreign key.
- [x] Profile-controller persistence ordering has dedicated in-memory regression tests around preference failures and rollback behavior.
- [ ] Database creation/persistence is exercised inside applicable built release candidates.
- [ ] Historical migration test exists — **not applicable yet because no schema version greater than 1 has been released**. The first schema increment must introduce a real migration and old-version-to-new-version test.

## Evidence log

| Date | Check | Result | Evidence |
| --- | --- | --- | --- |
| 2026-08-19 | Repository state inspected before Phase 6 audit | PASS | Base commit `d8c27cc81f678b1e49c17670c3d1efeab3d044d3` |
| 2026-08-19 | Fresh audit branch created from inspected `main` | PASS | `audit/phase-6-verification-2026-08-19` |
| 2026-08-19 | Active verification PR created | PASS | PR `#9` |
| 2026-08-19 | Superseded audit PRs closed | PASS | PRs `#6`, `#7`, and `#8` closed as superseded |
| 2026-08-19 | Obsolete self-mutating bootstrap workflows removed | PASS (source/config audit) | Focused Phase 6 deletion commits |
| 2026-08-19 | Import bounds, strict CSV parsing, and accepted-answer preservation hardened | PASS (source audit) | Focused domain/codec/test commits |
| 2026-08-19 | Settings/profile/reset/startup persistence behavior hardened | PASS (source audit) | Focused controller/storage/test commits |
| 2026-08-19 | Seeded quiz ordering made SDK-independent | PASS (source audit) | Deterministic generator + known-order regression fixture |
| 2026-08-19 | Starter-bank and database rollback invariants added | PASS (source audit) | Dedicated data/integration regression tests |
| 2026-08-19 | App-shell/onboarding/About navigation coverage expanded | PASS (source audit) | Injectable onboarding store + widget tests + reachable About page |
| 2026-08-19 | Nonlinear system text scaling preserved | PASS (source/API audit) | Existing `TextScaler` clamped to app minimum instead of replaced |
| 2026-08-19 | Deterministic local Markdown-link gate added | PASS (source/config audit) | Python checker + local scripts + CI/release integration |
| 2026-08-19 | Final-head automated verification | PENDING | Latest GitHub Actions runs must complete successfully |
| 2026-08-19 | Release-candidate lockfile | BLOCKED | `pubspec.lock` not yet generated/reviewed from successful Flutter CI/environment evidence |
| 2026-08-19 | Manual accessibility/screenshots/platform interaction review | PENDING | Requires verified built application on representative targets |

## Release decision rule

QuizForge must not be described as production/release verified and must not be tagged as a verified release candidate until every applicable blocker above has passed on the final commit. Any failed automated gate must be fixed with a focused commit and regression coverage where appropriate, then all affected gates must be rerun. Pending/cancelled/unobservable infrastructure is recorded as such rather than converted into a success claim.
