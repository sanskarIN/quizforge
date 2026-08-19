# QuizForge Roadmap

This roadmap tracks engineering milestones rather than guaranteed release dates. Completed work should be reflected in `CHANGELOG.md`; precise continuation and verification state belongs in `what_changed.md` and `docs/verification.md`.

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
- [x] Local activity reset and full local-data reset controls
- [x] Rich quiz setup screen for custom category/difficulty/tag/count combinations
- [ ] Dedicated full-app backup/restore archive beyond question-bank interchange

## Phase 3 — Advanced quality and platform work

- [x] Offline-first product boundary
- [x] Private-room multiplayer transport abstraction, disabled by default
- [ ] Implement and security-review an optional private-room transport
- [ ] Complete and verify platform-specific icon/splash generation on materialized runners
- [ ] Add robust file-picker based import/export where supported
- [ ] Validate web database worker/WASM packaging on a clean build
- [ ] Profile large question banks and add pagination/virtualization thresholds where measurements justify them

## Phase 4 — Verification depth

- [x] Domain tests
- [x] Codec regression tests
- [x] In-memory database integration tests
- [x] Widget-test harness and core widget tests
- [x] Creator widget journey
- [x] Import widget journey
- [x] Deterministic parser fuzz-style testing
- [x] Accessibility-focused quiz semantics checks
- [x] Controller integration tests with injected storage/preference fakes
- [ ] Add end-to-end primary-journey automation across app startup → play → result → persistence
- [ ] Establish measured performance benchmark evidence for large banks on a verified Flutter host

## Phase 5 — Release engineering and documentation

- [x] README and core policy documentation
- [x] Setup/development/testing/release/troubleshooting/accessibility/performance documentation
- [x] CI, dependency review, secret scanning, vulnerability scanning, and platform-build workflows
- [x] Release workflow with reproducible Android/Web packaging and checksums
- [x] Verification and repository-settings guidance
- [ ] Replace documentation screenshot placeholders with verified real captures
- [ ] Produce verified release notes and platform artifacts

## Phase 6 — Final audit

- [ ] Build from a clean checkout
- [ ] Pass formatting, analysis, tests, dependency/security checks on the final candidate commit
- [ ] Validate database creation and migration policy in the verified toolchain
- [ ] Verify Android release build
- [ ] Verify web release build
- [ ] Verify supported desktop builds on their host operating systems
- [ ] Verify iOS compilation/build on macOS/Xcode
- [ ] Check documentation links
- [ ] Manually review keyboard navigation, screen-reader semantics, scalable text, contrast, and reduced motion
- [ ] Confirm no credentials or private data are committed
- [ ] Capture real release-build screenshots
- [ ] Commit/validate the Flutter application lockfile if retained by final repository policy
- [ ] Tag a verified release candidate

## Future ideas after the baseline is verified

Future work must remain coherent with QuizForge rather than increasing feature count for its own sake. Candidates include shareable local quiz packs, richer statistics, optional cloud-independent LAN rooms, localization packs, educator-oriented batch authoring, and a versioned full-app backup format.

**Made by the Sanskar**
