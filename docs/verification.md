# Final Release-Candidate Verification Evidence

This document records evidence for the consolidated QuizForge release-candidate audit. It is intentionally evidence-driven: an item is marked complete only after a corresponding command, GitHub Actions result, or documented manual review has actually succeeded on the applicable candidate.

## Candidate identity

- Branch: `final/consolidated-release-audit-20260819`
- Pull request: `#12` — `release: consolidate final QuizForge audit`
- Base branch: `main`
- Base commit: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Consolidation source line: PR `#10` / `feature/phase-7-attempt-history-2026-08-19`, which already contained the stronger Phase 6 hardening from PR `#9`
- Additional audited source line: PR `#11` / `audit/phase6-20260819`
- Audit date: 2026-08-19
- Maintainer commit-email target: `sanskarin@outlook.in`
- Release-candidate status: **BLOCKED — final verification is not complete**

PR #12 deliberately consolidates the strongest implementation from the parallel branches instead of blindly merging overlapping store/controller refactors. The newer recent-attempt feature and Phase 6 persistence/import/security work remain the base; the full local-backup feature, ARB validation tooling, validator tests, and useful documentation from the parallel audit line were ported into that stronger base and then audited further.

## Source/configuration audit completed on the consolidated branch

- [x] Phase 6 import, question-validation, localization, persistence-ordering, privacy/logging, workflow, and documentation hardening retained.
- [x] Recent per-profile attempt history retained with bounded newest-first queries, profile isolation, cleanup behavior, UI rendering, and documentation/tests.
- [x] Complete versioned local backup added for questions, profiles, bookmarks, quiz attempts/submitted answers, application settings, and active-profile selection.
- [x] Database restore is transactional and validates the logical archive before destructive replacement.
- [x] Controller-level restore snapshots database/settings/profile selection and attempts compensating rollback when a later cross-store step fails.
- [x] Restore requires a destructive-replacement confirmation in the UI.
- [x] Backup archives are documented and handled as private user data; raw archive content is not logged.
- [x] Backup format/version, archive size, question/profile validity, duplicate content/ids, references, attempt counts/scores, bookmarks, and active-profile membership are validated.
- [x] Whole-app backups with no local profile are rejected instead of silently restoring into a different default-profile state.
- [x] The encoder refuses to emit an archive above the decoder's supported archive-size limit, preventing an intentionally exported archive that the same version rejects solely for size.
- [x] Schema-version-1 answer-order limitation was identified and fixed: `attempt_answers` has no position column, so backup validation does not invent play order from question-id-sorted rows or incorrectly recompute `bestStreak` from that order.
- [x] Stored `bestStreak` is preserved while order-independent streak invariants are still validated.
- [x] Database, codec, controller, and widget backup regressions were added, including cross-store rollback and missing-answer-order coverage.
- [x] Deterministic ARB catalog validation was added for duplicate JSON keys, locale/message shape, metadata consistency, and translated-catalog key parity.
- [x] ARB validator regression tests were added.
- [x] The Markdown validator regression-test helper referenced by CI/local scripts was added so the quality graph is self-contained.
- [x] CI runs repository-validator tests plus Markdown and ARB validation before Flutter setup.
- [x] Tagged release automation now runs the same repository-validator tests and Markdown/ARB structural gates before Flutter setup/packaging.
- [x] Local shell/PowerShell quality scripts run the maintained validator + Flutter sequence.
- [x] README, architecture, privacy, data lifecycle, development, setup, testing, CI, release, roadmap, changelog, and local-backup documentation were synchronized with the consolidated behavior.

## Required automated gates

These remain unchecked until the **final pull-request head** completes successfully. A queued, pending, cancelled, skipped because of path filtering when the gate is actually applicable, or superseded run is not a pass.

- [ ] Markdown-validator regression tests succeed.
- [ ] ARB-validator regression tests succeed.
- [ ] Repository-local Markdown validation succeeds.
- [ ] ARB localization-catalog validation succeeds.
- [ ] Dependency installation succeeds and produces/reuses the expected lockfile.
- [ ] Flutter localization generation succeeds.
- [ ] Dart formatting check succeeds for `lib`, `test`, and `tool`.
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

## Initial PR #12 GitHub Actions observation

Immediately after PR #12 was opened, the exact source/documentation head was `6e05fcbd0a7c306f621541df0007cdef37458d8e`. The following runs were observed on 2026-08-19 and were all still **queued**, so none is recorded as a passing result:

| Workflow | Run id | Observed status |
| --- | ---: | --- |
| CI | `32267984788` | queued |
| Secret Scan | `32267984765` | queued |
| Platform Build Matrix | `32267984940` | queued |
| Dependency Review | `32267984972` | queued |
| Build Gate | `32267985062` | queued |
| OSV Vulnerability Scan | `32267985458` | queued |

This verification-ledger commit and the final handoff commit create newer PR heads. Therefore the table above is historical evidence only. **The release decision must always use the newest PR #12 head and its own corresponding completed runs.** Do not transfer a green status from an older head to a newer candidate.

## Tooling limitation during this audit session

The execution environment used for repository editing did not provide a local Flutter/Dart toolchain, and direct container cloning/network access to GitHub was unavailable. Therefore local `flutter pub get`, `flutter gen-l10n`, Dart formatting, Flutter analyzer, Flutter tests, or platform builds could not be truthfully recorded as executed in that environment.

