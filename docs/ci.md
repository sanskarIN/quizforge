# Continuous Integration

QuizForge uses focused GitHub Actions workflows rather than a single opaque job. A pull request should be considered healthy only when all relevant current checks have completed successfully.

## Quality gate

`.github/workflows/ci.yml` verifies:

- the repository-local Markdown link checker with regression tests;
- repository-local Markdown link targets across tracked documentation;
- dependency resolution;
- generated Flutter localizations through the configured Flutter generation flow;
- Dart formatting;
- Flutter static analysis;
- automated tests with coverage.

The same core Flutter commands are available locally through `tool/check.sh` and `tool/check.ps1`. Documentation links can be checked independently without a Flutter SDK:

```bash
python tool/test_check_markdown_links.py
python tool/check_markdown_links.py .
```

The Markdown checker intentionally performs no network requests. It verifies repository-local targets, rejects links that escape the repository root, ignores fenced code examples, and leaves external-site availability to human/release review.

## Build gate

`.github/workflows/build.yml` materializes reproducible Android/Web runners in the ephemeral CI checkout, resolves dependencies, generates localizations, builds an Android debug APK, and builds a Web release bundle.

The build job is a compatibility gate, not a substitute for signed production Android artifacts or manual release-candidate testing.

## Dependency review

`.github/workflows/dependency-review.yml` reviews dependency changes in pull requests. It is intended to stop newly introduced dependency risk from being treated as ordinary source churn.

## Vulnerability scan

`.github/workflows/osv-scan.yml` uses the tracked OSV scanning workflow on its configured triggers. Results must be investigated rather than suppressed without a documented reason.

## Secret scan

`.github/workflows/secret-scan.yml` scans tracked repository history using the configured secret-detection tooling. A successful result is useful evidence, but it does not replace GitHub-hosted secret-scanning settings where those are available for the repository.

## Platform compilation gates

`.github/workflows/platform-builds.yml` provides host-appropriate platform compilation coverage. Platform compilation is a compatibility signal; release signing, provisioning, packaging policy, and manual release testing remain separate requirements.

## Tagged release workflow

`.github/workflows/release.yml` handles the repository's tagged Android/Web release path. It validates the tag/version relationship, runs quality checks, builds artifacts, creates checksums, uploads workflow artifacts, and creates a GitHub release.

Release automation does not make signing secrets public. Any distribution-channel signing/provisioning must use secret storage outside the repository.

## Baseline maintenance workflows

The one-shot baseline workflows exist to safely complete and record the initial repository baseline using the requested Git identity. They are path-triggered by their own tracked creation/update and are not intended to become recurring product behavior.

Normal future development should use pull requests and the standard quality/build/security workflows.

## Local reproduction

```bash
python tool/test_check_markdown_links.py
python tool/check_markdown_links.py .
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
- a documentation-link defect;
- an infrastructure/transient runner problem.

Product/test/configuration/documentation failures require a source fix and regression coverage where appropriate. Transient infrastructure failures may be rerun only after the failure evidence supports that classification.

## Evidence

`docs/verification.md` records automated baseline evidence. `what_changed.md` remains the primary cross-chat continuation ledger and must distinguish completed checks from pending platform/manual verification.
