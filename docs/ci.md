# Continuous Integration

QuizForge uses focused GitHub Actions workflows rather than a single opaque job. A pull request should be considered healthy only when all relevant current checks have completed successfully.

All recurring pull-request workflows use least-privilege permissions and concurrency cancellation so superseded commits do not consume runner capacity unnecessarily. Pull-request verification is intentionally available for **every pull request base branch**, not only PRs targeting `main`. This allows stacked review flows such as a feature PR into an active audit/release branch to receive the same applicable gates before the parent audit PR is merged into `main`.

Push-triggered verification remains scoped to `main` where configured. Path-filtered workflows still run only when their relevant paths change.

## Quality gate

`.github/workflows/ci.yml` verifies, in order:

- regression tests for the repository-local Markdown, ARB, release-metadata, and Web-runtime-asset tooling;
- repository-local Markdown links and image targets with `tool/check_markdown_links.py`;
- ARB localization-catalog structure/key consistency with `tool/check_arb_catalogs.py`;
- package/in-app/changelog/versioning consistency with `tool/check_release_metadata.py`;
- Flutter toolchain setup and dependency resolution;
- capture of the resolved `pubspec.lock` as short-lived review evidence;
- Flutter localization generation;
- Dart formatting across `lib/`, `test/`, and `tool/`;
- Flutter static analysis;
- automated tests with coverage.

The Markdown checker is deterministic and network-independent. It validates relative/local links and reference definitions while ignoring fenced code examples and network URLs. Its public test contract also rejects links that resolve outside the repository root. External HTTP availability remains a manual release review concern because third-party availability is inherently nondeterministic.

The ARB checker is stdlib-only. It rejects duplicate JSON keys, missing/non-empty locale metadata, empty/non-string messages, orphan metadata records, and translated catalogs whose message key sets diverge from the English template. `flutter gen-l10n` remains the authoritative Flutter generator check after this early structural gate.

The release-metadata checker is stdlib-only as well. For the maintained 2.7.4 line it checks `pubspec.yaml`, the in-app `AppConstants.version`, dated/ordered changelog release metadata, stable-major versioning policy, and matching package/tag documentation.

The Web runtime tool regression tests are also network-independent. The actual download of pinned Drift Web assets is isolated to Web build/release jobs rather than making the general quality job depend on an external download.

The same maintained source-quality sequence is available locally through `tool/check.sh` and `tool/check.ps1`.

## Android/Web build gate

`.github/workflows/build.yml` provides the primary Android/Web release-build compatibility gate. It:

1. tests the Web runtime asset tooling;
2. materializes reproducible Android/Web runners;
3. prepares the pinned Drift Web SQLite runtime assets;
4. resolves Flutter dependencies and generates localizations;
5. builds an **Android release APK**;
6. builds a Web release bundle;
7. verifies `sqlite3.wasm` and `drift_worker.js` exist and pass validation in `build/web`.

This closes the earlier gap where Web Dart compilation could pass even though the persistent Drift runtime assets were absent.

The build job is still not a substitute for Android signing/store validation or a real-browser Web persistence/reload smoke test.

## Platform build matrix

`.github/workflows/platform-builds.yml` provides host-appropriate release compile/build checks for Linux, Windows, macOS, and iOS. It materializes the relevant generated runner in each ephemeral checkout. iOS uses a no-codesign release compile because CI does not contain distribution signing credentials.

The platform workflow retains path filters, so documentation-only PRs do not consume all host runners. A relevant code/platform change in a stacked feature PR can still trigger the matrix even when that PR targets an audit/release branch rather than `main`.

A passing compile/build matrix is necessary evidence, but signing, store provisioning, installer UX, local persistence interaction, and manual device/accessibility review remain separate release activities.

## Cross-platform evidence already observed

On the earlier 2.7.4 candidate head `306bee785cbebbf5b5d6bea875f8d5b4988ea175`, the following completed successfully:

- Android/Web Build Gate;
- Linux release build;
- Windows release build;
- macOS release build;
- iOS no-codesign release compile;
- Dependency Review;
- OSV Vulnerability Scan;
- Secret Scan.

The main CI workflow on that head failed before Flutter setup because `tool/test_check_markdown_links.py` and `tool/check_markdown_links.py` had drifted apart: tests expected reusable `extract_targets()` / `validate_file()` APIs and repository-escape rejection that the implementation did not yet provide. The implementation was corrected with a focused regression-contract fix.

Because later cross-platform/Web runtime changes create newer source heads, the older green build/security results are **historical evidence only**. The current final head must run again before release verification is promoted.

## Dependency review

