# Privacy — QuizForge

Last updated: 2026-08-19

QuizForge is designed as an **offline-first** quiz application. Core quiz play, local profiles, question creation, bookmarks, progress statistics, leaderboards, settings, and question-bank storage do not require a remote account.

## Data stored locally

QuizForge may store the following on the user's device:

- locally created profile identifiers and display names;
- quiz questions, categories, tags, answers, explanations, and time limits;
- quiz-attempt summaries and per-question submitted answers;
- bookmarks;
- appearance and accessibility settings;
- the currently selected local profile.

The SQLite database and preference storage are controlled by the operating system's application-storage mechanisms.

## Data leaving the device

QuizForge does not intentionally transmit core quiz/profile data to a QuizForge server in the current offline build.

Data can leave the device only through an explicit user action or an external platform behavior, for example:

- copying or exporting a JSON/CSV question bank;
- opening GitHub, Buy Me a Coffee, or an email client from the About/Support interface;
- using a future multiplayer transport that is separately implemented, documented, and privacy-reviewed.

The private-room multiplayer interface in the current codebase is disabled by default and does not provide a network transport.

## Imported content

JSON/CSV imports are treated as untrusted input. QuizForge validates question structure and rejects invalid entries. Duplicate ids or normalized duplicate question content are skipped by the import pipeline.

Users should avoid importing files from sources they do not trust and should review exported files before sharing them because exports can contain their locally authored question-bank content.

## Analytics and advertising

The current project does not include advertising SDKs, behavioral analytics SDKs, or third-party tracking in its core implementation.

## Accounts and cloud storage

No QuizForge cloud account is required. The current project does not provide cloud synchronization. Local profiles are device-local identities rather than internet accounts.

## Data deletion

Application data can be removed using the operating system's application-data controls or by uninstalling the application. A dedicated in-app data-reset flow is planned for a later milestone and must use clear confirmation before deletion.

## Security

Security reports should follow `SECURITY.md`. Do not send private user datasets, credentials, or unrelated personal information when reporting a bug.

## Contact

- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`

This document describes the behavior of the open-source QuizForge codebase. A distributor who modifies the application by adding analytics, remote services, advertising, authentication, or another data-processing feature is responsible for documenting those changes accurately.

**Made by the Sanskar**
