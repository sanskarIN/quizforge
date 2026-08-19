# QuizForge Screenshots

This directory is reserved for **verified captures of the real application**. Do not publish fabricated screenshots that imply unimplemented behavior.

## Required capture set

Before a release candidate, capture the current release build at representative sizes:

1. Home dashboard — compact/mobile, light theme.
2. Home dashboard — wide/desktop, dark theme.
3. Quiz play — multiple-choice question.
4. Quiz play — multi-select or short-answer question.
5. Review screen with explanation/bookmark controls.
6. Question bank with search/filter controls.
7. Question creator with a valid preview.
8. Import/export report.
9. Progress/local leaderboard.
10. Settings/About with accessibility and project identity.

## Capture rules

- Use only fictional/demo quiz content.
- Do not expose device notifications, usernames, paths, emails unrelated to the documented project contacts, or private data.
- Use the exact release candidate being documented.
- Record the platform and app version in the pull request that adds captures.
- Prefer PNG for UI captures.
- Keep image dimensions useful for documentation without committing unnecessarily huge files.
- Verify light/dark contrast and large-text layouts during the same review even when not every state is published as a screenshot.

## README integration

Once verified captures exist, replace README placeholder language with a small representative gallery and keep this file as the capture/audit guide.

No generated mockup is treated as proof that a build was tested.