`.github/workflows/dependency-review.yml` reviews dependency changes in pull requests and fails on newly introduced dependencies at or above its configured severity threshold. It is not limited to PRs targeting `main`, so dependency changes cannot bypass review merely by being staged through an intermediate integration branch.

## Vulnerability scan

`.github/workflows/osv-scan.yml` runs OSV scanning for relevant dependency/workflow changes on pull requests, for relevant pushes to `main`, and on its scheduled/manual triggers. Its pull-request trigger is base-branch agnostic but remains path-filtered. Results must be investigated rather than suppressed without a documented reason.

## Secret scan

`.github/workflows/secret-scan.yml` scans full Git history with Gitleaks on every pull request, pushes to `main`, its schedule, and manual dispatch. The checkout intentionally uses full history for this job.

## Stacked and consolidated pull requests

When a feature is developed on top of an unmerged audit/release branch:

1. Open the feature PR against that audit/release branch rather than directly against `main` when it truly depends on the parent branch.
2. Use the feature PR's **exact head SHA** when reading check results.
3. Wait for all applicable feature checks to complete; queued/pending is not a pass.
4. Merge the feature PR into the audit/release branch only after its applicable gates are acceptable.
5. Then treat the resulting audit/release branch head as a new candidate and rerun/re-read the parent PR checks against `main`.

When multiple parallel audit branches contain overlapping work, prefer a deliberate consolidation branch over blind branch merging when that is necessary to preserve the stronger implementation from each line. The consolidated branch becomes a new candidate and must receive its own complete final-head verification; historical green checks on source branches do not transfer automatically.

## Tagged release workflow

`.github/workflows/release.yml` is a cross-platform gated release pipeline.

### Source verification

The first job:

- validates tag/public package-version agreement;
- requires a committed non-empty application lockfile;
- runs Markdown/ARB/release-metadata/Web-tool regression tests;
- runs all repository structural/metadata validators;
- uses `flutter pub get --enforce-lockfile` and verifies the lockfile is unchanged;
- generates localizations;
- verifies formatting;
- runs Flutter analysis and tests with coverage.

No platform packaging job begins until this verification succeeds.

### Platform packaging

After source verification, independent host jobs build/package:

- Android release APK and AAB;
- Web release bundle with validated Drift WASM/worker assets;
- Linux x64 release bundle;
- Windows x64 release bundle;
- macOS release output;
- iOS release compile with `--no-codesign`.

The iOS artifact is named as **unsigned** compile output and must not be represented as an App Store/device-signed distribution package.

### Publication

The publication job depends on every platform job. It downloads the platform artifacts, generates SHA-256 checksums, and creates the GitHub release only after all required build jobs have succeeded. Only this final job receives `contents: write`; verification/build jobs remain read-only.

For the current candidate, the intended public tag is `v2.7.4`, derived from package version `2.7.4+1`. The build suffix is intentionally omitted from the public Git tag.

Release automation does not make signing secrets public. Android/iOS/macOS distribution signing and provisioning must use appropriate secret storage outside the public repository.

## Removed one-shot maintenance automation

Early repository-bootstrap work used temporary self-mutating maintenance workflows to repair/materialize the baseline. Phase 6 removed those workflows from the maintained branch after their purpose was superseded. Long-lived production automation must not retain broad `contents: write` permissions merely to rewrite and push source code to `main`.

Normal development uses pull requests and the focused quality/build/security workflows above. The tagged release publication job has write permission solely to create an explicitly requested GitHub release from a version tag after all gates succeed.

## Local reproduction

```bash
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/test_prepare_web_assets.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

Use `python` instead of `python3` on Windows when that is the configured launcher.

For Android/Web release-build reproduction on a compatible host:

```bash
flutter create . --platforms=android,web
python3 tool/prepare_web_assets.py --destination web
flutter pub get
flutter gen-l10n
flutter build apk --release
flutter build web --release
python3 tool/prepare_web_assets.py --destination build/web --check
```

See [`platform-support.md`](platform-support.md) for all six target build commands.

## Failure policy

Do not merge around a failing check merely to make a status indicator green. Determine whether the failure is:

- a product regression;
- a test defect;
- a dependency/toolchain incompatibility;
- a generated-file/configuration issue;
- an infrastructure/transient runner problem.

Product/test/configuration failures require a source fix and regression coverage where appropriate. Transient infrastructure failures may be rerun only after the failure evidence supports that classification.

A check that is still `queued` or `pending` is not a pass. Version 2.7.4 verification records this distinction explicitly rather than inferring success from the existence of the workflow.

## Evidence

`docs/verification.md` records the current 2.7.4 release-candidate evidence and exact limitations. `what_changed.md` remains the primary cross-chat continuation ledger and distinguishes implemented work from checks that are still pending or require manual/platform verification.
