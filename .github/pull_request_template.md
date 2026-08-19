## Problem

<!-- What user/developer problem does this change solve? -->

## Solution

<!-- Describe the focused implementation and important tradeoffs. -->

## Verification

- [ ] `python3 tool/test_check_markdown_links.py`
- [ ] `python3 tool/test_check_arb_catalogs.py`
- [ ] `python3 tool/test_check_release_metadata.py`
- [ ] `python3 tool/check_markdown_links.py`
- [ ] `python3 tool/check_arb_catalogs.py`
- [ ] `python3 tool/check_release_metadata.py`
- [ ] `flutter gen-l10n`
- [ ] `dart format --output=none --set-exit-if-changed lib test tool`
- [ ] `flutter analyze`
- [ ] `flutter test --coverage`
- [ ] Relevant platform build/run checked when the change affects platform behavior

Use `python` instead of `python3` on Windows when that is the configured launcher. `tool/check.sh` / `tool/check.ps1` provide the maintained local sequence.

## Quality review

- [ ] Tests cover new behavior or the bug regression.
- [ ] Error/loading/empty states are handled where applicable.
- [ ] Accessibility impact was reviewed (keyboard, semantics, scalable text, non-color cues, reduced motion).
- [ ] Privacy/security impact was reviewed.
- [ ] No credentials, signing secrets, private endpoints, personal data, or real user backup archives are included.
- [ ] Database/data-format changes include migration/compatibility notes where required.
- [ ] Package-version changes keep `pubspec.yaml`, `AppConstants.version`, `CHANGELOG.md`, `docs/versioning.md`, and release evidence synchronized.
- [ ] Dependency changes include a resolver-generated/reviewed lockfile when the application lockfile is maintained by the branch.
- [ ] Documentation and `CHANGELOG.md` are updated when user-visible behavior changed.

## Release-candidate evidence

<!-- Complete only when this PR is part of a release candidate. -->

- [ ] Exact-head required checks have actually completed successfully; queued/pending/superseded runs are not counted as passes.
- [ ] Any required manual platform, backup/persistence, accessibility, and screenshot evidence is recorded in `docs/verification.md`.

## Screenshots / recordings

<!-- Add sanitized captures for visible UI changes when practical. Do not attach real backup archives or private quiz-history data. -->

## Additional notes

<!-- Known limitations, follow-up work, or ADR links. -->
