# Security Policy

Security and privacy are part of QuizForge's definition of done.

## Supported versions

Security fixes are applied to the latest released version and the current `main` branch. Older releases may receive fixes only when the issue is severe and a backport is practical.

## Reporting a vulnerability

Please do **not** open a public issue for an unpatched vulnerability or for a report that contains sensitive reproduction data.

Report security concerns privately to:

- `supportramsandesh@gmail.com`
- `sanskarin@outlook.in`

Include, when available:

- affected version or commit;
- affected platform;
- concise impact description;
- minimal reproduction steps;
- relevant logs with secrets and personal data removed;
- suggested mitigation, if you have one.

Do not include credentials, private user data, authentication tokens, production secrets, or unrelated personal information in a report.

## Scope

Security-relevant areas include:

- JSON/CSV import parsing and validation;
- local SQLite persistence and migrations;
- exported question-bank data;
- filesystem or platform permissions;
- future private-room networking transports;
- dependency and build-pipeline integrity;
- accidental credential or personal-data exposure.

The current core app is offline-first and does not require accounts, payment processing, or a production backend.

## Secure-development expectations

Contributions should:

- validate all untrusted imported data before persistence;
- avoid custom cryptography and home-grown authentication primitives;
- keep secrets out of source control;
- avoid logging tokens, credentials, raw private data, or authentication headers;
- use least-privilege platform permissions;
- pin or lock dependencies through normal Flutter tooling;
- add a regression test when fixing a security defect where practical.

## Coordinated disclosure

Maintainers will assess credible reports, reproduce them where possible, prepare a fix, add regression coverage, and publish release notes appropriate to the risk. Public disclosure should occur after a fix is available or after coordination with maintainers.

## Out of scope

Reports that require intentionally modifying the user's own local database with unrestricted device access, social engineering without a product vulnerability, or issues in unsupported third-party software without a QuizForge-specific impact may be closed as out of scope.

**Made by the Sanskar**
