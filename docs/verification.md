# QuizForge 2.7.4 Release-Candidate Verification Evidence

This document records evidence for the consolidated QuizForge **2.7.4** release candidate. It is intentionally evidence-driven: an item is marked complete only after a corresponding command, GitHub Actions result, source audit, or documented manual review has actually succeeded at the stated evidence level.

## Candidate identity

- Application/package version: `2.7.4+1`
- In-app/About public version: `2.7.4`
- Intended public tag after verification: `v2.7.4`
- Supported source targets: Android, iOS, Web, Windows, macOS, Linux
- Database schema version: `1`
- Local-backup format version: `1`
- Branch: `final/consolidated-release-audit-20260819`
- Pull request: `#12`
- Base branch: `main`
- Original consolidation base commit: `d8c27cc81f678b1e49c17670c3d1efeab3d044d3`
- Earlier fully observed build-evidence head: `306bee785cbebbf5b5d6bea875f8d5b4988ea175`
- Later exact CI diagnostic head: `3cd7511b48c07f9dacc1b901b63d93b486c0df97`
- Pre-verification-ledger branding/documentation head: `598ba4d22594fff1359395f9405bfb3fc8c51f61`
- Maintainer commit-email target: `sanskarin@outlook.in`
- Release-candidate status: **BLOCKED — final exact-head verification and required manual release-host evidence are not complete**

PR #12 is the single maintained release-candidate path. Former PRs #9, #10, and #11 were deliberately consolidated rather than blindly merged so the strongest persistence/import/security implementation could be retained while unique recent-history, backup, validation, and documentation work was integrated.

## 2.7.4 source/configuration audit completed

### Release identity

- [x] `pubspec.yaml` uses `2.7.4+1`.
- [x] `AppConstants.version` uses public version `2.7.4`.
- [x] About widget regression expects `Installed version: 2.7.4`.
- [x] `CHANGELOG.md` contains a dated 2.7.4 entry plus a fresh Unreleased section.
- [x] `docs/versioning.md` records package `2.7.4+1`, in-app `2.7.4`, and intended tag `v2.7.4`.
- [x] Stable 2.x compatibility policy replaced stale pre-1.0 wording.
- [x] Release metadata validation covers package syntax/build, in-app version equality, changelog version/order/date, stable-major policy, and version/tag documentation.
- [x] Release metadata rejects leading-zero SemVer components and impossible calendar dates.
- [x] A Flutter-generated application `pubspec.lock` is committed and accepted by enforced resolution evidence.

### Product/data hardening retained

- [x] Four quiz question types, deterministic scoring/selection, daily/random/timed/custom quiz flows retained.
- [x] Local profiles, bookmarks, progress, leaderboard, and bounded recent attempt history retained.
- [x] Question creation plus bounded/validated JSON/CSV import/export retained.
- [x] Persistence-first settings/profile ordering and rollback-aware controller operations retained.
- [x] Complete local backup/restore covers questions, profiles, bookmarks, attempts/submitted answers, settings, and active-profile selection.
- [x] Backup restore validates before destructive replacement and uses a SQLite transaction for database replacement.
- [x] Cross-store restore attempts compensation when settings/profile preference restoration fails after database mutation.
- [x] Whole-app backup requires at least one question, one profile, and a valid active profile.
- [x] Backup archive encode/decode size boundaries are symmetric.
- [x] Restored attempts are restricted to normal 1–100-question sessions.
- [x] Submitted-answer correctness/score rows are re-evaluated using `QuizEngine` before trust.
- [x] Bookmark duplicate identity uses exact `(profileId, questionId)` pairs.
- [x] Schema-v1 answer-order limitation is respected: stored `bestStreak` is preserved and only order-independent invariants are validated.
- [x] Settings/profile preference repositories can be constructed without eagerly initializing the platform plugin; actual persistence still uses `SharedPreferencesAsync`.

### Cross-platform implementation

