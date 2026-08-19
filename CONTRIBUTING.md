# Contributing to QuizForge

Thank you for helping improve QuizForge.

## Development workflow

1. Fork or branch from `main`.
2. Configure Git with a real identity. Repository maintainers may use `sanskarin@outlook.in` for local commits.
3. Install Flutter stable and run `flutter pub get`.
4. Make one focused change at a time.
5. Add or update tests for behavior changes and bug fixes.
6. Run the quality gate before opening a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Commit style

Use Conventional Commit prefixes when practical:

- `feat:` user-facing capability
- `fix:` defect correction
- `test:` test-only change
- `docs:` documentation
- `refactor:` behavior-preserving restructure
- `perf:` performance change
- `ci:` automation
- `build:` build/dependency configuration
- `chore:` maintenance

Keep commits atomic and meaningful. Do not create empty commits or artificial churn to inflate history.

## Pull requests

A pull request should explain the problem, the chosen solution, testing performed, accessibility impact, privacy/security impact, and screenshots for visible UI changes when practical.

## Architecture expectations

- Keep domain rules independent from Flutter widgets and persistence details.
- Validate imported/untrusted data before storing it.
- Do not add network dependencies to core offline flows.
- Do not commit credentials, production tokens, private endpoints, personal datasets, or signing keys.
- Add an ADR under `docs/adr/` for major architectural changes.

## UI and accessibility

New UI should support keyboard use where applicable, semantic labels, scalable text, light/dark themes, touch-friendly targets, and non-color-only status indicators.

## Questions

- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`

**Made by the Sanskar**
