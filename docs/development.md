# Development Guide

## Working principles

QuizForge favors small, testable modules and incremental changes. Keep business rules in the domain layer, persistence details in the data layer, orchestration in the application layer, and Flutter-specific concerns in presentation.

## Daily workflow

From the repository root:

```bash
flutter pub get
flutter gen-l10n
dart format lib test tool
flutter analyze
flutter test
```

Before committing, use the non-mutating formatting gate:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

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

## Import/export changes

Treat all file/pasted content as untrusted. Parsers should:

- impose clear structure;
- reject invalid types;
- validate domain rules;
- skip or report duplicates predictably;
- return useful errors without crashing the entire import;
- avoid executing imported content;
- preserve Unicode correctly.

Add regression cases for malformed quoting, unexpected JSON types, duplicate ids/content, large fields, and relevant edge cases. Keep deterministic malformed-input/fuzz coverage in `test/data/`.

## UI development

Use the design tokens in `lib/src/core/theme/app_theme.dart`. Prefer responsive constraints and `LayoutBuilder` over hardcoded device assumptions.

Visible changes should be reviewed at compact and wide sizes, in light and dark mode, with larger text. Interactive controls must remain keyboard reachable on desktop/web and have semantic labels where their visual meaning is not self-evident.

All user-facing framework strings should come from the ARB localization resources unless they are user-authored/domain content or unavoidable platform text. Run `flutter gen-l10n` after localization changes and keep resource identifiers valid Dart identifiers rather than language keywords.

## Asynchronous work

Do not block the UI isolate with expensive parsing or processing. Current question banks are intentionally small enough for synchronous codecs; if profiling shows large imports cause frame stalls, move parsing to an isolate and record the performance threshold in `docs/performance.md`.

Use `unawaited` only when intentionally discarding a future. User-visible mutations should normally be awaited so errors can be surfaced.

## Logging

Use `AppLogger` from `lib/src/core/logging/app_logger.dart` instead of ad-hoc `print` calls. The logger emits structured JSON-like event payloads, validates event names, redacts sensitive field keys, truncates/redacts unsafe string content, and is covered by tests.

Do not log raw question prompts, answers, profile names, email addresses, import/export payloads, tokens, secrets, authorization material, cookies, or credentials. When reporting a caught exception, prefer a stable event name and a small machine-oriented field such as the exception runtime type instead of serializing arbitrary exception/user content.

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

For this Flutter application, keep `intl: any` paired with `flutter_localizations` so Flutter stable chooses its SDK-compatible `intl` version. Review and commit the application `pubspec.lock` after dependency resolution in a verified Flutter environment.

## Commit discipline

Use atomic, meaningful commits. Conventional Commit prefixes are preferred. Avoid mixing unrelated formatting churn, refactors, feature changes, and generated artifacts in a single commit.

The maintainer-requested commit email is `sanskarin@outlook.in`; configure it locally when making Git commits through a normal Git client.

## Definition of a completed change

A change is complete when relevant tests exist, format/analyze/tests pass, error states are handled, accessibility impact has been considered, documentation reflects the behavior, and no secrets/private data were introduced.
