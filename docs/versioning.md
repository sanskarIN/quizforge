# Versioning and Compatibility

QuizForge uses Semantic Versioning for public releases.

## Version format

Application/package versions use `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`.

- **MAJOR**: incompatible public data-format, storage, or behavior changes that cannot be delivered with a reasonable compatibility path.
- **MINOR**: backward-compatible user-facing features and substantial capabilities.
- **PATCH**: backward-compatible fixes, security hardening, accessibility improvements, and documentation/release corrections.
- **BUILD**: platform/store build number where required. The build suffix is not part of the public SemVer tag.

Git release tags omit the Flutter build suffix and use `vMAJOR.MINOR.PATCH`, for example `v2.7.4`.

The maintained release-candidate line currently targets **2.7.4+1**. The in-app public version shown by `AppConstants.version` is **2.7.4**, and the intended public Git tag is **`v2.7.4`**. A later store rebuild of the same public 2.7.4 release may increment only the build suffix when no public SemVer behavior changes.

`tool/check_release_metadata.py` enforces that the public `pubspec.yaml` version, `AppConstants.version`, dated changelog entry, and maintained package/tag documentation agree before Flutter setup.

## Post-1.0 compatibility policy

QuizForge 2.x is a stable-version line. Public compatibility boundaries must therefore be treated as release contracts rather than experimental interfaces.

A backward-compatible 2.x release may add optional fields, features, validations, or UI capabilities, but must not silently invalidate previously released user data. Any intentionally incompatible public storage/data-format behavior requires a new major version unless a documented migration preserves compatibility.

Released questions, profiles, attempts, bookmarks, settings, and supported backup/question-bank formats must be handled according to the migration and format policies below.

## Database compatibility

The SQLite schema has an explicit version. After a schema has shipped publicly:

1. increment `schemaVersion` for schema changes;
2. implement a forward migration;
3. add migration tests using a representation of every supported previous released schema;
4. preserve user data unless release notes explicitly document an unavoidable conversion/loss scenario;
5. never edit an old released schema in place and assume users start from an empty database.

Downgrade support is not implied. If a new release makes the database unreadable by an older release, document that fact before release.

The current database schema remains version 1. Changing the application version to 2.7.4 does **not** by itself require a schema version increment because no schema layout change is introduced by the version metadata update.

## Local-backup compatibility

The whole-app local-backup format has its own explicit format version and is not coupled directly to the application SemVer number.

- Application 2.7.4 continues to use local-backup format version 1.
- A future application release may remain compatible with backup version 1 even when its application SemVer changes.
- A breaking backup-layout change must use a new backup format version and either provide a tested conversion path or fail closed with a clear unsupported-version error.
- Existing supported backup versions must not be reinterpreted with incompatible semantics.

See [`local-backup.md`](local-backup.md).

## Question-bank interchange compatibility

Stable serialized identifiers include question type and difficulty enum names. UI translations must never replace these identifiers in JSON/CSV storage.

A format change is compatibility-sensitive when it:

- removes or renames a required field;
- changes a field type;
- changes enum identifiers;
- changes answer/scoring meaning;
- changes duplicate semantics in a way that can silently discard previously distinct questions.

New optional fields should have documented defaults for older data where possible.

## Multiplayer protocol compatibility

The current network transport is disabled by default. A future real private-room protocol must have its own explicit protocol version and compatibility rules before release.

## Release checklist

Before tagging `v2.7.4` or any later release:

- `pubspec.yaml`, `AppConstants.version`, and the Git tag public version must agree;
- `tool/test_check_release_metadata.py` and `tool/check_release_metadata.py` must pass;
- the application lockfile must be generated, reviewed, committed, and accepted by locked dependency resolution;
- `CHANGELOG.md` must contain the dated release entry;
- database migrations must be tested from every supported previous release baseline when the schema changes;
- question-bank and backup compatibility changes must be documented;
- formatting, analysis, automated tests, applicable platform builds, dependency review, vulnerability scanning, and secret scanning must pass on the exact release head;
- required manual platform/accessibility/data-restoration checks must be recorded where automation cannot establish them;
- `what_changed.md` and `docs/verification.md` must reflect actual evidence rather than planned work.

See [`release.md`](release.md) for the complete release process.
