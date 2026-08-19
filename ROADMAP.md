# QuizForge Roadmap

This roadmap tracks engineering milestones rather than guaranteed release dates. Completed work should be reflected in `CHANGELOG.md` and the precise continuation state belongs in `what_changed.md`.

Current maintained release candidate: **`2.7.4+1`**, intended public tag **`v2.7.4`** after verification.

## Phase 0 — Repository foundation

- [x] Public MIT repository identity
- [x] Flutter/Dart package configuration
- [x] Strict analyzer/lint baseline
- [x] Editor, attributes, ignore, and environment templates
- [x] Community/security/privacy/support baseline
- [x] CI quality workflow
- [x] Issue/PR templates and dependency automation
- [x] Architecture decision records

## Phase 1 — End-to-end MVP

- [x] Four supported question types
- [x] Deterministic quiz engine
- [x] Daily quiz, random practice, and timed sprint
- [x] Answer evaluation and review
- [x] SQLite-backed question/profile/attempt persistence
- [x] Starter question bank
- [x] Adaptive application shell
- [x] Local profiles and progress

## Phase 2 — Complete core product

- [x] Search and filters
- [x] Bookmarks
- [x] Local leaderboard
- [x] Recent per-profile attempt history
- [x] Question creator with validation and preview
- [x] JSON/CSV question-bank import/export
- [x] Versioned complete local backup/restore with validation and rollback handling
- [x] Duplicate handling
- [x] Theme and accessibility preferences
- [x] In-app profile rename/delete with safe data handling
- [x] Local activity/data reset controls
- [x] Rich quiz setup for category/difficulty/tag/count/timing combinations
- [x] English localization resources and localized product navigation/workflows

## Phase 3 — Advanced quality and platform work

- [x] Offline-first product boundary
- [x] Private-room multiplayer transport abstraction, disabled by default
- [x] Structured logging with sensitive-field/content redaction
- [x] Reproducible generated platform-runner strategy and host build matrix
- [ ] Implement and security-review an optional private-room transport
- [ ] Complete platform-specific production icon/splash generation and visual verification
- [ ] Add file-picker based question-bank/backup import-export where supported and justified
- [ ] Validate web database worker/WASM packaging in a verified release build
- [ ] Profile very large banks on representative hardware and add pagination/virtualization only when measured thresholds justify it

## Phase 4 — Verification depth

- [x] Domain tests
- [x] Codec regression tests
- [x] Deterministic malformed-input/fuzz-style codec tests
- [x] In-memory database integration tests
- [x] Controller persistence/rollback-ordering regression tests
- [x] Creator/import/settings/quiz widget tests
- [x] Accessibility semantics tests for quiz progress/timing
- [x] Private-room disabled-transport/fail-closed tests
- [x] Primary quiz completion → review journey automation
- [x] Recent-attempt ordering/limit/database cleanup tests
- [x] Recent-attempt statistics rendering test
- [x] Local-backup codec/database/controller/widget regression coverage
- [x] Local-backup minimum-state, tamper-resistance, attempt-bound, bookmark-pair, and answer-order regression coverage
- [x] Deterministic benchmark harness for quiz selection and codecs
- [x] Repository Markdown-validator regression tests
- [x] Localization ARB-validator regression tests
- [x] Release-metadata-validator regression tests, including historical zero-major release parsing
- [ ] Expand full-app restart/platform-adapter end-to-end journeys after stable test adapters are available
- [ ] Record representative performance measurements and budgets from documented hardware/toolchains

## Phase 5 — Release engineering and documentation

- [x] README and core policy documentation
- [x] Setup/development/testing/release/troubleshooting/accessibility/performance documentation
- [x] Local backup/restore format, privacy, compatibility, and verification documentation
- [x] CI, dependency review, vulnerability scan, secret scan, and platform build workflows
- [x] Tagged Android/Web release workflow with checksums and generated notes
- [x] Release workflow lockfile enforcement and deterministic local-link validation
- [x] Deterministic ARB localization-catalog validation before Flutter localization generation
- [x] Deterministic package/changelog/versioning release-metadata validation before Flutter setup
- [x] Verified-screenshot capture policy and gallery placeholders
- [x] Dedicated 2.7.4 release notes and stable-version compatibility policy
- [ ] Replace screenshot placeholders with real captures from the verified 2.7.4 release candidate
- [ ] Produce signed/store-specific artifacts where applicable without committing credentials

