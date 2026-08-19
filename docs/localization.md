# Localization

QuizForge ships English first, but user-interface copy is externalized through Flutter's generated localization system.

## Files

- `l10n.yaml` configures generation.
- `lib/l10n/app_en.arb` is the English template catalog.
- `flutter gen-l10n` generates `lib/l10n/app_localizations.dart` and locale-specific implementation files in the working tree.
- `QuizForgeApp` registers the generated delegates and supported locales.

Generated Dart localization files are build outputs. Contributors should edit ARB files rather than hand-editing generated Dart.

## Generate localizations

```bash
flutter pub get
flutter gen-l10n
```

The repository quality scripts and CI run localization generation before analysis/tests.

## Adding a language

1. Copy the English template to a locale-specific ARB such as `app_hi.arb`.
2. Change `@@locale` to the target locale.
3. Translate values without renaming message keys.
4. Preserve placeholders and ICU plural/select syntax exactly when present.
5. Run `flutter gen-l10n`.
6. Run `tool/check.sh` or `tool/check.ps1`.
7. Manually test compact/wide layouts and large text because translated strings can be substantially longer than English.
8. Test screen-reader pronunciation and reading order with the target locale where platform tooling is available.

## Product data versus interface strings

Question-bank content is user/authored data and is not translated by the application localization layer. Categories, tags, prompts, answer choices, correct answers, and explanations are preserved exactly as authored/imported.

Stable domain enum values such as `multipleChoice` and `easy` are serialized data identifiers. Presentation code should map those identifiers to localized labels rather than storing translated enum names in exports or the database.

## True/false compatibility

The persisted/scored true/false values remain stable domain values. A future translated true/false UI must map localized display labels back to those stable values before evaluation; translated display text must never become the storage/scoring identifier accidentally.

## Translation quality

Translations should be human-reviewed for meaning, accessibility, and product tone. Avoid machine-translating security/privacy/legal text without review. Contact and funding URLs are product metadata and should not be altered by translators.

## Adding new UI copy

New reusable or user-facing interface strings should be added to the ARB catalog rather than embedded directly in widgets. Short data-derived strings (user names, question text, category names, percentages, durations, and numeric values) remain dynamic.