- [x] Supported target contract explicitly covers Android, iOS, Web, Windows, macOS, and Linux.
- [x] Shared application/domain/controller code does not require OS-specific `dart:io` / `Platform.*` branches for core flows.
- [x] Standard Flutter runner shells are reproducibly generated with `flutter create . --platforms=android,ios,web,windows,macos,linux`.
- [x] Native Android/iOS/Windows/macOS/Linux database path remains `drift_flutter` native SQLite.
- [x] `AppDatabase.defaults()` supplies explicit `DriftWebOptions` for Web.
- [x] Web database URIs point to `sqlite3.wasm` and `drift_worker.js`.
- [x] `tool/prepare_web_assets.py` prepares the pinned Drift 2.34.3 Web runtime assets.
- [x] Web WASM validation checks the WebAssembly magic header and bounded size.
- [x] Web worker validation checks non-empty bounded UTF-8 content and rejects HTML error pages.
- [x] Web worker validation does not depend on minifier-preserved human-readable identifiers.
- [x] Web runtime asset writes are atomic.
- [x] `tool/test_prepare_web_assets.py` covers local validation without network access.
- [x] Android/Web PR build gate prepares Web runtime assets and verifies them in `build/web`.
- [x] Android/Web PR build gate builds Android in release mode.
- [x] Linux, Windows, macOS, and iOS no-codesign host build matrix remains maintained.
- [x] Tagged release workflow is gated across Android, Web, Linux, Windows, macOS, and unsigned iOS compile output.
- [x] Tagged release publication waits for every platform packaging job and generates SHA-256 checksums.
- [x] Only the final release publication job receives `contents: write` permission.
- [x] iOS release artifact is explicitly described/named as unsigned compile evidence rather than a signed distribution package.

### Deterministic platform branding

- [x] `tool/generate_platform_branding.py` uses only Python standard-library code and does not require an image-conversion dependency or remote artwork download.
- [x] Android launcher-density icons and branded launch-background artwork are generated after runner materialization.
- [x] iOS AppIcon sizes and launch-image assets are generated after runner materialization.
- [x] Web favicon, 192/512 icons, and maskable icons are generated after runner materialization.
- [x] Windows application ICO is generated deterministically.
- [x] macOS AppIcon sizes are generated deterministically.
- [x] Linux receives a deterministic 256px packaging/icon resource; final desktop packaging integration remains distribution-format dependent.
- [x] Opaque icon PNGs use RGB while splash/launch artwork may use RGBA transparency.
- [x] The generator has a non-mutating `--check` mode for expected assets, PNG dimensions, Android splash references, and Windows ICO structure.
- [x] `tool/test_generate_platform_branding.py` covers deterministic rendering, PNG mode/dimensions, all target layouts, missing-asset detection, platform parsing, and ICO structure.
- [x] Local standard-library test execution completed 4/4 branding-generator tests successfully before CI integration.
- [x] Main CI and local shell/PowerShell quality scripts run the branding regression suite.
- [x] Android/Web Build Gate applies and checks branding after `flutter create`.
- [x] Linux/Windows/macOS/iOS build matrix applies and checks branding after `flutter create`.
- [x] Tagged platform packaging applies and checks branding before building release artifacts.
- [ ] Representative platform visual inspection confirms launcher-mask/crop, splash scaling, icon clarity, and distribution presentation.

### Repository tooling

- [x] Markdown checker regression contract is implemented with reusable `extract_targets()` and `validate_file()` APIs.
- [x] Markdown checker rejects local targets that escape the repository root.
- [x] ARB validation protects locale/message/metadata/key parity.
- [x] Release-metadata validation protects package/in-app/changelog/versioning identity.
- [x] Web runtime asset validation is covered by deterministic tests.
- [x] Platform-branding generation/validation is covered by deterministic tests.
- [x] Local shell/PowerShell checks, PR CI, Android/Web build CI, host build matrix, and tagged release automation are aligned with their applicable tool contracts.
- [x] Platform host/build workflows now use `flutter pub get --enforce-lockfile` and reject unexpected resolver drift.

## Historical exact-head GitHub Actions evidence

### Head `306bee785cbebbf5b5d6bea875f8d5b4988ea175`

Observed completed workflow results:

- [x] Build Gate — **SUCCESS** (`32273890444`).
- [x] Platform Build Matrix — **SUCCESS** (`32273890427`).
  - Linux release build succeeded.
  - Windows release build succeeded.
  - macOS release build succeeded.
  - iOS no-codesign release compile succeeded.
- [x] Dependency Review — **SUCCESS** (`32273890437`).
- [x] OSV Vulnerability Scan — **SUCCESS** (`32273890873`).
- [x] Secret Scan — **SUCCESS** (`32273890415`).
- [ ] CI — **FAILURE** (`32273890486`).

