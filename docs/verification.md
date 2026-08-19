# QuizForge 2.7.4 Release-Candidate Verification Evidence

This document records evidence for the consolidated QuizForge **2.7.4** release candidate. It is intentionally evidence-driven: an item is marked complete only after a corresponding command, GitHub Actions result, or documented manual review has actually succeeded on the applicable candidate.

## Candidate identity

- Application/package version: `2.7.4+1`
- Intended public tag after verification: `v2.7.4`
- Database schema version: `1`
- Local-backup format version: `1`
- Branch: `final/consolidated-release-audit-20260819`
- Pull request: `#12`
- Base branch: `main`
- Original consolidation base commit: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Consolidation source line: PR `#10` / `feature/phase-7-attempt-history-2026-08-19`, which already contained the stronger Phase 6 hardening from PR `#9`
- Additional audited source line: PR `#11` / `audit/phase6-20260819`
- Audit/release-candidate date: 2026-08-19
- Maintainer commit-email target: `sanskarin@outlook.in`
- Release-candidate status: **BLOCKED — final verification is not complete**

PR #12 deliberately consolidates the strongest implementation from the parallel branches instead of blindly merging overlapping store/controller refactors. The newer recent-attempt feature and Phase 6 persistence/import/security work remain the base; the full local-backup feature, ARB validation tooling, repository-validator tests, and useful documentation from the parallel audit line were ported into that stronger base and then audited further.

The 2.7.4 continuation additionally aligns package/versioning/changelog metadata and introduces an early release-metadata consistency validator so version drift can fail in pull-request CI before a tag exists.

## Source/configuration audit completed on the consolidated branch

- [x] Package version set to `2.7.4+1`.
- [x] `CHANGELOG.md` contains the dated 2.7.4 release-candidate entry and a fresh Unreleased section.
- [x] Stable-version compatibility documentation replaces the stale pre-1.0 policy.
- [x] `docs/versioning.md` records `2.7.4+1` and intended tag `v2.7.4`.
- [x] Dedicated 2.7.4 release notes added.
- [x] Stdlib-only release-metadata validator added for package/changelog/versioning consistency.
- [x] Release-metadata validator regression tests include invalid package versions, missing matching changelog releases, duplicate/out-of-order releases, stable-major/pre-1.0 mismatch, missing version/tag documentation, and historical zero-major release parsing.
- [x] Local/CI/tag workflows are wired to run the release-metadata validator and its tests alongside Markdown/ARB gates.
- [x] Phase 6 import, question-validation, localization, persistence-ordering, privacy/logging, workflow, and documentation hardening retained.
- [x] Recent per-profile attempt history retained with bounded newest-first queries, profile isolation, cleanup behavior, UI rendering, and documentation/tests.
- [x] Complete versioned local backup added for questions, profiles, bookmarks, quiz attempts/submitted answers, application settings, and active-profile selection.
- [x] Database restore is transactional and validates the logical archive before destructive replacement.
- [x] Controller-level restore snapshots database/settings/profile selection and attempts compensating rollback when a later cross-store step fails.
- [x] Restore requires a destructive-replacement confirmation in the UI.
- [x] Backup archives are documented and handled as private user data; raw archive content is not logged.
- [x] Backup format/version, archive size, question/profile validity, duplicate content/ids, references, attempt counts/scores, bookmarks, and active-profile membership are validated.
- [x] Whole-app backups with no local profile, no question, or no archived active-profile selection are rejected rather than silently restoring into initialization-generated state.
- [x] The encoder refuses to emit an archive above the decoder's supported archive-size limit.
- [x] Restored attempts are bounded to the normal 1–100-question QuizForge session contract.
- [x] Submitted-answer correctness and score are re-evaluated against archived questions using the normal `QuizEngine` before restored history is trusted.
- [x] Bookmark duplicate identity is represented as the exact `(profileId, questionId)` pair rather than a delimiter-built composite string.
- [x] Schema-version-1 answer-order limitation was identified and fixed: backup validation does not invent play order from question-id-sorted rows or incorrectly recompute `bestStreak` from that order.
- [x] Stored `bestStreak` is preserved while order-independent streak invariants are still validated.
- [x] Database, codec, controller, and widget backup regressions were added, including cross-store rollback and missing-answer-order coverage.
- [x] Deterministic ARB catalog validation exists for duplicate JSON keys, locale/message shape, metadata consistency, and translated-catalog key parity.
- [x] ARB validator regression tests exist.
- [x] Markdown validator regression coverage exists and the maintained quality graph references real files.
- [x] CI runs repository-validator tests plus Markdown, ARB, and release-metadata validation before Flutter setup.
- [x] Tagged release automation runs the same repository-validator tests and structural/metadata gates before Flutter setup/packaging.
- [x] Local shell/PowerShell quality scripts run the maintained validator + Flutter sequence.
- [x] README, architecture, privacy, data lifecycle, development, setup, testing, CI, release, roadmap, changelog, versioning, verification, release-notes, and local-backup documentation are synchronized with the maintained behavior.

## Required automated gates

These remain unchecked until the **final 2.7.4 pull-request head** completes successfully. A queued, pending, cancelled, skipped because of path filtering when the gate is actually applicable, or superseded run is not a pass.

- [ ] Markdown-validator regression tests succeed.
- [ ] ARB-validator regression tests succeed.
- [ ] Release-metadata-validator regression tests succeed.
- [ ] Repository-local Markdown validation succeeds.
- [ ] ARB localization-catalog validation succeeds.
- [ ] Release metadata validation succeeds.
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

