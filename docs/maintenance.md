# Maintenance Guide

This guide describes routine maintenance after the initial QuizForge baseline is established. The maintained release-candidate line is currently `2.7.4+1` / intended tag `v2.7.4`.

## Weekly / dependency update work

- Review Dependabot pull requests individually.
- Read dependency release notes for behavior/security changes.
- Run repository validator tests/validators before Flutter work.
- Run localization generation, formatting, analysis, tests, and relevant builds.
- Do not batch unrelated major upgrades merely to reduce pull-request count.
- Reject dependencies that add unnecessary permissions, telemetry, or network behavior.
- Review the resolver-generated `pubspec.lock` rather than hand-authoring dependency state.

## Monthly health review

Review:

- open issues and pull requests;
- CI reliability and flaky-test signals;
- dependency/security alerts;
- documentation links and setup instructions;
- package/changelog/versioning consistency;
- supported Flutter/Dart toolchain status;
- performance measurements if user-visible regressions are reported;
- accessibility regressions in recently changed flows;
- whether release evidence still refers to the exact current candidate head.

## Flutter upgrades

Treat Flutter SDK upgrades as product changes, not a blind generated-file refresh.

1. read the Flutter/Dart migration notes;
2. create a dedicated upgrade branch;
3. update SDK constraints only when required;
4. run repository validators;
5. run `flutter pub get` and review the lockfile diff;
6. regenerate localization output;
7. update platform runners only when needed;
8. inspect Android/iOS/macOS/Windows/Linux/Web generated diffs;
9. run the complete automated suite;
10. run all platform build gates;
11. manually smoke-test core quiz/create/import/settings/backup flows;
12. update documentation if toolchain requirements changed.

## Dependency removal

Prefer deleting a dependency when the same behavior can be implemented clearly using Flutter/Dart/OS APIs already present. Removing a dependency requires the same build/test review as adding one because platform registrants/generated files can change.

## Database maintenance

Never change a released schema by only editing the create-table SQL. Use explicit migrations and migration tests. Back up representative fictional fixtures for migration tests rather than real user data.

Application SemVer and database schema version are separate contracts. QuizForge 2.7.4 currently remains on database schema version 1 because the release-candidate version change does not alter the SQLite layout.

## Import/export and backup maintenance

Parser/codec changes need regression cases for:

- previous valid exports;
- malformed input;
- Unicode;
- quoted CSV fields;
- duplicate semantics;
- resource boundaries;
- invalid backup references/aggregates;
- answer-scoring integrity;
- any newly introduced optional field.

Question-bank formats and whole-app local backup are separate contracts. Local-backup versioning is independent from application SemVer; QuizForge 2.7.4 currently uses local-backup format version 1.

If a format change is not backward compatible, document and test a conversion path or explicit unsupported-version failure before release.

## Localization maintenance

New user-facing interface copy belongs in ARB resources. Keep domain/storage identifiers language-neutral and stable. Run `tool/test_check_arb_catalogs.py`, `tool/check_arb_catalogs.py`, and `flutter gen-l10n`, then review translations for layout/accessibility impact.

## Release metadata maintenance

Before a version/tag change is accepted:

- update `pubspec.yaml` with `MAJOR.MINOR.PATCH+BUILD`;
- update the matching dated `CHANGELOG.md` entry and keep an Unreleased section;
- update the maintained package/tag identity and compatibility policy in `docs/versioning.md`;
- run `tool/test_check_release_metadata.py`;
- run `tool/check_release_metadata.py`;
- update release notes and evidence documentation as applicable.

The release-metadata validator deliberately recognizes historical zero-major releases and rejects a stable-major project whose versioning guide still claims a pre-1.0 policy.

## Security maintenance

When a vulnerability is reported:

- follow `SECURITY.md`;
- avoid public disclosure of exploit details before a fix is available;
- add a regression test when technically practical;
- rotate any exposed credential outside the repository immediately;
- document user impact and upgrade advice in the security release.

Any future networking, cloud sync, authentication, analytics, advertising, or payment capability requires an updated threat model/privacy review before merge.

## Release maintenance

Keep these synchronized with real repository state:

- `pubspec.yaml`;
- `CHANGELOG.md`;
- `ROADMAP.md`;
- `docs/versioning.md`;
- `docs/release.md`;
- release-specific notes such as `docs/release-notes-2.7.4.md`;
- `docs/verification.md`;
- `what_changed.md`.

Do not preserve an old “passing” statement after code has changed without re-running the corresponding gate on the new exact head. A queued, pending, cancelled, superseded, skipped-but-applicable, or unobserved check is not a pass.

## Commit discipline

Continue using small, reviewable Conventional Commit-style changes. A high commit count is useful only when each commit represents a coherent engineering step. Avoid empty commits, churn-only changes, or splitting inseparable code/test updates purely to inflate history.