The CI failure occurred in `Test repository validation tooling` before Flutter setup. All five Markdown checker regression tests errored because the tests expected `extract_targets()`, `validate_file()`, and a `BrokenLink.reason` contract that the implementation did not expose. The repository-escape test also demonstrated that the implementation did not yet explicitly reject `../` targets leaving the repository root.

That failure was treated as a real source/tooling defect, not runner noise. The checker was fixed in commit `8120a2605671894dbc99e2a502f472c0eb8f3cb4` to implement the tested APIs, reasons, and repository-boundary validation.

### Head `3cd7511b48c07f9dacc1b901b63d93b486c0df97`

Observed completed workflow results:

- [x] Build Gate — **SUCCESS**.
- [x] Platform Build Matrix — **SUCCESS**.
- [x] Dependency Review — **SUCCESS**.
- [x] OSV Vulnerability Scan — **SUCCESS**.
- [x] Secret Scan — **SUCCESS**.
- [ ] CI — **FAILURE** (`32435888584`).

Before the test step failed, this exact CI run proved:

- [x] Markdown-validator regression tests succeeded.
- [x] ARB-validator regression tests succeeded.
- [x] Release-metadata-validator regression tests succeeded.
- [x] Web-runtime-asset regression tests succeeded.
- [x] Repository-local Markdown validation succeeded.
- [x] ARB localization-catalog validation succeeded.
- [x] Release metadata validation succeeded.
- [x] Flutter `3.47.1` / Dart `3.13.1` setup succeeded.
- [x] `flutter pub get --enforce-lockfile` succeeded.
- [x] Dependency resolution left `pubspec.lock` and `analysis_options.yaml` unchanged.
- [x] Flutter localization generation succeeded.
- [x] Dart formatting checked 76 files with zero changes.
- [x] Flutter analyzer reported no issues.

The test step reported **86 passed, 13 failed**.

Eleven failures shared the same root cause: constructing `SettingsRepository()` eagerly constructed `SharedPreferencesAsync`, which requires a configured platform backend even for widget tests that only need a controller object and never touch persistent settings.

The remaining two failures were stale lazy-list assumptions:

- recent-attempt history was asserted before its low `ListView` child had been built;
- local-backup restore controls were asserted before their low `ListView` child had been built.

Focused fixes were committed on 2026-08-23:

- `6f05c68b6a17fed41832aba79f2c07e000e05277` — defer settings preference-plugin acquisition;
- `94d283e4c3400918ff05bb36e4c4ab8dada37886` — defer active-profile preference-plugin acquisition;
- `7d9b640ba9a61e84afcebb7a36a1f97736ac799b` — constructor regression coverage for both preference repositories;
- `9717b93f2341235a184772d822d387e6d5149009` — scroll recent-attempt history into view in widget coverage;
- `4df73edecc58fda4ea3ab9853001f4619b50225d` — scroll local-backup restore controls into view in widget coverage.

These are source/test fixes, not final pass evidence. The newer exact head must complete the affected workflows successfully.

### Interpretation

The successful build matrix on `306bee...` is strong historical evidence that the pre-Web-hardening codebase compiled across all six supported targets. The later `3cd751...` head additionally proved the committed lockfile, repository validators, localization generation, formatter, analyzer, and all non-CI security/build workflows were healthy before the widget-test regressions were reached.

Neither historical head is final release evidence for a newer candidate head. Branding/build-workflow changes also materially affect later heads, so all applicable workflows must pass again on the final frozen head.

## Required automated gates for the final head

These remain unchecked until the **exact final PR #12 head** completes successfully:

