# Contributing to QuizForge

Thank you for helping improve QuizForge.

## Development workflow

1. Fork or branch from `main`.
2. Configure Git with a real identity. Repository maintainers may use `sanskarin@outlook.in` for local commits.
3. Install Flutter stable and the platform tooling needed for your target.
4. Materialize runners when required with `flutter create . --platforms=android,ios,web,windows,macos,linux`.
5. Make one focused change at a time.
6. Add or update tests for behavior changes and bug fixes.
7. Run the maintained quality gate before opening a pull request:

```bash
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

On Windows, use the configured `python` launcher when `python3` is not the command name, or run `tool/check.ps1`. Unix-like contributors can run `tool/check.sh`.

## Release/version changes

The maintained release-candidate line is currently `2.7.4+1`, with public tag `v2.7.4` reserved for the exact verified release head.

When changing the package version:

- update `pubspec.yaml` intentionally;
- add/update the matching dated release entry in `CHANGELOG.md`;
- keep a fresh `## [Unreleased]` section;
- update the maintained package/tag identity in `docs/versioning.md`;
- update release notes/evidence when applicable;
- run `tool/test_check_release_metadata.py` and `tool/check_release_metadata.py`.

Do not hand-author `pubspec.lock`. Review and commit resolver-generated lockfile output from a supported Flutter environment.

## Commit style

Use Conventional Commit prefixes when practical:

- `feat:` user-facing capability
- `fix:` defect correction
- `test:` test-only change
- `docs:` documentation
- `refactor:` behavior-preserving restructure
- `perf:` performance change
- `ci:` automation
- `build:` build/dependency configuration
- `chore:` maintenance
- `release:` version/release-candidate metadata

Keep commits atomic and meaningful. Do not create empty commits or artificial churn to inflate history.

## Pull requests

A pull request should explain the problem, the chosen solution, testing performed, accessibility impact, privacy/security impact, and screenshots for visible UI changes when practical.

A release-candidate pull request must distinguish implemented source work from evidence that actually completed. Queued, pending, cancelled, superseded, skipped-but-applicable, or unobserved checks are not passes.

## Architecture expectations

- Keep domain rules independent from Flutter widgets and persistence details.
- Validate imported/untrusted data before storing it.
- Do not add network dependencies to core offline flows.
- Do not commit credentials, production tokens, private endpoints, personal datasets, real user backup archives, or signing keys.
- Add an ADR under `docs/adr/` for major architectural changes.
- Preserve released user data through tested migrations/format compatibility rules.

## UI and accessibility

New UI should support keyboard use where applicable, semantic labels, scalable text, light/dark themes, touch-friendly targets, reduced-motion expectations, and non-color-only status indicators.

## Questions

- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`

**Made by the Sanskar**
