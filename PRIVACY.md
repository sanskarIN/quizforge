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
- copying a versioned local backup archive to the clipboard;
- pasting exported data into another application or service;
- opening GitHub, Buy Me a Coffee, or an email client from the About/Support interface;
- using a future multiplayer transport that is separately implemented, documented, and privacy-reviewed.

A **local backup** contains more data than a question-bank export. It can include locally authored questions and answers, local profile names, bookmarks, quiz-attempt history including submitted answers, the selected profile, and application settings. Backup archives should therefore be treated as private user data and shared only when the user intentionally chooses to do so.

The private-room multiplayer interface in the current codebase is disabled by default and does not provide a network transport.

## Imported and restored content

JSON/CSV question-bank imports and local-backup archives are treated as untrusted input. QuizForge validates their supported structure before persistence. Question-bank imports reject invalid entries and skip duplicate ids or normalized duplicate question content.

Local-backup restore validates the complete archive, its version, references, question/profile validity, attempt aggregates, bookmarks, and active-profile selection before replacement. The application takes a logical snapshot of current local state before applying a restore and attempts to roll that state back if a later restore step fails.

No rollback mechanism can substitute for keeping an independent copy of important data. Users should export a current backup before a destructive restore when they may need to recover the previous state.

## Analytics and advertising

The current project does not include advertising SDKs, behavioral analytics SDKs, or third-party tracking in its core implementation.

## Accounts and cloud storage

No QuizForge cloud account is required. The current project does not provide cloud synchronization. Local profiles are device-local identities rather than internet accounts.

## Data deletion and reset

QuizForge provides explicit in-app controls for:

- clearing quiz history and bookmarks for the active local profile;
- deleting a local profile while retaining at least one profile;
- resetting all local QuizForge data with confirmation, after which starter questions and a default local profile are recreated.

Application data can also be removed using the operating system's application-data controls or by uninstalling the application. Operating-system or platform backups may retain copies outside QuizForge's direct control according to the user's platform settings.

## Logging

The application logger is designed to avoid logging raw question prompts, answers, profile display names, import/export payloads, credentials, tokens, cookies, or similarly sensitive values. Error paths generally log event names and error types rather than user-authored content.

## Security

Security reports should follow `SECURITY.md`. Do not send private user datasets, backup archives, credentials, or unrelated personal information when reporting a bug unless a secure maintainer-requested process explicitly requires a minimal reproduction.

## Contact

- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`

This document describes the behavior of the open-source QuizForge codebase. A distributor who modifies the application by adding analytics, remote services, advertising, authentication, or another data-processing feature is responsible for documenting those changes accurately.

**Made by the Sanskar**
