# Continuous Integration

QuizForge uses focused GitHub Actions workflows rather than a single opaque job. A pull request should be considered healthy only when all relevant current checks have completed successfully.

All recurring pull-request workflows use least-privilege permissions and concurrency cancellation so superseded commits do not consume runner capacity unnecessarily.

## Quality gate

`.github/workflows/ci.yml` verifies:

- dependency resolution;
- Flutter localization generation;
- Dart formatting across `lib/`, `test/`, and `tool/`;
- Flutter static analysis;
- automated tests with coverage.

The same core commands are available locally through `tool/check.sh` and `tool/check.ps1`.

## Android/Web build gate

`.github/workflows/build.yml` materializes reproducible Android/Web runners in the ephemeral CI checkout, resolves dependencies, generates localizations, builds an Android debug APK, and builds a Web release bundle.

The build job is a compatibility gate, not a substitute for signed production Android artifacts or manual release-candidate testing.

## Platform build matrix

`.github/workflows/platform-builds.yml` provides host-appropriate release compile/build checks for Linux, Windows, macOS, and iOS. It materializes the relevant generated runner in each ephemeral checkout. iOS uses a no-codesign release compile because CI does not contain distribution signing credentials.

A passing compile/build matrix is necessary evidence, but signing, store provisioning, installer UX, and manual device/accessibility review remain separate release activities.

## Dependency review

`.github/workflows/dependency-review.yml` reviews dependency changes in pull requests and fails on newly introduced dependencies at or above its configured severity threshold.

## Vulnerability scan

`.github/workflows/osv-scan.yml` runs OSV scanning for relevant dependency changes on pull requests/pushes and on its scheduled/manual triggers. Results must be investigated rather than suppressed without a documented reason.

## Secret scan

`.github/workflows/secret-scan.yml` scans full Git history with Gitleaks on pull requests, pushes to `main`, its schedule, and manual dispatch. The checkout intentionally uses full history for this job.

## Tagged release workflow

`.github/workflows/release.yml` handles the repository's tagged Android/Web release path. It validates the tag/version relationship, resolves dependencies, generates localizations, verifies formatting across application/tests/tooling, runs analysis/tests, builds release artifacts, creates SHA-256 checksums, uploads workflow artifacts, and creates a GitHub release.

Release automation does not make signing secrets public. Any distribution-channel signing/provisioning must use secret storage outside the repository.

## Removed one-shot maintenance automation

Early repository-bootstrap work used temporary self-mutating maintenance workflows to repair/materialize the baseline. Phase 6 removed those workflows from the maintained branch after their purpose was superseded. Long-lived production automation must not retain broad `contents: write` permissions merely to rewrite and push source code to `main`.

Normal development uses pull requests and the focused quality/build/security workflows above. The tagged release workflow is the only recurring workflow in this set that needs `contents: write`, because it creates GitHub release records/artifacts for an explicitly pushed version tag.

## Local reproduction

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

For Android/Web build reproduction on a compatible host:

```bash
flutter create . --platforms=android,web
flutter pub get
flutter gen-l10n
flutter build apk --debug
flutter build web --release
```

## Failure policy

Do not merge around a failing check merely to make a status indicator green. Determine whether the failure is:

- a product regression;
- a test defect;
- a dependency/toolchain incompatibility;
- a generated-file/configuration issue;
- an infrastructure/transient runner problem.

Product/test/configuration failures require a source fix and regression coverage where appropriate. Transient infrastructure failures may be rerun only after the failure evidence supports that classification.

A check that is still `queued` or `pending` is not a pass. Phase 6 verification records this distinction explicitly rather than inferring success from the existence of the workflow.

## Evidence

`docs/verification.md` records the current Phase 6 evidence and exact limitations. `what_changed.md` remains the primary cross-chat continuation ledger and distinguishes implemented work from checks that are still pending or require manual/platform verification.
