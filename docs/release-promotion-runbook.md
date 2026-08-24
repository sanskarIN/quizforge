# QuizForge Release Promotion Runbook

This runbook defines the final promotion sequence after a release candidate has already received its required source, build, security, and manual evidence. It prevents documentation or tag operations from being mistaken for verification.

## 1. Freeze the candidate

- Record the exact candidate branch and SHA.
- Stop feature work on that release line.
- Confirm package/public/tag identity is internally consistent.
- Confirm the committed application lockfile is present and reviewed.
- Confirm no applicable check is merely queued, pending, cancelled, superseded, or skipped.

## 2. Read exact-head automated evidence

For the exact frozen SHA require the applicable maintained workflows to complete successfully:

- CI quality gate;
- Android/Web Build Gate;
- Linux/Windows/macOS/iOS Platform Build Matrix;
- Dependency Review;
- OSV Vulnerability Scan;
- full-history Secret Scan.

Within CI require successful repository-tool regressions and validators, locked dependency resolution without resolver-file drift, localization generation, formatting, analyzer, and all automated tests.

Do not transfer a green result from an older SHA to a newer release head.

## 3. Complete release-host evidence

Use `docs/manual-release-verification-report-template.md` for applicable distributed targets. Use fictional/demo data only.

At minimum record the actual verified scope for:

- local database startup and persistence;
- quiz/profile/bookmark/progress/history behavior;
- question-bank portability;
- complete local-backup export/mutate/restore;
- Web runtime/persistence/reload behavior;
- branding/icon/splash presentation;
- accessibility and interaction review;
- signing/provisioning/package state where applicable;
- real candidate screenshots.

A compile artifact is not automatically a signed/distributed application.

## 4. Reconcile release documentation

Before tagging, update the authoritative files with observed evidence only:

- `docs/verification.md`;
- release-specific notes;
- `CHANGELOG.md` when needed;
- `ROADMAP.md`;
- `what_changed.md`.

If this reconciliation creates a new commit, that new SHA becomes the final candidate and its applicable automated checks must be read again. Keep evidence-document edits focused to avoid needless release-head churn.

## 5. Review repository safety

- Confirm no credentials, signing secrets, real user archives, private datasets, or production tokens were introduced.
- Confirm generated/local machine files are not unintentionally tracked.
- Confirm application/bundle identity is intentional.
- Confirm licensing and third-party dependency state are acceptable.
- Confirm release notes accurately distinguish supported, verified, unsigned, and externally signed targets.

## 6. Merge/promote the source state

Only after all applicable blockers are clear:

- merge the maintained release-candidate PR using the repository's intended history policy;
- confirm the resulting `main` SHA is the expected verified source state or perform the required post-merge check if the merge creates a distinct commit;
- do not silently add unrelated feature work during promotion.

If branch protection or merge strategy creates a new source SHA whose contents differ materially from the verified candidate, run the applicable checks again.

## 7. Create the public tag

Create the intended tag only from the verified release source state. For the current 2.7.4 line the intended public tag is `v2.7.4`.

If signed tags are required but signing is unavailable, do not claim the tag is signed.

## 8. Let the gated release workflow package artifacts

The tagged workflow must:

- verify source first;
- build/package every supported release target through its appropriate host job;
- keep iOS no-codesign output explicitly identified as unsigned compile evidence;
- wait for all required platform jobs before publication;
- create SHA-256 checksums;
- grant write permission only to the publication job.

If a tag workflow job fails, do not present a knowingly partial release as complete. Fix the release defect according to the repository's version/tag correction policy rather than rewriting evidence.

## 9. Verify published artifacts

After publication:

- verify expected artifacts are present;
- verify checksum file coverage;
- confirm artifact names/version labels are correct;
- confirm release notes describe actual signing and verified-platform scope;
- perform any distribution-channel/store upload as a separate controlled activity;
- record external signing/notarization/store follow-up without exposing credentials.

## 10. Close the release milestone

- Mark the release verification issue complete only when its applicable evidence is complete.
- Update the continuation ledger with the published tag and release commit.
- Leave a fresh Unreleased section for future work.
- Begin the next-version branch from the verified release/main state rather than from a stale pre-release head.

For the prepared 2.18.12 milestone, follow issue #15 and rebase/recreate its development line from verified `main` after 2.7.4 closes.

## Stop conditions

Do not promote the release when any applicable condition below is true:

- automated workflow is failing or unobserved;
- manual persistence/backup evidence required for a distributed target is missing;
- real-browser Web persistence has not been checked where Web is distributed;
- signing/provisioning state is falsely or ambiguously represented;
- screenshots are placeholders or fabricated;
- release documentation claims a broader verified scope than the evidence supports;
- source identity/version/lockfile state is inconsistent;
- known security/privacy blocker remains unresolved.

**Made by the Sanskar**
