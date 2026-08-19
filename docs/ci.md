# Continuous Integration

QuizForge uses focused GitHub Actions workflows rather than a single opaque job. A pull request should be considered healthy only when all relevant current checks have completed successfully.

All recurring pull-request workflows use least-privilege permissions and concurrency cancellation so superseded commits do not consume runner capacity unnecessarily. Pull-request verification is intentionally available for **every pull request base branch**, not only PRs targeting `main`. This allows stacked review flows such as a feature PR into an active audit/release branch to receive the same applicable gates before the parent audit PR is merged into `main`.

Push-triggered verification remains scoped to `main` where configured. Path-filtered workflows still run only when their relevant paths change.

## Quality gate

`.github/workflows/ci.yml` verifies, in order:

- regression tests for the repository-local Markdown and ARB validators;
- repository-local Markdown links and image targets with `tool/check_markdown_links.py`;
- ARB localization-catalog structure/key consistency with `tool/check_arb_catalogs.py`;
- Flutter toolchain setup and dependency resolution;
- capture of the resolved `pubspec.lock` as short-lived review evidence;
- Flutter localization generation;
- Dart formatting across `lib/`, `test/`, and `tool/`;
- Flutter static analysis;
- automated tests with coverage.

The Markdown checker is intentionally deterministic and network-independent. It validates relative/local links and reference definitions while ignoring fenced code examples and network URLs. External HTTP availability is still a manual release review concern because third-party availability is inherently nondeterministic.

The ARB checker is also stdlib-only. It rejects duplicate JSON keys, missing/non-empty locale metadata, empty/non-string messages, orphan metadata records, and translated catalogs whose message key sets diverge from the English template. `flutter gen-l10n` remains the authoritative Flutter generator check after this early structural gate.

The same maintained sequence is available locally through `tool/check.sh` and `tool/check.ps1`.

## Android/Web build gate

`.github/workflows/build.yml` materializes reproducible Android/Web runners in the ephemeral CI checkout, resolves dependencies, generates localizations, builds an Android debug APK, and builds a Web release bundle.

The build job is a compatibility gate, not a substitute for signed production Android artifacts or manual release-candidate testing.

## Platform build matrix

`.github/workflows/platform-builds.yml` provides host-appropriate release compile/build checks for Linux, Windows, macOS, and iOS. It materializes the relevant generated runner in each ephemeral checkout. iOS uses a no-codesign release compile because CI does not contain distribution signing credentials.

The platform workflow retains path filters, so documentation-only PRs do not consume all host runners. A relevant code/platform change in a stacked feature PR can still trigger the matrix even when that PR targets an audit/release branch rather than `main`.

A passing compile/build matrix is necessary evidence, but signing, store provisioning, installer UX, and manual device/accessibility review remain separate release activities.

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

`.github/workflows/release.yml` handles the repository's tagged Android/Web release path. It validates the tag/version relationship, resolves dependencies, generates localizations, verifies formatting across application/tests/tooling, runs analysis/tests, builds release artifacts, creates SHA-256 checksums, uploads workflow artifacts, and creates a GitHub release.

Release automation does not make signing secrets public. Any distribution-channel signing/provisioning must use secret storage outside the repository.

## Removed one-shot maintenance automation

Early repository-bootstrap work used temporary self-mutating maintenance workflows to repair/materialize the baseline. Phase 6 removed those workflows from the maintained branch after their purpose was superseded. Long-lived production automation must not retain broad `contents: write` permissions merely to rewrite and push source code to `main`.

Normal development uses pull requests and the focused quality/build/security workflows above. The tagged release workflow is the only recurring workflow in this set that needs `contents: write`, because it creates GitHub release records/artifacts for an explicitly pushed version tag.

## Local reproduction

```bash
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

Use `python` instead of `python3` on Windows when that is the configured launcher.

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
