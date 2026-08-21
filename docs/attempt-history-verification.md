# Attempt History Verification

This checklist covers the recent-attempt history addition before it is merged into the Phase 6 audit branch.

## Automated gates

Run on the exact feature head:

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test tool
python3 tool/check_markdown_links.py
flutter analyze
flutter test --coverage
```

Specific regression coverage expected:

- `test/data/app_database_test.dart`
  - projects stored attempts into `AttemptSummary`;
  - returns newest attempts first;
  - honors the requested limit;
  - rejects limits outside 1–100;
  - clears history with active-profile activity deletion.
- `test/widget/recent_attempt_history_test.dart`
  - initializes against in-memory SQLite and memory-only settings/profile adapters;
  - persists a completed attempt;
  - renders the recent-history row with score and elapsed time.

## Manual review

On at least one built target:

1. Complete two quizzes with visibly different scores.
2. Open Statistics and confirm newest-first ordering.
3. Switch local profiles and confirm history changes with the active profile.
4. Complete another quiz and confirm history refreshes after returning to Statistics.
5. Clear active-profile activity and confirm recent history is empty.
6. Confirm the list remains usable at large system text sizes.
7. Confirm no submitted-answer content is shown in the summary list.

## Privacy and storage

The feature reads the existing local `attempts` table and introduces no network transport, analytics, account, or extra history store. Detailed submitted answers remain in the existing local attempt-answer data and are not surfaced by the recent-history summary projection.

Do not mark this checklist verified until the exact feature head has completed the applicable automated and manual checks.
