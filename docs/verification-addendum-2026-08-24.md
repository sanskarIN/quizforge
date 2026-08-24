# QuizForge 2.7.4 Verification Addendum — 2026-08-24

This addendum captures exact GitHub Actions evidence and continuation work from 2026-08-24 without rewriting older historical evidence. It is intended to be folded into `docs/verification.md` and `what_changed.md` only after the current release-candidate head finishes its exact-head checks.

## Exact head `c1bca20d610dcb9b4a438554d753d71698bb73fa`

Observed workflow results:

- Build Gate — **SUCCESS** (`32686440282`).
- Platform Build Matrix — **SUCCESS** (`32686440290`).
- Dependency Review — **SUCCESS** (`32686440308`).
- OSV Vulnerability Scan — **SUCCESS** (`32686440577`).
- Secret Scan — **SUCCESS** (`32686440288`).
- CI — **FAILURE** (`32686440306`) at the Dart formatting step only.

Before the formatting step failed, the exact head successfully completed:

- Markdown-validator regression tests;
- ARB-validator regression tests;
- release-metadata-validator regression tests;
- Web-runtime-asset regression tests;
- platform-branding regression tests;
- generated-runner-contract regression tests;
- repository-local Markdown validation;
- ARB catalog validation;
- release metadata validation;
- generated platform-runner contract validation;
- Flutter 3.47.1 / Dart 3.13.1 setup;
- `flutter pub get --enforce-lockfile`;
- zero resolver-file drift for `pubspec.lock` and `analysis_options.yaml`;
- Flutter localization generation.

The formatter reported one changed file: `lib/src/data/settings_repository.dart`. Analyzer and tests were skipped because the formatting gate correctly stopped the job.

## Formatting diagnosis and repair

Earlier attempts focused on constructor-initializer indentation, but Dart 3.13 documentation confirms the maintained four-space continuation style for constructor initializer lists. The remaining short expression-body getter was still split across lines even though its full expression fits the formatter page width.

Continuation commits:

- `c348e391807084ac94678a2b4ed8befc5a3c474d` — make CI print `git diff -- lib test tool` when Dart formatting fails, so future formatting failures expose the exact formatter mutation instead of only naming the changed file.
- `f576374c48064168a182b31349a99181802ab264` — normalize the lazy `SettingsRepository._store` expression-body getter to a single formatter-friendly line while retaining lazy `SharedPreferencesAsync` initialization semantics.

The current maintained PR #12 head is `f576374c48064168a182b31349a99181802ab264`. Its workflow set exists but remains queued/pending as of this addendum. Queued, pending, cancelled, superseded, or unobserved checks are not passes.

## Release-engineering state confirmed by `c1bca20...`

The successful Build Gate and Platform Build Matrix are direct exact-head evidence that the hardened generated-runner sequence is viable across all supported build targets on that head:

- runner scaffolding uses `--no-pub`;
- canonical generated organization is `io.github.sanskarin`;
- canonical generated application/bundle identity is `io.github.sanskarin.quizforge`;
- reviewed `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml` are restored from `HEAD` after project recreation;
- locked dependency resolution is then performed explicitly;
- deterministic QuizForge branding is applied/checked;
- Web runtime assets are prepared/packaged/verified;
- Android, Web, Linux, Windows, macOS, and iOS no-codesign build/compile paths completed successfully.

This does not remove the requirement for a final exact-head rerun after the formatting-only source change at `f576374...`.

## Next-version preparation isolation

Future version `2.18.12` preparation is isolated on branch `planning/2.18.12-20260824` rather than changing the 2.7.4 candidate.

Prepared planning artifacts:

- `docs/next-version-2.18.12.md`;
- `docs/version-2.18.12-workstreams.md`;
- `docs/version-2.18.12-release-checklist.md`;
- a Phase 8 roadmap section on the planning branch.

Temporary stacked draft PR #13 was created for review organization and then closed without merging so its Actions jobs do not compete with the active 2.7.4 release-candidate queue. The planning branch remains available to rebase/reopen after the verified 2.7.4 release path closes.

No 2.18.12 source version bump, tag, database-schema change, backup-format change, or network-feature enablement has been performed.

## Remaining automated blocker

The immediate automated goal is to observe the complete exact-head `f576374...` CI path through:

- formatting;
- analyzer;
- all unit/widget/integration/application tests.

If CI still reports formatting drift, the diagnostic formatter step now prints the exact diff. If formatting succeeds and analyzer/tests reveal a real defect, that defect must receive a focused source/test fix and a new exact-head verification cycle.

## Remaining manual/release-host blockers

Even after all exact-head automated workflows pass, 2.7.4 is not fully release-verified until applicable manual evidence is recorded for:

- Android persistence and complete local-backup restore;
- Web real-browser SQLite WASM/worker loading, create/write/read, refresh/reload persistence, and complete-backup restore;
- representative Windows/Linux/macOS persistence/core-flow checks;
- signed/device iOS validation if iOS is distributed;
- branded launcher/icon/splash visual presentation;
- keyboard/focus, screen-reader, large-text, reduced-motion, contrast, and touch review;
- real screenshots from actual candidate builds using fictional/demo data;
- distribution signing/notarization/provisioning where applicable.

`v2.7.4` must not be promoted as verified until the applicable blockers above are actually complete.

**Made by the Sanskar**
