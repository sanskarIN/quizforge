# Localization

QuizForge ships English first, but user-interface copy is externalized through Flutter's generated localization system.

## Files

- `l10n.yaml` configures generation.
- `lib/l10n/app_en.arb` is the English template catalog.
- `tool/check_arb_catalogs.py` validates catalog structure and locale-key parity without requiring a Flutter SDK.
- `flutter gen-l10n` generates localization Dart sources in the configured generated output location.
- `QuizForgeApp` registers the generated delegates and supported locales.

Generated Dart localization files are build outputs. Contributors should edit ARB files rather than hand-editing generated Dart.

## Validate catalogs without Flutter

```bash
python tool/test_check_arb_catalogs.py
python tool/check_arb_catalogs.py .
```

The checker rejects malformed/duplicate JSON keys, missing locale metadata, empty/non-string messages, orphan metadata, and translation catalogs whose message-key set differs from the English template.

## Generate localizations

```bash
flutter pub get
flutter gen-l10n
```

The repository quality workflow validates ARB catalogs before installing Flutter and then exercises Flutter's generated localization path before analysis/tests.

## Adding a language

1. Copy the English template to a locale-specific ARB such as `app_hi.arb`.
2. Change `@@locale` to the target locale.
3. Translate values without renaming message keys.
4. Preserve placeholders and ICU plural/select syntax exactly when present.
5. Run `python tool/check_arb_catalogs.py .`.
6. Run `flutter gen-l10n`.
7. Run `tool/check.sh` or `tool/check.ps1`.
8. Manually test compact/wide layouts and large text because translated strings can be substantially longer than English.
9. Test screen-reader pronunciation and reading order with the target locale where platform tooling is available.

## Product data versus interface strings

Question-bank content is user/authored data and is not translated by the application localization layer. Categories, tags, prompts, answer choices, correct answers, and explanations are preserved exactly as authored/imported.

Stable domain enum values such as `multipleChoice` and `easy` are serialized data identifiers. Presentation code should map those identifiers to localized labels rather than storing translated enum names in exports or the database.

## True/false compatibility

The persisted/scored true/false values remain stable domain values. A future translated true/false UI must map localized display labels back to those stable values before evaluation; translated display text must never become the storage/scoring identifier accidentally.

## Translation quality

Translations should be human-reviewed for meaning, accessibility, and product tone. Avoid machine-translating security/privacy/legal text without review. Contact and funding URLs are product metadata and should not be altered by translators.

## Adding new UI copy

New reusable or user-facing interface strings should be added to the ARB catalog rather than embedded directly in widgets. Short data-derived strings (user names, question text, category names, percentages, durations, and numeric values) remain dynamic.
