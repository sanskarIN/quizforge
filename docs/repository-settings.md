# GitHub Repository Settings

This document records recommended repository settings that are not fully represented by tracked files.

## Repository About metadata

Keep the GitHub repository's **About** panel aligned with the README and current product scope.

Recommended description:

> Offline-first Flutter quiz game and quiz-authoring toolkit with local profiles, question-bank import/export, statistics, and accessibility-first UI.

Recommended website/funding link when a project website is not yet published:

- `https://buymeacoffee.com/sanskarIN` may remain the funding destination through `.github/FUNDING.yml`;
- do not present the funding page as the product homepage;
- leave the website field empty until a real QuizForge project/site URL exists.

Recommended topics:

- `flutter`
- `dart`
- `quiz`
- `quiz-app`
- `offline-first`
- `sqlite`
- `drift`
- `education`
- `accessibility`
- `open-source`

The About panel is GitHub repository metadata, not a tracked source file. It should be changed through repository settings by an authorized maintainer and must not be claimed as configured merely because these recommendations exist in documentation.

## Default branch

Use `main` as the default branch.

## Branch protection / ruleset

For `main`, enable a ruleset that:

- requires a pull request before merge for normal contributor changes;
- requires CI quality checks to pass;
- requires the dependency-review check on pull requests that change dependencies;
- requires conversations to be resolved;
- blocks force pushes and branch deletion;
- requires the branch to be up to date when appropriate for the repository's merge volume;
- permits repository administrators to recover from automation emergencies without routinely bypassing review.

Do not mark a status check as required until the workflow has run successfully and the exact check name is known.

## Merge policy

Squash merge is suitable for contributor pull requests when their internal commit history is noisy. Preserve normal merge/rebase options when maintaining a carefully atomic series is useful. Commit messages should remain meaningful and use Conventional Commit prefixes where practical.

For the Phase 6 audit PR, prefer a merge strategy that preserves the intentionally granular, meaningful audit history unless repository policy requires another strategy.

## Security features

For this public repository, enable the GitHub security features available to the account/repository, especially:

- dependency graph;
- Dependabot alerts;
- Dependabot security updates;
- secret scanning and push protection when available;
- code-scanning ingestion for vulnerability/scanner SARIF when supported by the chosen workflow/tooling.

The repository also runs dependency review on pull requests, an OSV vulnerability scan, and a full-history Gitleaks secret scan.

## Discussions

Enable GitHub Discussions if community Q&A grows beyond issues. Suggested categories:

- Announcements
- Q&A
- Ideas
- Show and tell

Bugs and actionable feature work should remain in Issues because issues are easier to connect to commits and releases.

## Suggested labels

- `bug`
- `enhancement`
- `documentation`
- `accessibility`
- `security`
- `performance`
- `dependencies`
- `ci`
- `platform: android`
- `platform: ios`
- `platform: web`
- `platform: windows`
- `platform: macos`
- `platform: linux`
- `good first issue`
- `help wanted`
- `needs reproduction`
- `blocked`

## Suggested milestones

Create milestones only when they help coordinate active work. Initial useful milestones are:

- `0.1.x — Baseline verification`
- `0.2.0 — Core product completion`
- `1.0.0 — Production release`

## Releases

Tags matching `vX.Y.Z` trigger the tracked release workflow. Do not create a release tag until the version, changelog, committed/reviewed lockfile, final-head quality/build/security checks, and applicable manual checks have been verified according to `docs/release.md` and `docs/verification.md`.

## Funding

`.github/FUNDING.yml` points to the optional Buy Me a Coffee page. Funding must remain non-intrusive and must never gate application functionality.
