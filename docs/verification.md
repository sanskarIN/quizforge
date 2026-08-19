# Verification Evidence — QuizForge 0.1.0 Development Baseline

Audit branch: `audit/final-0.1.0-verification`

This file exists to trigger and record verification against the **latest `main` state**. It is not a substitute for completed workflow/build evidence.

## Pull-request quality gate

The audit pull request must run the repository's current workflows against the complete source tree:

- Flutter dependency resolution;
- Flutter localization generation;
- Dart formatting verification;
- Flutter static analysis;
- automated tests;
- dependency review.

The OSV workflow separately provides dependency vulnerability scanning on its configured triggers.

## Required clean-checkout command sequence

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

Generate only host-supported platform runners when the host cannot materialize every target.

## Release-build evidence still required

A release candidate must additionally record successful builds actually executed on supported hosts. Relevant commands include:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
flutter build macos --release
flutter build linux --release
flutter build ios --release
```

Do not mark a platform release-verified merely because source code targets it or a runner can be generated.

## Evidence record template

For each completed audit, record:

- date/time and timezone;
- audited commit SHA;
- Flutter version;
- Dart version;
- host OS/architecture;
- `flutter pub get` result;
- `flutter gen-l10n` result;
- format result;
- analyzer result;
- automated test result and count;
- dependency/security scan result;
- platform builds actually attempted;
- database/persistence smoke-test result;
- accessibility manual-review result;
- documentation-link result;
- known limitations;
- GitHub Actions run links/ids where available.

## Current status

Evidence is intentionally **pending** until the current audit pull request workflows finish. Any discovered failure must be fixed before this ledger or `what_changed.md` can state that the corresponding quality gate passed.

**Made by the Sanskar**