- [ ] Markdown-validator regression tests succeed.
- [ ] ARB-validator regression tests succeed.
- [ ] Release-metadata-validator regression tests succeed.
- [ ] Web-runtime-asset regression tests succeed.
- [ ] Platform-branding regression tests succeed.
- [ ] Repository-local Markdown validation succeeds.
- [ ] ARB localization-catalog validation succeeds.
- [ ] Release metadata validation succeeds.
- [ ] `flutter pub get --enforce-lockfile` succeeds against the committed lockfile.
- [ ] Dependency resolution leaves `pubspec.lock` unchanged.
- [ ] Flutter localization generation succeeds.
- [ ] Dart formatting succeeds for `lib`, `test`, and `tool`.
- [ ] Flutter analyzer succeeds.
- [ ] Unit/widget/integration/application tests succeed.
- [ ] Android generated branding structural check succeeds.
- [ ] Android release APK build succeeds.
- [ ] Web generated branding structural check succeeds.
- [ ] Web release build succeeds.
- [ ] Packaged Web WASM/worker validation succeeds.
- [ ] Linux generated branding structural check succeeds.
- [ ] Linux release build succeeds.
- [ ] Windows generated branding structural check succeeds.
- [ ] Windows release build succeeds.
- [ ] macOS generated branding structural check succeeds.
- [ ] macOS release build succeeds.
- [ ] iOS generated branding structural check succeeds.
- [ ] iOS no-codesign release compile succeeds.
- [ ] Dependency Review succeeds.
- [ ] OSV Vulnerability Scan succeeds.
- [ ] Secret Scan succeeds.

A queued, pending, cancelled, superseded, skipped-but-applicable, or unobserved check is not a pass.

## Dependency lockfile status

- [x] `pubspec.lock` is generated and committed from a supported Flutter resolver.
- [x] Exact-head CI at `3cd751...` accepted it with `flutter pub get --enforce-lockfile`.
- [x] Exact-head CI at `3cd751...` left the committed lockfile unchanged after dependency resolution.
- [x] Android/Web and Linux/Windows/macOS/iOS build-workflow definitions now enforce the committed lockfile and check resolver cleanliness.
- [x] Tagged release packaging enforces the committed lockfile.

The lockfile is no longer a missing-source blocker. It remains part of every final-head verification because a later dependency/configuration change must not silently rewrite it.

## Database and backup release-host verification

Source-controlled coverage is present for database operations and logical backup/restore, but real release-host behavior remains required:

- [ ] Android release build opens/creates the database and persists data across restart.
- [ ] Android complete-backup export → mutate/reset → restore succeeds using fictional data.
- [ ] Web release build loads `sqlite3.wasm` and the worker successfully.
- [ ] Web server serves `.wasm` with the WebAssembly MIME type.
- [ ] Web database create/write/read succeeds in a real browser.
- [ ] Web refresh/reload preserves expected local data.
- [ ] Web complete-backup export → mutate/reset → restore succeeds using fictional data.
- [ ] Windows local database and representative core-flow smoke test completes.
- [ ] Linux local database and representative core-flow smoke test completes.
- [ ] macOS local database and representative core-flow smoke test completes.
- [ ] iOS signed/device validation is completed outside public CI if iOS is distributed.

Historical schema migration testing is **not applicable while schemaVersion remains 1**. The first schema increment must add a real old-version-to-new-version migration test.

## Manual branding, accessibility, and UI checks

Before calling 2.7.4 release-verified:

- [ ] Android launcher icon is recognizable under representative adaptive masks/crops and branded launch artwork is centered/scaled correctly.
- [ ] iOS application icon and launch artwork are visually correct on representative simulator/device presentation.
- [ ] Web favicon/app icons are visually correct and maskable icons retain safe content inside common masks.
- [ ] Windows application icon is visible/recognizable in representative shell/taskbar/window surfaces.
- [ ] macOS application icon is visible/recognizable at representative Dock/Finder sizes.
- [ ] Linux packaging/icon integration is completed for the intended distribution format and visually checked.
- [ ] keyboard navigation and visible focus checked on desktop/Web.
- [ ] representative screen-reader checks completed.
- [ ] large-text behavior checked with app + OS/browser scaling.
- [ ] reduced-motion behavior reviewed.
- [ ] light/dark contrast and non-color-only result cues reviewed.
- [ ] touch interaction reviewed on Android/iOS where distributed.
- [ ] installed About page shows version `2.7.4`.
- [ ] verified screenshots captured from actual release builds using fictional/demo data.

## Signing/distribution boundaries

- Android store signing remains external to the public repository.
- iOS CI uses `--no-codesign`; its artifact is compile evidence, not a signed IPA/App Store package.
- macOS distribution signing/notarization remains external unless configured through secure release infrastructure.
- Windows/Linux packaging in the tag workflow provides portable build bundles, not a claim of installer certification.

No signing keys, profiles, passwords, service-account credentials, or private certificates may be committed.

## Tooling limitation of the editing environment

The repository-editing environment used during this audit does not provide a local Flutter/Dart toolchain and cannot perform the authoritative local six-platform build sequence. GitHub-hosted Actions therefore provides the automated Flutter/platform build evidence.

