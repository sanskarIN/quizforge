# Development Guide

## Working principles

QuizForge favors small, testable modules and incremental changes. Keep business rules in the domain layer, persistence details in the data layer, orchestration in the application layer, and Flutter-specific concerns in presentation.

## Daily workflow

From the repository root:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Before committing, use the non-mutating formatting gate:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Documentation/localization repository checks do not require Flutter. On macOS/Linux:

```bash
sh tool/check_docs.sh
```

On Windows PowerShell:

```powershell
./tool/check_docs.ps1
```

Set `PYTHON_BIN` if your Python executable uses a different name.

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

Add regression cases for malformed quoting, unexpected JSON types, duplicate ids/content, large fields, and relevant edge cases.

## Localization changes

Before generating localization Dart sources, run:

```bash
python tool/check_arb_catalogs.py .
```

All locale catalogs must retain the English template's message-key set. Do not rename stable message keys merely to improve translated wording.

## Documentation links

Repository-local Markdown targets are validated by `tool/check_markdown_links.py` and CI. The checker intentionally does not make network requests; external-site health remains part of release/manual review.

## UI development

Use the design tokens in `lib/src/core/theme/app_theme.dart`. Prefer responsive constraints and `LayoutBuilder` over hardcoded device assumptions.

Visible changes should be reviewed at compact and wide sizes, in light and dark mode, with larger text. Interactive controls must remain keyboard reachable on desktop/web and have semantic labels where their visual meaning is not self-evident.

## Asynchronous work

Do not block the UI isolate with expensive parsing or processing. Current question banks are intentionally small enough for synchronous codecs; if profiling shows large imports cause frame stalls, move parsing to an isolate and record the performance threshold in `docs/performance.md`.

Use `unawaited` only when intentionally discarding a future. User-visible mutations should normally be awaited so errors can be surfaced.

## Logging

Do not use ad-hoc `print` calls in application code. The structured logger should redact secrets, authentication material, and user-authored content by default.

## Dependencies

Prefer Flutter/Dart standard libraries unless a maintained package materially reduces risk or complexity. Evaluate maintenance status, platform support, license, API scope, transitive dependencies, and security history before adding packages.

After changing dependencies:

```bash
flutter pub get
flutter pub outdated
flutter analyze
flutter test
```

## Commit discipline

Use atomic, meaningful commits. Conventional Commit prefixes are preferred. Avoid mixing unrelated formatting churn, refactors, feature changes, and generated artifacts in a single commit.

The maintainer-requested commit email is `sanskarin@outlook.in`; configure it locally when making Git commits through a normal Git client.

## Definition of a completed change

A change is complete when relevant tests exist, format/analyze/tests pass, error states are handled, accessibility impact has been considered, documentation reflects the behavior, and no secrets/private data were introduced.
