# GitHub Repository Settings

This document records recommended repository settings that are not fully represented by tracked files.

## Repository About metadata

Keep the GitHub repository's **About** panel aligned with the README and current product scope.

Recommended description:

> Offline-first Flutter quiz game and authoring toolkit with local profiles, progress history, validated import/export, full local backup, and accessibility-focused UI.

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
- requires the maintained CI quality check to pass;
- requires applicable build/platform/security checks according to release policy;
- requires the dependency-review check on pull requests that change dependencies;
- requires conversations to be resolved;
- blocks force pushes and branch deletion;
- requires the branch to be up to date when appropriate for the repository's merge volume;
- permits repository administrators to recover from automation emergencies without routinely bypassing review.

The CI quality workflow includes Markdown, ARB, and release-metadata validator tests/validation before Flutter setup. Do not mark a status check as required until the workflow has run successfully and the exact check name is known. Do not guess a required-check context name from a workflow or job display label.

## Merge policy

Squash merge is suitable for contributor pull requests when their internal commit history is noisy. Preserve normal merge/rebase options when maintaining a carefully atomic series is useful. Commit messages should remain meaningful and use Conventional Commit prefixes where practical.

For PR #12 / the 2.7.4 final candidate, prefer a merge strategy that preserves the intentionally granular, meaningful audit/release history unless repository policy requires another strategy.

Do not merge the release-candidate PR merely because GitHub reports it as mechanically mergeable. The release evidence in `docs/verification.md` is stricter than merge-conflict status.

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
- `release`
- `release: 2.7.4`
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

Create milestones only when they help coordinate active work. For the current repository state, useful milestone names are:

- `2.7.4 — Final verification`
- `2.8.0 — Post-release product improvements`
- `3.0.0 — Breaking compatibility work` only if a real incompatible product/data-format change is planned.

Do not retain old pre-1.0 milestones as the active release plan after the package has intentionally moved to the stable 2.x line.

## Releases

The maintained package is `2.7.4+1`; the intended public tag after verification is `v2.7.4`.

Tags matching `vX.Y.Z` trigger the tracked release workflow. Do not create/promote a release tag until:

- `pubspec.yaml`, `AppConstants.version`, changelog, versioning documentation, and the tag agree;
- `tool/test_check_release_metadata.py` and `tool/check_release_metadata.py` pass;
- the application lockfile is Flutter-resolver-generated, reviewed, and committed;
- exact-final-head quality/build/security checks pass;
- applicable manual backup/persistence/accessibility/screenshot checks are recorded according to `docs/release.md` and `docs/verification.md`.

## Funding

`.github/FUNDING.yml` points to the optional Buy Me a Coffee page. Funding must remain non-intrusive and must never gate application functionality.

**Made by the Sanskar**
