# Verification Evidence

This file records repeatable evidence for milestone and release audits. It is intentionally separate from product claims in the README.

## Required command set

```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
```

When platform runners are not already present in a clean checkout, generate them first as documented:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux
```

## Evidence record

For every audited milestone or release candidate, append a record containing:

- date/time and timezone;
- commit SHA;
- Flutter and Dart versions;
- host OS/architecture;
- dependency resolution result;
- format result;
- analyzer result;
- unit/widget/integration test result;
- security/dependency scan result;
- platform builds actually attempted and their results;
- known tooling limitations;
- links to relevant GitHub Actions runs when available.

A platform must not be described as release-verified unless the corresponding production/release build was actually executed successfully on a supported host.

## Current audit

The branch containing this file exists specifically to trigger the repository pull-request quality workflows against the complete current source tree. The resulting workflow evidence will be recorded in `what_changed.md` after the checks complete and any discovered defects are corrected.
