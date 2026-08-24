# QuizForge Manual Release Verification Report Template

Use this template for evidence that cannot be established by source review or compile-only GitHub Actions jobs. Copy it for a specific release candidate and fill only observations that were actually performed.

Do not use real user data. Use fictional/demo questions, profiles, attempts, and backup archives. Do not paste signing credentials, tokens, private certificates, keystore passwords, provisioning profiles, or raw private backup payloads into the report.

## Candidate identity

- Public version:
- Package/build version:
- Git commit SHA:
- Intended tag:
- Tester/date/time zone:
- Flutter version:
- Dart version:
- Database schema version:
- Local-backup format version:
- Canonical application/bundle identity observed:

The commit SHA is mandatory. Evidence from a different SHA is historical evidence, not exact-candidate evidence.

## Target environment

- Platform:
- OS/version:
- Device/model or VM/browser:
- Architecture:
- Installation/package method:
- Build artifact/source:
- Signing/provisioning state, described without secrets:

## Branding and launch

- [ ] Launcher/application icon is QuizForge-branded and recognizable.
- [ ] Icon mask/crop is acceptable for the target shell/launcher.
- [ ] Launch/splash artwork is centered and not clipped.
- [ ] Window/taskbar/Dock/Finder/desktop icon surfaces are correct where applicable.
- [ ] Installed application identity matches `io.github.sanskarin.quizforge` where exposed by the target.

Observed notes:

## Startup and persistence

- [ ] Application starts successfully from a clean local state.
- [ ] Local database is created successfully.
- [ ] Fictional starter/default state is initialized as documented.
- [ ] A fictional local profile can be created or selected.
- [ ] A quiz can be completed and reviewed.
- [ ] Progress/recent history persists after application restart or browser reload.
- [ ] Settings persist after restart/reload.
- [ ] Bookmarks remain isolated to the expected local profile.

Observed notes:

## Question-bank portability

- [ ] JSON export succeeds.
- [ ] JSON re-import succeeds as expected.
- [ ] CSV export succeeds.
- [ ] CSV re-import succeeds as expected.
- [ ] Duplicate handling is understandable and safe.
- [ ] Malformed input fails without crashing or exposing raw sensitive payloads.
- [ ] Clipboard behavior works on this target where supported.

Observed notes:

## Complete local backup restore

Create fictional state containing at minimum one custom question, two local profiles, one bookmark, one completed attempt, non-default settings, and a non-default active profile.

- [ ] Complete local backup export succeeds.
- [ ] Backup is stored temporarily in a tester-controlled location.
- [ ] Current local state is intentionally mutated/reset.
- [ ] Restore requires the documented destructive-replacement confirmation.
- [ ] Restore succeeds.
- [ ] Questions return.
- [ ] Profiles return.
- [ ] Active-profile selection returns.
- [ ] Bookmark state returns.
- [ ] Progress and recent history return.
- [ ] Settings return.
- [ ] Malformed/unsupported backup fails safely.
- [ ] Failure UI/logging does not expose the raw archive.
- [ ] Temporary fictional backup evidence is removed when no longer needed.

Observed notes:

## Web-only runtime checks

Complete this section for Web; otherwise mark it not applicable.

- [ ] `sqlite3.wasm` loads successfully.
- [ ] `drift_worker.js` loads successfully.
- [ ] WebAssembly is served with correct MIME behavior.
- [ ] Database create/write/read succeeds in a real browser.
- [ ] Refresh preserves expected local state.
- [ ] Full browser reload preserves expected local state.
- [ ] Browser storage behavior is acceptable for the tested deployment context.
- [ ] Complete backup restore succeeds in the built/deployed Web application.

Browser/deployment notes:

## Accessibility and interaction

- [ ] Keyboard navigation reaches all applicable primary controls.
- [ ] Visible focus is clear on keyboard-capable targets.
- [ ] Representative screen-reader labels/semantics are understandable.
- [ ] Large text / OS or browser scaling remains usable.
- [ ] Reduced-motion preference behavior is acceptable.
- [ ] Light and dark themes remain legible.
- [ ] Correct/incorrect/status meaning is not communicated by color alone.
- [ ] Touch targets/interactions are usable on distributed mobile targets.

Observed notes:

## External links and About

- [ ] Project/support links open the expected destination.
- [ ] About screen reports the intended public version.
- [ ] Required project credit is present.

Observed notes:

## Screenshot evidence

Screenshots must come from the actual tested build and use fictional/demo data.

- [ ] Home/dashboard capture.
- [ ] Quiz play/review capture.
- [ ] Question bank/creator capture.
- [ ] Statistics/progress capture.
- [ ] Settings/About capture.
- [ ] Dark-theme or accessibility-oriented representative capture where appropriate.

Evidence file names/locations:

## Distribution-specific checks

- Android signing/store state:
- iOS signing/provisioning state:
- macOS signing/notarization state:
- Windows packaging/signing state:
- Linux package/desktop integration state:
- Web hosting/cache/header state:

Never copy secret values into this report.

## Failures discovered

For every failure, record:

- target and exact candidate SHA;
- reproducible steps using fictional data;
- expected behavior;
- observed behavior;
- whether the failure is product, packaging, platform-integration, or environment-specific;
- linked issue/commit when available.

A failed applicable item blocks release verification until resolved or explicitly documented as an accepted limitation with appropriate release-scope consequences.

## Final target decision

- Target tested:
- Result: PASS / FAIL / PARTIAL / NOT DISTRIBUTED
- Exact candidate SHA:
- Evidence reviewer:
- Remaining limitations:

`PASS` means all applicable items for that target were actually performed successfully. `PARTIAL` must never be reported as a full target verification.

**Made by the Sanskar**
