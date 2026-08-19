# Continuous Integration

QuizForge uses focused GitHub Actions workflows rather than a single opaque job. A pull request should be considered healthy only when all relevant current checks have completed successfully.

## Quality gate

`.github/workflows/ci.yml` verifies:

- dependency resolution;
- Flutter localization generation;
- Dart formatting;
- Flutter static analysis;
- automated tests with coverage.

The same core commands are available locally through `tool/check.sh` and `tool/check.ps1`.

## Build gate

`.github/workflows/build.yml` materializes reproducible Android/Web runners in the ephemeral CI checkout, resolves dependencies, generates localizations, builds an Android debug APK, and builds a Web release bundle.

The build job is a compatibility gate, not a substitute for signed production Android artifacts or manual release-candidate testing.

## Dependency review

`.github/workflows/dependency-review.yml` reviews dependency changes in pull requests. It is intended to stop newly introduced dependency risk from being treated as ordinary source churn.

## Vulnerability scan

`.github/workflows/osv-scan.yml` uses the tracked OSV scanning workflow on its configured triggers. Results must be investigated rather than suppressed without a documented reason.

## Tagged release workflow

`.github/workflows/release.yml` handles the repository's tagged Android/Web release path. It validates the tag/version relationship, runs quality checks, builds artifacts, creates checksums, uploads workflow artifacts, and creates a GitHub release.

Release automation does not make signing secrets public. Any distribution-channel signing/provisioning must use secret storage outside the repository.

## Baseline maintenance workflows

The one-shot `finalize-baseline.yml` / `stabilize-baseline.yml` workflows exist to safely complete and record the initial repository baseline using the requested Git identity. They are path-triggered by their own tracked creation/update and are not intended to become recurring product behavior.

Normal future development should use pull requests and the standard quality/build/security workflows.

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

## Evidence

`docs/verification.md` records automated baseline evidence after the stabilization workflow succeeds. `what_changed.md` remains the primary cross-chat continuation ledger and must distinguish completed checks from pending platform/manual verification.
