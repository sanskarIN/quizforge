# QuizForge Roadmap

This roadmap tracks engineering milestones rather than guaranteed release dates. Completed work should be reflected in `CHANGELOG.md` and the precise continuation state belongs in `what_changed.md`.

## Phase 0 — Repository foundation

- [x] Public MIT repository identity
- [x] Flutter/Dart package configuration
- [x] Strict analyzer/lint baseline
- [x] Editor, attributes, ignore, and environment templates
- [x] Community/security/privacy/support baseline
- [x] CI quality workflow
- [ ] Finish all issue/PR templates and dependency automation
- [ ] Complete architecture decision records

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
- [ ] In-app profile rename/delete with safe data handling
- [ ] Dedicated data backup/restore and reset controls
- [ ] Rich quiz setup screen for custom category/difficulty/tag/count combinations

## Phase 3 — Advanced quality and platform work

- [x] Offline-first product boundary
- [x] Private-room multiplayer transport abstraction, disabled by default
- [ ] Implement and security-review an optional private-room transport
- [ ] Complete platform-specific icon/splash generation
- [ ] Add robust file-picker based import/export where supported
- [ ] Validate web database worker/WASM packaging on a clean build
- [ ] Profile large question banks and add pagination/virtualization thresholds where measured

## Phase 4 — Verification depth

- [x] Domain tests
- [x] Codec regression tests
- [x] In-memory database integration tests
- [x] Initial widget test
- [ ] Add controller integration tests with injected preference fakes
- [ ] Add creator/import widget journeys
- [ ] Add end-to-end primary-journey automation
- [ ] Add parser fuzz/property testing
- [ ] Add accessibility-focused automated checks where tool support is stable
- [ ] Establish measured performance benchmarks for large banks

## Phase 5 — Release engineering and documentation

- [x] README and core policy documentation
- [ ] Complete setup/development/testing/release/troubleshooting/accessibility/performance docs
- [ ] Add release workflow and reproducible packaging scripts
- [ ] Replace documentation screenshot placeholders with verified captures
- [ ] Produce release notes and platform artifacts

## Phase 6 — Final audit

- [ ] Build from a clean checkout
- [ ] Pass formatting, analysis, tests, dependency/security checks
- [ ] Validate database creation/migrations
- [ ] Verify Android release build
- [ ] Verify web release build
- [ ] Verify supported desktop builds on their host operating systems
- [ ] Check documentation links
- [ ] Manually review keyboard navigation, screen-reader semantics, scalable text, contrast, and reduced motion
- [ ] Confirm no credentials or private data are committed
- [ ] Tag a verified release candidate

## Future ideas after the baseline is verified

Future work must remain coherent with QuizForge rather than increasing feature count for its own sake. Candidates include shareable local quiz packs, richer statistics, optional cloud-independent LAN rooms, localization packs, and educator-oriented batch authoring.

**Made by the Sanskar**
