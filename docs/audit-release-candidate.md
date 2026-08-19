# Release Candidate Audit Marker — 0.1.0

This branch exists only to trigger the repository's current pull-request quality, build, and dependency-review workflows against the latest `main` baseline.

No production behavior is intentionally changed by this file.

## Required pull-request checks

- Flutter localization generation
- Dart format verification
- Flutter static analysis
- automated tests with coverage
- Android debug build gate
- Web release build gate
- dependency review

A green audit does not replace the remaining native-host release builds, signed distribution packaging, real screenshot capture, or manual accessibility review documented in `what_changed.md` and `docs/verification.md`.

**Made by the Sanskar**
