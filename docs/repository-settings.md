# GitHub Repository Settings

This document records recommended repository settings that are not fully represented by tracked files.

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

## Security features

For this public repository, enable the GitHub security features available to the account/repository, especially:

- dependency graph;
- Dependabot alerts;
- Dependabot security updates;
- secret scanning and push protection when available;
- code-scanning ingestion for the OSV SARIF workflow when supported.

The repository also runs dependency review on pull requests and a scheduled OSV vulnerability scan.

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

Tags matching `vX.Y.Z` trigger the tracked release workflow. Do not create a release tag until the version, changelog, and quality checks have been verified according to `docs/release.md`.

## Funding

`.github/FUNDING.yml` points to the optional Buy Me a Coffee page. Funding must remain non-intrusive and must never gate application functionality.
