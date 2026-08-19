# Question Bank Interchange Format

QuizForge supports JSON and CSV interchange for the **question bank**. Imports are treated as untrusted data and pass through parsing, domain validation, and duplicate detection before accepted questions are written to SQLite.

## Canonical question fields

Every question has these logical fields:

| Field | Type | Required | Notes |
|---|---|---:|---|
| `id` | string | yes | Non-empty stable identifier. Must not duplicate an existing id. |
| `type` | string enum | yes | `multipleChoice`, `trueFalse`, `multiSelect`, or `shortAnswer`. |
| `prompt` | string | yes | Non-empty question text. |
| `choices` | array of strings | depends | Required for multiple-choice/multi-select; not used for short-answer. |
| `correctAnswers` | array of strings | yes | At least one answer. Multiple choice/true-false require one logical correct answer. |
| `category` | string | yes | Non-empty category. |
| `difficulty` | string enum | yes | `easy`, `medium`, or `hard`. |
| `tags` | array of strings | no | Empty array is valid. |
| `explanation` | string | no | Empty string is valid. |
| `timeLimitSeconds` | integer/null | no | Positive integer when supplied. |

## JSON

The JSON root is an object with a `questions` array:

```json
{
  "questions": [
    {
      "id": "science-water-state",
      "type": "multipleChoice",
      "prompt": "At standard atmospheric pressure, water freezes at which Celsius temperature?",
      "choices": ["0", "10", "50", "100"],
      "correctAnswers": ["0"],
      "category": "Science",
      "difficulty": "easy",
      "tags": ["water", "temperature"],
      "explanation": "At standard atmospheric pressure, the freezing point is 0 °C.",
      "timeLimitSeconds": null
    }
  ]
}
```

The exporter emits deterministic field names and stable enum identifiers. Consumers should not assume unknown future fields are executable or trusted.

## CSV

The canonical header is:

```text
id,type,prompt,choices,correctAnswers,category,difficulty,tags,explanation,timeLimitSeconds
```

`choices`, `correctAnswers`, and `tags` are JSON arrays encoded inside their CSV cells. Standard CSV quoting is used when a value contains commas, quotes, or line breaks.

Use a QuizForge-generated export as the safest template for authoring compatible CSV.

## Validation rules

The domain model rejects structurally invalid questions, including empty ids/prompts/categories, invalid choice configuration, correct answers that do not belong to choice-based questions, and invalid time limits.

A malformed row or JSON entry is reported rather than silently converted into a different question.

## Duplicate handling

An incoming question is considered a duplicate if either:

1. its `id` already exists in the accepted/current bank; or
2. its normalized duplicate fingerprint matches existing content.

The fingerprint is based on normalized category, question type, and normalized prompt. Whitespace/casing-only edits therefore do not create a second copy.

Duplicates are skipped and reported by the import result.

## Unicode and locale

JSON and CSV text is UTF-8 in normal file/clipboard workflows. Question content is preserved as authored. QuizForge's UI localization system does not translate imported question content.

## Compatibility policy

Adding an optional field can be compatible when older readers safely ignore it or supply a documented default. Renaming/removing fields, changing enum identifiers, or changing scoring meaning is a format-breaking change and must be documented in `CHANGELOG.md` and release notes.

Before a format-breaking public release, add compatibility/migration tests and document a conversion path.