## GitHub Actions observations

Earlier PR #12 heads produced applicable CI, Build Gate, Platform Build Matrix, Dependency Review, OSV, and Secret Scan runs that remained queued/pending. Those observations are historical evidence only because every source/documentation commit creates a newer candidate head.

The 2.7.4 metadata/tooling commits intentionally supersede the previous head. Therefore **all final release decisions must use the newest PR #12 head and only runs associated with that exact SHA**. Do not transfer a green or queued status from an older head to the current candidate.

As of this continuation, GitHub Actions runner availability remains a verification blocker rather than a passing result. Queued/pending runs are not converted into successes.

## Tooling limitation during this audit session

The execution environment used for repository editing did not provide a local Flutter/Dart toolchain, and direct container cloning/network access to GitHub was unavailable. Therefore local `flutter pub get`, `flutter gen-l10n`, Dart formatting, Flutter analyzer, Flutter tests, or platform builds could not be truthfully recorded as executed in that environment.

The stdlib release-metadata parsing logic was source-audited and its key regex behavior was independently sanity-checked for both current `2.7.4+1` metadata and historical `0.1.0` changelog recognition, but the authoritative repository validator/test result remains the final-head CI execution or a real checkout execution.

This is an evidence limitation, not a reason to waive any gate.

## Dependency lockfile status

- [ ] `pubspec.lock` is generated, reviewed, and committed from a supported Flutter environment.

The dependency manifest other than the root package version remained unchanged when moving from `0.1.0+1` to `2.7.4+1`. However, the repository still does not hand-author a lockfile. A lockfile may be committed only after it is produced by a supported Flutter resolver from the maintained dependency manifest and reviewed as evidence.

The read-only CI workflow resolves dependencies and uploads the generated application lockfile as a short-lived artifact when it reaches that step. Once a successful final-head CI run produces the artifact, review and commit that generated lockfile through the normal branch/PR process. The tag release workflow intentionally refuses to package a release without a committed, non-empty lockfile and enforced locked dependency resolution.

## Database and backup verification

- [x] Database schema remains explicitly versioned as version 1.
- [x] Application version 2.7.4 does not introduce a database schema layout change by itself.
- [x] Foreign keys are enabled at database open.
- [x] Database creation and core persistence are covered by in-memory SQLite tests in source control.
- [x] Attempt/question multi-step writes are transactional where required.
- [x] Complete logical database backup export/restore has in-memory integration coverage in source control.
- [x] Invalid backup references/aggregates/profile invariants have source-controlled regression coverage.
- [x] Submitted-answer tamper rejection has source-controlled regression coverage.
- [x] 1–100 restored-attempt bounds have source-controlled regression coverage.
- [x] Exact bookmark-pair duplicate handling has source-controlled regression coverage.
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
- [ ] Local backup restore is manually exercised with fictional custom question/profile/bookmark/history/settings data on applicable release targets.
- [ ] Keyboard navigation and focus visibility are manually checked on desktop/web.
- [ ] Representative screen-reader checks are completed.
- [ ] Large-text behavior is manually checked with both app and OS scaling.
- [ ] Reduced-motion behavior is manually reviewed.
- [ ] Light/dark contrast and non-color-only status indicators are reviewed.
- [ ] Real screenshots listed in `docs/screenshots/README.md` are captured from the verified 2.7.4 candidate using fictional/demo data.
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
| 2026-08-19 | Minimum restorable-state ambiguity fixed | PASS (source audit) | question/profile/active-profile validation + regression tests |
| 2026-08-19 | Submitted-answer tamper resistance added | PASS (source audit) | normal QuizEngine re-evaluation + regression test |
| 2026-08-19 | Attempt bounds and bookmark-pair identity hardened | PASS (source audit) | focused validation + regression tests |
| 2026-08-19 | Markdown/ARB validator tests and CI/local gates aligned | PASS (source/config audit) | quality workflow/scripts/tool commits |
| 2026-08-19 | 2.7.4 package/changelog/versioning identity established | PASS (source/config audit) | `pubspec.yaml`, `CHANGELOG.md`, `docs/versioning.md` |
| 2026-08-19 | Release-metadata validator and tests added | PASS (source/config audit) | `tool/check_release_metadata.py` + regression suite |
| 2026-08-19 | Release-metadata zero-major history bug fixed | PASS (source audit) | regex correction + historical `0.1.0` regression fixture |
| 2026-08-19 | CI/local/tag release metadata gates aligned | PASS (source/config audit) | workflow/script commits |
| 2026-08-19 | Dedicated 2.7.4 release notes added | PASS (documentation) | `docs/release-notes-2.7.4.md` |
| 2026-08-19 | Final-head automated verification | PENDING | newest PR #12 head must complete applicable checks successfully |
| 2026-08-19 | Release-candidate lockfile | BLOCKED | `pubspec.lock` not yet generated/reviewed/committed from verified Flutter evidence |
| 2026-08-19 | Manual platform/accessibility/screenshots/backup smoke verification | PENDING | requires verified built application on representative targets |

## Release decision rule

QuizForge 2.7.4 must not be described as production/release verified and `v2.7.4` must not be promoted as a verified release until every applicable blocker above has passed on the final commit. Any failed automated gate must be fixed with a focused commit and regression coverage where appropriate, then affected gates must run again on the new head.

Pending, queued, cancelled, superseded, skipped-but-applicable, or unobserved infrastructure is recorded as such rather than converted into a success claim.

**Made by the Sanskar**
