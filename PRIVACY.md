# Privacy — QuizForge

Last updated: 2026-08-19

QuizForge is designed as an **offline-first** quiz application. Core quiz play, local profiles, question creation, bookmarks, progress statistics, leaderboards, settings, question-bank storage, and local backup/restore do not require a remote account.

## Data stored locally

QuizForge may store the following on the user's device:

- locally created profile identifiers and display names;
- quiz questions, categories, tags, answers, explanations, and time limits;
- quiz-attempt summaries and per-question submitted answers;
- bookmarks;
- appearance and accessibility settings;
- onboarding completion state;
- the currently selected local profile.

The SQLite database and preference storage are controlled by the operating system's application-storage mechanisms.

## Data leaving the device

QuizForge does not intentionally transmit core quiz/profile data to a QuizForge server in the current offline build.

Data can leave the application boundary only through an explicit user action or an external platform behavior, for example:

- copying or exporting a JSON/CSV question bank;
- copying a full local-backup JSON archive;
- pasting/importing a question bank or backup obtained from elsewhere;
- opening GitHub, Buy Me a Coffee, or an email client from the About/Support interface;
- using a future multiplayer transport that is separately implemented, documented, and privacy-reviewed.

A full local-backup archive can contain local profile names, authored/imported questions and answers, bookmarks, quiz history/submitted answers, settings, and active-profile selection. Treat copied backup archives as private files and review them before sharing.

The private-room multiplayer interface in the current codebase is disabled by default and does not provide a network transport.

## Imported and restored content

JSON/CSV question-bank imports are treated as untrusted input. QuizForge validates question structure and rejects invalid entries. Duplicate ids or normalized duplicate question content are skipped by the question-bank import pipeline.

Full local-backup restores are also treated as untrusted input. The archive format is explicitly versioned and validated before replacement. Restore checks record structure and references and uses transactional database replacement plus best-effort rollback of database/preferences if a later restore step fails. Unsupported backup versions are rejected rather than interpreted heuristically.

Users should avoid importing or restoring data from sources they do not trust. Question-bank exports and local-backup archives can contain user-authored/private content.

## Analytics and advertising

The current project does not include advertising SDKs, behavioral analytics SDKs, or third-party tracking in its core implementation.

## Accounts and cloud storage

No QuizForge cloud account is required. The current project does not provide cloud synchronization. Local profiles are device-local identities rather than internet accounts.

## Data deletion and reset

QuizForge provides in-app controls to:

- clear quiz history and bookmarks for the active local profile;
- delete a non-final local profile and its dependent activity;
- reset all local QuizForge quiz data, profiles, bookmarks, attempt history, custom/imported questions, appearance/accessibility settings, and active-profile selection, then recreate starter questions/default profile during initialization.

Onboarding completion is intentionally stored separately from the ordinary local-data backup/reset payload. Operating-system application-data controls or uninstalling the application can remove all app storage, including onboarding state.

Because deletion/reset can be irreversible, QuizForge uses confirmation for destructive UI actions. Export a local backup first when recovery may be needed.

## Security

Security reports should follow `SECURITY.md`. Do not send private user datasets, backup archives, credentials, or unrelated personal information when reporting a bug.

## Contact

- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`

This document describes the behavior of the open-source QuizForge codebase. A distributor who modifies the application by adding analytics, remote services, advertising, authentication, or another data-processing feature is responsible for documenting those changes accurately.

**Made by the Sanskar**
