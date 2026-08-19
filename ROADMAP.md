# QuizForge Roadmap

This roadmap tracks engineering milestones rather than guaranteed release dates. Completed work should be reflected in `CHANGELOG.md` and the precise continuation state belongs in `what_changed.md`.

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
- [x] Question creator with validation and preview
- [x] JSON/CSV import/export
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
- [ ] Add file-picker based import/export where supported and justified
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
- [x] Deterministic benchmark harness for quiz selection and codecs
- [ ] Expand full-app restart/platform-adapter end-to-end journeys after stable test adapters are available
- [ ] Record representative performance measurements and budgets from documented hardware/toolchains

## Phase 5 — Release engineering and documentation

- [x] README and core policy documentation
- [x] Setup/development/testing/release/troubleshooting/accessibility/performance documentation
- [x] CI, dependency review, vulnerability scan, secret scan, and platform build workflows
- [x] Tagged Android/Web release workflow with checksums and generated notes
- [x] Release workflow lockfile enforcement and deterministic local-link validation
- [x] Verified-screenshot capture policy and gallery placeholders
- [ ] Replace screenshot placeholders with real captures from the verified release candidate
- [ ] Produce signed/store-specific artifacts where applicable without committing credentials

## Phase 6 — Final audit

- [x] Create a dedicated Phase 6 audit branch and evidence ledger
- [x] Remove obsolete self-mutating bootstrap workflows from maintained release-candidate changes
- [x] Harden import resource limits and question content bounds
- [x] Harden CSV structural parsing for malformed quoted fields
- [x] Harden settings and profile persistence ordering plus rollback/error handling
- [x] Refresh documentation and local check scripts to match maintained CI commands
- [x] Add deterministic repository-local Markdown link checking to CI/local tooling
- [x] Preserve CI-generated `pubspec.lock` as a reviewable workflow artifact when CI executes
- [ ] Generate, review, and commit the application `pubspec.lock` from verified Flutter-generated evidence
- [ ] Build from a clean checkout
- [ ] Pass formatting, localization generation, documentation-link validation, analysis, and all automated tests on the final head
- [ ] Pass dependency review, OSV scan, and secret scan on the final head
- [ ] Validate database creation on release builds; add migration verification when schema version first changes
- [ ] Verify Android release build
- [ ] Verify web release build and Drift persistence/reload behavior
- [ ] Verify supported desktop builds on their host operating systems
- [ ] Verify iOS no-codesign compile and complete signing/device validation outside the public repository
- [ ] Manually review keyboard navigation, screen-reader semantics, scalable text, contrast, and reduced motion
- [ ] Capture verified real screenshots using fictional data
- [ ] Confirm the final release-candidate history contains no credentials or private user data
- [ ] Tag a verified release candidate only after all applicable blockers above are cleared

## Future ideas after the baseline is verified

Future work must remain coherent with QuizForge rather than increasing feature count for its own sake. Candidates include shareable local quiz packs, richer statistics, optional cloud-independent LAN rooms, additional localization packs, and educator-oriented batch authoring.

**Made by the Sanskar**
