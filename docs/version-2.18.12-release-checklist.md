# QuizForge 2.18.12 Release Checklist

This checklist is a future release gate. It does not supersede the current 2.7.4 verification ledger and must not be marked complete before the corresponding evidence exists.

## Release identity

- [ ] `pubspec.yaml` intentionally declares the 2.18.12 package/build identity.
- [ ] `AppConstants.version` matches public version `2.18.12`.
- [ ] About/version widget coverage expects 2.18.12.
- [ ] `CHANGELOG.md` contains a dated 2.18.12 entry and a fresh Unreleased section.
- [ ] `docs/versioning.md` identifies the maintained package version and intended tag `v2.18.12`.
- [ ] Release metadata regression tests and validator pass.

## Data compatibility

- [ ] Database schema version is unchanged unless an actual schema change requires a migration.
- [ ] Every schema change has clean-create and previous-schema migration tests.
- [ ] Local-backup format version is unchanged unless the archive contract actually changes.
- [ ] Any backup-format change explicitly handles old-version compatibility or rejection.
- [ ] Existing 2.7.4-compatible local data is exercised through the documented upgrade path.
- [ ] Shareable quiz packs, if implemented, remain content-only and distinct from complete private backups.

## Security and privacy

- [ ] Imported files/packs/backups are treated as untrusted and resource-bounded.
- [ ] Logs contain no raw profile names, authored question content, submitted answers, backup payloads, tokens, credentials, or signing material.
- [ ] Dependency Review succeeds on the exact final head.
- [ ] OSV Vulnerability Scan succeeds on the exact final head.
- [ ] Full-history Secret Scan succeeds on the exact final head.
- [ ] Optional network transport, if enabled, has authorization, malformed-message, timeout, replay/duplication, disconnect, privacy, and abuse-case coverage.

## Repository tooling

- [ ] Markdown validator regression tests pass.
- [ ] ARB validator regression tests pass.
- [ ] Release-metadata validator regression tests pass.
- [ ] Web runtime validator regression tests pass.
- [ ] Platform-branding regression tests pass.
- [ ] Generated-runner contract regression tests pass.
- [ ] Repository-local Markdown links pass.
- [ ] ARB catalogs pass structural validation.
- [ ] Release metadata is consistent.
- [ ] Generated-runner contract remains consistent with canonical identity `io.github.sanskarin.quizforge`.

## Flutter source quality

- [ ] Supported Flutter stable toolchain is recorded.
- [ ] `flutter pub get --enforce-lockfile` succeeds.
- [ ] Resolver files remain unchanged after locked resolution.
- [ ] `flutter gen-l10n` succeeds.
- [ ] `dart format --output=none --set-exit-if-changed lib test tool` succeeds.
- [ ] `flutter analyze` reports no issues.
- [ ] All unit/widget/integration/application tests pass.
- [ ] New feature regressions are covered at the appropriate domain/data/application/widget layer.

## Android

- [ ] Generated runner uses canonical application id.
- [ ] Deterministic launcher/splash branding check passes.
- [ ] Release APK builds.
- [ ] Release AAB builds when distributed through a store.
- [ ] Database creation and persistence survive restart.
- [ ] Question-bank file/clipboard exchange works as applicable.
- [ ] Complete local-backup export/mutate/restore succeeds with fictional data.
- [ ] Launcher/splash appearance is visually reviewed.
- [ ] Signing/store setup is completed outside public source control where required.

## Web

- [ ] Generated runner/branding contract passes.
- [ ] Drift `sqlite3.wasm` and worker assets are prepared and packaged.
- [ ] Release Web bundle builds.
- [ ] Deployed server uses correct WebAssembly MIME behavior.
- [ ] Real-browser database create/write/read succeeds.
- [ ] Refresh/reload persistence succeeds.
- [ ] Question-bank file/clipboard exchange works as applicable.
- [ ] Complete local-backup export/mutate/restore succeeds with fictional data.
- [ ] Browser accessibility/keyboard/focus behavior is reviewed.

## Windows

- [ ] Generated runner/branding/canonical identity contract passes.
- [ ] Release build succeeds.
- [ ] Local database persistence/core quiz flow succeeds.
- [ ] File/clipboard exchange works as applicable.
- [ ] Complete-backup smoke restore succeeds where the target is distributed.
- [ ] Packaging/installer and signing decisions are documented.

## macOS

- [ ] Generated runner uses canonical bundle identifier.
- [ ] Deterministic icon branding passes structural checks.
- [ ] Release build succeeds.
- [ ] Local persistence/core quiz flow succeeds.
- [ ] Complete-backup smoke restore succeeds where distributed.
- [ ] Signing/notarization is completed externally when required.

## Linux

- [ ] Generated runner/branding contract passes.
- [ ] Release build succeeds.
- [ ] Local persistence/core quiz flow succeeds.
- [ ] Linux desktop metadata/icon integration matches the chosen package format.
- [ ] Complete-backup smoke restore succeeds where distributed.

## iOS

- [ ] Generated runner uses canonical bundle identifier.
- [ ] AppIcon/launch artwork passes structural checks.
- [ ] No-codesign release compile succeeds in CI.
- [ ] Signed/device validation is completed externally if iOS is distributed.
- [ ] Persistence, backup restore, and touch interaction are exercised on representative hardware/simulator as applicable.

## Accessibility and UX

- [ ] Keyboard navigation and visible focus are reviewed on desktop/Web.
- [ ] Screen-reader semantics are reviewed on representative targets.
- [ ] Large-text behavior is reviewed with OS/browser scaling.
- [ ] Reduced-motion behavior is reviewed.
- [ ] Light/dark contrast and non-color-only result cues are reviewed.
- [ ] New localization catalogs are reviewed for long text and layout expansion.
- [ ] Verified screenshots come from actual candidate builds using fictional/demo data.

## Performance

- [ ] Representative hardware/OS/toolchain details are recorded.
- [ ] Large-bank selection benchmark is recorded.
- [ ] Import/export/pack codec performance is recorded.
- [ ] Backup encode/decode/validation performance is recorded.
- [ ] Statistics-query performance is recorded.
- [ ] Any optimization has before/after evidence and regression coverage where practical.

## Final promotion

- [ ] Exact final-head CI is green.
- [ ] Exact final-head Build Gate is green.
- [ ] Exact final-head Platform Build Matrix is green.
- [ ] Exact final-head Dependency Review is green.
- [ ] Exact final-head OSV scan is green.
- [ ] Exact final-head Secret Scan is green.
- [ ] Required manual release-host evidence is recorded.
- [ ] Release notes state actual verified platform scope and signing state.
- [ ] `v2.18.12` is created/promoted only after every applicable blocker above is cleared.

**Made by the Sanskar**
