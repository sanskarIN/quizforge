# Verification Evidence — QuizForge 0.1.0 Baseline

Audit branch: `audit/final-0.1.0-verification-v2`

This ledger is intentionally created on a fresh branch from the latest `main` so pull-request workflows evaluate the current source, tests, localization, benchmark harness, documentation, and repository automation together.

## Pull-request checks expected

- Flutter dependency resolution
- Flutter localization generation
- Dart format verification
- Flutter static analysis
- automated unit/integration/widget tests
- dependency review

The repository also configures OSV vulnerability scanning on its own supported triggers.

## Clean-checkout verification sequence

```bash
flutter --version
flutter doctor -v
flutter create . --platforms=android,ios,web,windows,macos,linux
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
```

Only generate/build targets supported by the current host when the host cannot provide every platform toolchain.

## Performance harness

```bash
dart run tool/benchmark.dart 10000
```

Benchmark evidence must record environment metadata; timing output is not a universal product guarantee.

## Release-build evidence still required

A platform becomes release-verified only after its corresponding release build succeeds on a supported host. Relevant commands include:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release
```

## Evidence record

For each completed audit record:

- timestamp/timezone;
- audited commit SHA;
- Flutter/Dart versions;
- host OS/architecture;
- package resolution result;
- localization generation result;
- format result;
- analyzer result;
- automated test result/count;
- dependency/security scan result;
- benchmark command/environment/result if measured;
- platform builds actually executed;
- SQLite persistence smoke test;
- manual accessibility review;
- documentation-link review;
- known limitations;
- GitHub Actions run identifiers/links when available.

## Current status

Pending the workflows triggered by the audit pull request. A failure must be fixed and reverified; this file must not be interpreted as evidence that a pending check passed.

**Made by the Sanskar**
