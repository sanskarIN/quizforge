# Versioning and Compatibility

QuizForge uses Semantic Versioning for public releases.

## Version format

Application/package versions use `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`.

- **MAJOR**: incompatible public data-format, storage, or behavior changes that cannot be delivered with a reasonable compatibility path.
- **MINOR**: backward-compatible user-facing features and substantial capabilities.
- **PATCH**: backward-compatible fixes, security hardening, accessibility improvements, and documentation/release corrections.
- **BUILD**: platform/store build number where required.

Git release tags omit the Flutter build suffix and use `vMAJOR.MINOR.PATCH`, for example `v0.1.0`.

## Pre-1.0 policy

While QuizForge remains below 1.0, public interfaces can evolve more quickly, but released user data must still be handled responsibly. A pre-1.0 version is not permission to silently discard a user's questions, profiles, attempts, or bookmarks.

## Database compatibility

The SQLite schema has an explicit version. After a schema has shipped publicly:

1. increment `schemaVersion` for schema changes;
2. implement a forward migration;
3. add migration tests using a representation of the previous released schema;
4. preserve user data unless the release notes explicitly document an unavoidable conversion/loss scenario;
5. never edit an old released schema in place and assume users start from an empty database.

Downgrade support is not implied. If a new release makes the database unreadable by an older release, document that fact.

## Question-bank interchange compatibility

Stable serialized identifiers include question type and difficulty enum names. UI translations must never replace these identifiers in JSON/CSV storage.

A format change is compatibility-sensitive when it:

- removes/renames a required field;
- changes a field type;
- changes enum identifiers;
- changes answer/scoring meaning;
- changes duplicate semantics in a way that can silently discard previously distinct questions.

New optional fields should have documented defaults for older data where possible.

## Multiplayer protocol compatibility

The current network transport is disabled by default. A future real private-room protocol must have its own explicit protocol version and compatibility rules before release.

## Release checklist

Before tagging:

- version and tag must agree;
- `CHANGELOG.md` must contain the release entry;
- database migrations must be tested from every supported previous release baseline;
- question-bank compatibility changes must be documented;
- build and security gates must pass;
- `what_changed.md` must reflect actual evidence, not planned work.

See [`release.md`](release.md) for the complete release process.
