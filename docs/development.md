# Development Guide

## Working principles

QuizForge favors small, testable modules and incremental changes. Keep business rules in the domain layer, persistence details in the data layer, orchestration in the application layer, and Flutter-specific concerns in presentation.

The maintained release-candidate line is currently `2.7.4+1`, with `v2.7.4` reserved for the exact verified release head.

## Daily workflow

From the repository root, prefer the maintained quality scripts:

```bash
./tool/check.sh
```

or on PowerShell:

```powershell
./tool/check.ps1
```

The equivalent sequence is:

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

Use `python` instead of `python3` on Windows when that is the configured launcher. The repository validators intentionally run before Flutter setup so broken documentation/localization/release metadata inputs and broken validator tests fail early.

## Release/version metadata changes

Treat version metadata as a release contract rather than a cosmetic edit.

When changing the package version:

1. update `pubspec.yaml` using `MAJOR.MINOR.PATCH+BUILD`;
2. create/update the matching dated release entry in `CHANGELOG.md` while retaining a fresh Unreleased section;
3. update the maintained package/tag identity and compatibility policy in `docs/versioning.md`;
4. update release notes/evidence documentation when applicable;
5. run `tool/test_check_release_metadata.py` and `tool/check_release_metadata.py` before Flutter work;
6. do not create/promote the public Git tag until exact-head release verification is complete.

`tool/check_release_metadata.py` validates current package/changelog/versioning consistency and rejects a stable-major documentation state that still claims a pre-1.0 policy. Its release-heading parser is regression-tested against historical zero-major entries such as `0.1.0`.

## Adding a question rule

1. Change the domain model or engine first.
2. Add unit tests that define the new rule and edge cases.
3. Update import/export behavior if the serialized shape changes.
4. Add a database migration if persistence changes.
5. Update presentation only after the domain behavior is stable.
6. Document a breaking format/schema change in the changelog.

## Adding persistence

Do not let widgets execute SQL. Add database/repository methods and expose the capability through the application controller or a focused use-case object.

Multi-step mutations must use transactions. Released schema changes must increment `schemaVersion`, include migration code, and include tests that exercise the old-to-new path.

Schema version 1 does not store the original per-answer position inside completed attempts. Code working with historical attempts must not infer play order from database row order. See `docs/local-backup.md` and `docs/architecture.md` for the backup/streak consequence of this boundary.

Changing application SemVer alone does not require a database schema increment. The 2.7.4 package update therefore retains database schema version 1 because it does not change the SQLite layout.

## Import/export and backup changes

Treat all file/pasted content as untrusted. Parsers/codecs should:

- impose clear structure;
- reject invalid types;
- validate domain rules;
- skip or report duplicates predictably where the format permits it;
- return useful errors without crashing the entire operation;
- avoid executing imported content;
- preserve Unicode correctly;
- bound input/archive resources;
- never log raw user payloads.

Add regression cases for malformed quoting, unexpected JSON types, duplicate ids/content, large fields, invalid references, non-finite numeric values, and relevant edge cases. Keep deterministic malformed-input/fuzz coverage in `test/data/`.

Question-bank JSON/CSV and complete local backup JSON are different contracts. Changes to the local backup format must preserve or explicitly reject older versions, validate the complete object graph before destructive replacement, preserve rollback behavior, and update `docs/local-backup.md`, `PRIVACY.md`, `docs/data-lifecycle.md`, tests, and the changelog.

Backup-format versioning is independent from application SemVer. QuizForge 2.7.4 continues to use local-backup format version 1.

Do not increase the backup encoder's supported output beyond what the decoder can accept. The current codec refuses to emit an archive above its supported restore limit so it cannot intentionally create an archive that the same version will reject solely for size.

For restored historical attempt data, preserve schema-v1 order limitations: the database does not store original answer sequence. Validate only order-independent streak invariants unless a future schema migration adds explicit sequence metadata.

Every restored answer row must remain consistent with normal QuizForge scoring. Backup validation re-evaluates submitted answers against the archived question and rejects correctness/score metadata that does not agree with the normal `QuizEngine` result.

## UI development

Use the design tokens in `lib/src/core/theme/app_theme.dart`. Prefer responsive constraints and `LayoutBuilder` over hardcoded device assumptions.

Visible changes should be reviewed at compact and wide sizes, in light and dark mode, with larger text. Interactive controls must remain keyboard reachable on desktop/web and have semantic labels where their visual meaning is not self-evident.

All user-facing framework strings should come from the ARB localization resources unless they are user-authored/domain content or unavoidable platform text. Run `python3 tool/check_arb_catalogs.py` and `flutter gen-l10n` after localization changes. Resource identifiers must be valid Dart identifiers rather than language keywords.

## Asynchronous work

Do not block the UI isolate with expensive parsing or processing. Current question banks are intentionally small enough for synchronous codecs; if profiling shows large imports or backups cause frame stalls, move processing to an isolate only after measuring the threshold and recording the result in `docs/performance.md`.

Use `unawaited` only when intentionally discarding a future. User-visible mutations should normally be awaited so errors can be surfaced.

## Logging

Use `AppLogger` from `lib/src/core/logging/app_logger.dart` instead of ad-hoc `print` calls. The logger emits structured JSON-like event payloads, validates event names, redacts sensitive field keys, truncates/redacts unsafe string content, and is covered by tests.

Do not log raw question prompts, answers, profile names, email addresses, import/export/backup payloads, tokens, secrets, authorization material, cookies, or credentials. When reporting a caught exception, prefer a stable event name and a small machine-oriented field such as the exception runtime type instead of serializing arbitrary exception/user content.

## Dependencies

Prefer Flutter/Dart standard libraries unless a maintained package materially reduces risk or complexity. Evaluate maintenance status, platform support, license, API scope, transitive dependencies, and security history before adding packages.

After changing dependencies:

```bash
flutter pub get
flutter pub outdated
flutter gen-l10n
flutter analyze
flutter test
```

For this Flutter application, keep `intl: any` paired with `flutter_localizations` so Flutter stable chooses its SDK-compatible `intl` version unless a future verified compatibility reason changes that policy.

Review and commit the application `pubspec.lock` after dependency resolution in a supported verified Flutter environment. Do not hand-author a lockfile. The tagged release workflow requires a committed lockfile and enforces it with `flutter pub get --enforce-lockfile`.

## Commit discipline

Use atomic, meaningful commits. Conventional Commit prefixes are preferred. Avoid mixing unrelated formatting churn, refactors, feature changes, and generated artifacts in a single commit.

The maintainer-requested commit email is `sanskarin@outlook.in`; configure it locally when making Git commits through a normal Git client.

## Definition of a completed change

A change is complete when relevant regression tests exist, repository validators pass, localization generation succeeds when applicable, format/analyze/tests pass, error states are handled, accessibility/privacy impact has been considered, documentation reflects the behavior, and no secrets/private data were introduced.

Release-candidate completion is stricter: final-head GitHub Actions/build/security gates, reviewed locked dependency state, and applicable manual platform/accessibility/data-restore checks must also be observed as successful rather than inferred from source review.