Deterministic Python tooling can be executed independently for source-level regression confidence, but no source review or Python-only test is converted into an unobserved Flutter/platform pass.

The connected GitHub contents API also does not expose a per-commit author-email override. The requested maintainer email is documented for local Git use, but connector-generated commits are not represented as carrying an author email that was not verified.

## Evidence log

| Date | Check | Result | Evidence |
| --- | --- | --- | --- |
| 2026-08-19 | Original repository baseline | PASS | `main` at `d8c27cc81f678b1e49c17670c3d1efeab3d044d3` |
| 2026-08-19 | Consolidated final branch/PR | PASS | `final/consolidated-release-audit-20260819` / PR #12 |
| 2026-08-19 | Complete local backup/restore hardening | PASS (source audit) | DB/controller/codec/widget tests and docs |
| 2026-08-19 | 2.7.4 package/in-app/tag identity | PASS (source audit) | pubspec, AppConstants, changelog, versioning docs/tests |
| 2026-08-20 | Earlier Android/Web build gate | PASS (historical exact head) | run `32273890444` at `306bee...` |
| 2026-08-20 | Earlier Linux/Windows/macOS/iOS matrix | PASS (historical exact head) | run `32273890427` at `306bee...` |
| 2026-08-20 | Earlier Dependency Review | PASS (historical exact head) | run `32273890437` at `306bee...` |
| 2026-08-20 | Earlier OSV scan | PASS (historical exact head) | run `32273890873` at `306bee...` |
| 2026-08-20 | Earlier Secret Scan | PASS (historical exact head) | run `32273890415` at `306bee...` |
| 2026-08-20 | Earlier CI quality job | FAIL | run `32273890486`; Markdown checker/test API mismatch |
| 2026-08-20 | Markdown checker contract/repository-escape fix | PASS (source fix) | commit `8120a2605671894dbc99e2a502f472c0eb8f3cb4` |
| 2026-08-20 | Explicit Drift Web database configuration | PASS (source/config audit) | `AppDatabase.defaults()` Web options |
| 2026-08-20 | Pinned Drift Web runtime preparation/tool tests | PASS (source/config audit) | `tool/prepare_web_assets.py` + tests |
| 2026-08-20 | Android/Web release-mode + packaged runtime gate | PASS (config audit) | maintained `build.yml`; final exact-head execution required |
| 2026-08-20 | Six-platform tagged release packaging | PASS (config audit) | maintained `release.yml`; tag execution not yet applicable |
| 2026-08-21 | Committed application lockfile | PASS | Flutter 3.47.1 accepted `--enforce-lockfile` with zero resolver diff at `3cd751...` |
| 2026-08-21 | Exact diagnostic CI quality job | FAIL | run `32435888584`; 86 tests passed, 13 widget tests failed |
| 2026-08-23 | Preference/plugin construction repair | PASS (source fix) | commits `6f05c68`, `94d283e`, `7d9b640`; exact-head rerun required |
| 2026-08-23 | Lazy-list widget regression repair | PASS (source fix) | commits `9717b93`, `4df73ed`; exact-head rerun required |
| 2026-08-23 | Deterministic platform-branding generator | PASS (source/local tooling) | commits `703cb6d`, `8b53c2a`; local standard-library tests 4/4 |
| 2026-08-23 | Branding integrated into CI/build/release paths | PASS (source/config audit) | commits `08a8041`, `b328420`, `87106d3`, `4148eda`, `9c59f0f`, `1fce8f0` |
| 2026-08-23 | Branding docs/roadmap/release notes/changelog | PASS (documentation audit) | commits `df1d3f8`, `3eca500`, `ea27f80`, `598ba4d` |
| 2026-08-23 | Final-head automated verification | PENDING | read the newest PR #12 exact-head workflows after the final continuation-ledger commit |
| 2026-08-23 | Manual platform/branding/accessibility/screenshots | PENDING | requires representative built applications and distribution contexts |

## Release decision rule

QuizForge 2.7.4 must not be described as fully release-verified and `v2.7.4` must not be promoted as a verified release until every applicable blocker above has passed on the exact final commit.

Any real automated failure must be inspected and fixed with a focused source/configuration change and regression coverage where practical. The resulting new head then requires the affected checks again.

**Made by the Sanskar**