## Phase 6 — Final audit and consolidation

- [x] Create dedicated audit branches and an evidence ledger
- [x] Consolidate Phase 6 hardening with the newer recent-attempt feature line
- [x] Consolidate full local backup/restore from the parallel audit line without weakening persistence hardening
- [x] Close superseded parallel PR paths and retain PR #12 as the single final integration candidate
- [x] Remove obsolete self-mutating bootstrap workflows from maintained release-candidate changes
- [x] Harden import resource limits and question content bounds
- [x] Harden CSV structural parsing for malformed quoted fields
- [x] Harden settings and profile persistence ordering plus rollback/error handling
- [x] Harden local-backup aggregate/reference validation and cross-store rollback behavior
- [x] Require a directly restorable backup minimum state
- [x] Re-evaluate restored submitted-answer correctness/score through normal QuizEngine rules
- [x] Bound restored attempts to normal 1–100-question sessions
- [x] Use exact bookmark pair identity instead of collision-prone delimiter composites
- [x] Preserve schema-v1 stored streak summaries without inventing historical answer order
- [x] Refresh documentation and local check scripts to match maintained CI commands
- [x] Add deterministic repository-local Markdown link checking to CI/local tooling
- [x] Add deterministic ARB localization validation to CI/local tooling
- [x] Preserve CI-generated `pubspec.lock` as a reviewable workflow artifact when CI executes

## Phase 7 — Version 2.7.4 release candidate

- [x] Set package/application version to `2.7.4+1`
- [x] Reserve public release tag identity `v2.7.4`
- [x] Cut the dated 2.7.4 changelog entry and retain a new Unreleased section
- [x] Replace stale pre-1.0 compatibility policy with stable 2.x compatibility rules
- [x] Keep database schema at version 1 because the application-version change does not alter SQLite layout
- [x] Keep local-backup format at version 1 as an independent data-format contract
- [x] Add `tool/check_release_metadata.py`
- [x] Add release-metadata validator tests
- [x] Fix and test historical `0.x.y` changelog parsing in the release validator
- [x] Wire release-metadata tests/validation into shell/PowerShell local gates
- [x] Wire release-metadata tests/validation into pull-request CI
- [x] Wire release-metadata tests/validation into tag release packaging
- [x] Add 2.7.4 README identity, release guide, release notes, CI/testing/setup/development/contribution/maintenance documentation, verification ledger, and continuation handoff
- [x] Update PR #12 title/body as the maintained 2.7.4 final candidate
- [ ] Generate, review, and commit the application `pubspec.lock` from verified Flutter-generated evidence
- [ ] Build from a clean checkout
- [ ] Pass Markdown/ARB/release-metadata validator tests and validators on the final head
- [ ] Pass formatting, localization generation, analysis, and all automated tests on the final head
- [ ] Pass dependency review, OSV scan, and secret scan on the final head
- [ ] Validate database creation and local backup/restore on release builds; add migration verification when schema version first changes
- [ ] Verify Android release build
- [ ] Verify Web release build and Drift persistence/reload behavior
- [ ] Verify supported desktop builds on their host operating systems
- [ ] Verify iOS no-codesign compile and complete signing/device validation outside the public repository
- [ ] Manually review keyboard navigation, screen-reader semantics, scalable text, contrast, and reduced motion
- [ ] Capture verified real screenshots using fictional data
- [ ] Confirm the exact final release-candidate history contains no credentials or private user data
- [ ] Create/promote `v2.7.4` only after all applicable blockers above are cleared

## Future ideas after 2.7.4 is verified

Future work must remain coherent with QuizForge rather than increasing feature count for its own sake. Candidates include shareable local quiz packs, richer longitudinal statistics beyond the implemented recent-attempt list, optional cloud-independent LAN rooms, additional localization packs, educator-oriented batch authoring, and optional file-picker adapters for the already-versioned local backup format.

**Made by the Sanskar**