The same limitation prevented executing the repository Python validators from a real checked-out tree inside the container even though the validator code/tests were audited and wired into GitHub Actions. Their actual success must come from an observed final-head CI run or another documented checkout environment.

This is an evidence limitation, not a reason to waive any gate.

## Dependency lockfile status

- [ ] `pubspec.lock` is generated, reviewed, and committed from a supported Flutter environment.

The maintained read-only CI workflow resolves dependencies and uploads the generated application lockfile as a short-lived artifact when it reaches that step. Once a successful final-head CI run produces the artifact, review and commit that exact generated lockfile through the normal branch/PR process. Do **not** hand-author the application lockfile.

The tag release workflow intentionally refuses to package a release without a committed, non-empty lockfile and enforced locked dependency resolution.

## Database and backup verification

- [x] Database schema remains explicitly versioned as version 1.
- [x] Foreign keys are enabled at database open.
- [x] Database creation and core persistence are covered by in-memory SQLite tests in source control.
- [x] Attempt/question multi-step writes are transactional where required.
- [x] Complete logical database backup export/restore has in-memory integration coverage in source control.
- [x] Invalid backup references/aggregates/profile invariants have source-controlled regression coverage.
- [x] Cross-store controller rollback has source-controlled regression coverage.
- [x] Restore confirmation has widget regression coverage.
- [x] Schema-v1 missing answer-order behavior has a regression test so valid historical streak metadata is not rejected based on invented ordering.
- [ ] Database creation is exercised inside applicable final release builds.
- [ ] Android complete-backup export/mutate/restore smoke test is completed using fictional data.
- [ ] Web complete-backup export/mutate/restore and refresh/reload persistence smoke test is completed using fictional data.
- [ ] At least one applicable native-desktop complete-backup smoke test is completed when a desktop target is part of the release.
- [ ] Historical schema migration test exists — **not applicable until a schema version greater than 1 is introduced**. The first schema increment must add real migration code and an old-version-to-new-version test.

## Required manual/release-host checks

- [ ] Clean checkout setup follows `docs/setup.md` without undocumented steps.
- [ ] Generated platform runners are reproducible from documented commands.
- [ ] Drift persistence is exercised on Android and Web release builds as applicable.
- [ ] Web refresh/reload preserves expected local data in the built artifact.
- [ ] Local backup restore is manually exercised with fictional custom question/profile/bookmark/history/settings data on the applicable release targets.
- [ ] Keyboard navigation and focus visibility are manually checked on desktop/web.
- [ ] Representative screen-reader checks are completed.
- [ ] Large-text behavior is manually checked with both app and OS scaling.
- [ ] Reduced-motion behavior is manually reviewed.
- [ ] Light/dark contrast and non-color-only status indicators are reviewed.
- [ ] Real screenshots listed in `docs/screenshots/README.md` are captured from the verified release candidate using fictional/demo data.
- [ ] External documentation URLs are manually spot-checked where release-critical; repository-local links are covered by automation once that final-head gate passes.
- [ ] Final repository/history secret review completes successfully after the candidate head is fixed.

## Evidence log

| Date | Check | Result | Evidence |
| --- | --- | --- | --- |
| 2026-08-19 | Original repository state inspected | PASS | `main` at `d8c27cc81f678b1e49c17670c3d1efeab3d044d3` |
| 2026-08-19 | Strongest integrated feature base selected | PASS (source audit) | PR #10 already contained PR #9 hardening plus recent attempt history |
| 2026-08-19 | Parallel PR #11 unique work inspected | PASS (source audit) | Backup/restore and ARB/tooling work selectively ported instead of blindly merging overlapping store refactors |
| 2026-08-19 | Consolidated final branch created | PASS | `final/consolidated-release-audit-20260819` |
| 2026-08-19 | Complete local backup/restore integrated into hardened controller | PASS (source audit) | focused feature commits on consolidated branch |
| 2026-08-19 | Cross-store restore rollback covered | PASS (source audit) | controller backup regression test |
| 2026-08-19 | Missing answer-order/best-streak bug found and fixed | PASS (source audit) | order-independent backup validation + regression test |
| 2026-08-19 | Unrestorable oversized-export edge case fixed | PASS (source audit) | encoder now enforces its decoder archive limit |
| 2026-08-19 | Profileless whole-app archive ambiguity fixed | PASS (source audit) | snapshot validation + regression test |
| 2026-08-19 | Markdown/ARB validator tests and CI/local gates aligned | PASS (source/config audit) | quality workflow/scripts/tool commits |
| 2026-08-19 | Tagged release validator gates aligned with CI | PASS (source/config audit) | release workflow commit |
| 2026-08-19 | Consolidated pull request opened | PASS | PR #12 |
| 2026-08-19 | First PR #12 workflow observation | PENDING | six applicable runs queued on head `6e05fcbd...` |
| 2026-08-19 | Final-head automated verification | PENDING | newest PR #12 head must complete applicable checks successfully |
| 2026-08-19 | Release-candidate lockfile | BLOCKED | `pubspec.lock` not yet generated/reviewed/committed from verified Flutter evidence |
| 2026-08-19 | Manual platform/accessibility/screenshots/backup smoke verification | PENDING | requires verified built application on representative targets |

## Release decision rule

QuizForge must not be described as production/release verified and must not be tagged as a verified release candidate until every applicable blocker above has passed on the final commit. Any failed automated gate must be fixed with a focused commit and regression coverage where appropriate, then affected gates must run again on the new head.

Pending, queued, cancelled, or superseded infrastructure is recorded as such rather than converted into a success claim.
