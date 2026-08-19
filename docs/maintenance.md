# Maintenance Guide

This guide describes routine maintenance after the initial QuizForge baseline is established.

## Weekly / dependency update work

- Review Dependabot pull requests individually.
- Read dependency release notes for behavior/security changes.
- Run localization generation, formatting, analysis, tests, and relevant builds.
- Do not batch unrelated major upgrades merely to reduce pull-request count.
- Reject dependencies that add unnecessary permissions, telemetry, or network behavior.

## Monthly health review

Review:

- open issues and pull requests;
- CI reliability and flaky-test signals;
- dependency/security alerts;
- documentation links and setup instructions;
- supported Flutter/Dart toolchain status;
- performance measurements if user-visible regressions are reported;
- accessibility regressions in recently changed flows.

## Flutter upgrades

Treat Flutter SDK upgrades as product changes, not a blind generated-file refresh.

1. read the Flutter/Dart migration notes;
2. create a dedicated upgrade branch;
3. update SDK constraints only when required;
4. run `flutter pub get` and review the lockfile diff;
5. regenerate localization output;
6. update platform runners only when needed;
7. inspect Android/iOS/macOS/Windows/Linux/Web generated diffs;
8. run the complete automated suite;
9. run all platform build gates;
10. manually smoke-test core quiz/create/import/settings flows;
11. update documentation if toolchain requirements changed.

## Dependency removal

Prefer deleting a dependency when the same behavior can be implemented clearly using Flutter/Dart/OS APIs already present. Removing a dependency requires the same build/test review as adding one because platform registrants/generated files can change.

## Database maintenance

Never change a released schema by only editing the create-table SQL. Use explicit migrations and migration tests. Back up representative fictional fixtures for migration tests rather than real user data.

## Import/export maintenance

Parser changes need regression cases for:

- previous valid exports;
- malformed input;
- Unicode;
- quoted CSV fields;
- duplicate semantics;
- any newly introduced optional field.

If a format change is not backward compatible, document a conversion path before release.

## Localization maintenance

New user-facing interface copy belongs in ARB resources. Keep domain/storage identifiers language-neutral and stable. Run `flutter gen-l10n` in CI and review translations for layout/accessibility impact.

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

- `CHANGELOG.md`;
- `ROADMAP.md`;
- `docs/release.md`;
- `docs/verification.md`;
- `what_changed.md`.

Do not preserve an old “passing” statement after code has changed without re-running the corresponding gate.

## Commit discipline

Continue using small, reviewable Conventional Commit-style changes. A high commit count is useful only when each commit represents a coherent engineering step. Avoid empty commits, churn-only changes, or splitting inseparable code/test updates purely to inflate history.
