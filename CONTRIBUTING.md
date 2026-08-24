# Contributing to QuizForge

Thank you for helping improve QuizForge.

## Development workflow

1. Fork or branch from `main`.
2. Configure Git with a real identity. Repository maintainers may use `sanskarin@outlook.in` for local commits.
3. Install Flutter stable and the platform tooling needed for your target.
4. When runners are required, materialize them with the canonical organization and without an implicit package-resolution pass:

```bash
flutter create . --platforms=android,ios,web,windows,macos,linux --org io.github.sanskarin --no-pub
git restore --source=HEAD -- pubspec.yaml pubspec.lock analysis_options.yaml
python3 tool/check_platform_runner_contract.py
```

5. Make one focused change at a time.
6. Add or update tests for behavior changes and bug fixes.
7. Run the maintained quality gate before opening a pull request:

```bash
python3 tool/test_check_markdown_links.py
python3 tool/test_check_arb_catalogs.py
python3 tool/test_check_release_metadata.py
python3 tool/test_prepare_web_assets.py
python3 tool/test_generate_platform_branding.py
python3 tool/test_check_platform_runner_contract.py
python3 tool/check_markdown_links.py
python3 tool/check_arb_catalogs.py
python3 tool/check_release_metadata.py
python3 tool/check_platform_runner_contract.py
flutter pub get --enforce-lockfile
git diff --exit-code -- pubspec.yaml pubspec.lock analysis_options.yaml
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --coverage
```

On Windows, use the configured `python` launcher when `python3` is not the command name, or run `tool/check.ps1`. Unix-like contributors can run `tool/check.sh`.

Generated runners must use organization `io.github.sanskarin`, yielding canonical application/bundle identity `io.github.sanskarin.quizforge` where applicable. Do not commit or release Flutter's `com.example` default. Project recreation can remove/reset reviewed package metadata even with `--no-pub`, which is why the documented runner sequence restores `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml` from `HEAD` before locked dependency resolution.

Normal verification must not silently regenerate `pubspec.lock`. Intentional dependency changes are separate maintenance work: update `pubspec.yaml`, regenerate the lockfile in a supported Flutter environment, review its full diff, then rerun the locked quality gate before committing.

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

Changing a previously distributed application/bundle identifier is not routine metadata cleanup; it can change installed-app and local-storage identity and must be treated as a compatibility/migration decision.

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
- Preserve the generated-runner contract unless a reviewed compatibility decision intentionally changes it.

## UI and accessibility

New UI should support keyboard use where applicable, semantic labels, scalable text, light/dark themes, touch-friendly targets, reduced-motion expectations, and non-color-only status indicators.

## Questions

- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`

**Made by the Sanskar**