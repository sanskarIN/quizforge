# QuizForge 2.18.12 Workstreams

This file decomposes the planned 2.18.12 milestone into reviewable workstreams. It is intentionally separate from the 2.7.4 release candidate and does not change current package metadata.

## Workstream A — File adapters

Goal: make existing question-bank and complete-backup codecs usable through optional platform file pick/save flows while preserving clipboard fallback.

Deliverables:

- platform-neutral file import/export interfaces in the application boundary;
- adapters for supported Flutter targets where the chosen dependency is maintained and security-reviewed;
- cancellation and permission-denial behavior that is not reported as corruption;
- size checks before expensive decode work where practical;
- no automatic execution/opening of imported content;
- widget/application tests using fakes rather than host file dialogs;
- platform smoke checks for actual pick/save behavior.

Exit criteria:

- JSON/CSV question-bank file round trips succeed;
- complete local-backup file save/restore succeeds with fictional data;
- clipboard flows remain functional;
- malformed/oversized/unsupported inputs fail safely.

## Workstream B — Shareable quiz packs

Goal: introduce a content-only exchange format that cannot accidentally expose local profile/history state.

Deliverables:

- explicit format name and version;
- content-only model/codec;
- question-domain validation;
- duplicate-id/content handling;
- deterministic encode order;
- import report suitable for UI rendering;
- compatibility/security/privacy documentation.

Exit criteria:

- pack archives cannot contain profile, bookmark, attempt, submitted-answer, preference, or active-profile fields;
- round-trip, malformed-input, duplicate, size-bound, and unsupported-version tests pass;
- docs clearly distinguish quiz packs from private complete backups.

## Workstream C — Longitudinal statistics

Goal: add useful local trends without creating a new remote analytics requirement.

Candidate metrics:

- attempts over time;
- accuracy trend;
- score trend;
- category/difficulty breakdown;
- average duration;
- streak summaries;
- recent-versus-historical comparison.

Constraints:

- active-profile isolation is mandatory;
- submitted-answer payloads stay out of summary queries/UI;
- query/index/schema changes require measured justification;
- any schema change requires migration and old-schema tests.

Exit criteria:

- deterministic aggregate tests cover empty and large histories;
- representative database performance is recorded;
- compact/wide and large-text layouts are reviewed.

## Workstream D — Localization expansion

Goal: expand supported UI languages while preserving deterministic catalog integrity.

Deliverables:

- additional ARB catalogs selected based on maintainable translation quality;
- exact key parity with the English template;
- locale metadata and formatter coverage;
- UI tests for long translated strings and right-to-left layout if an RTL language is added;
- updated contributor translation guidance.

Exit criteria:

- `tool/check_arb_catalogs.py` and `flutter gen-l10n` pass;
- no serialized domain identifier depends on localized text;
- representative navigation/quiz/import/settings flows are reviewed in each new locale.

## Workstream E — Browser/restart end-to-end verification

Goal: automate high-risk persistence journeys that source-level tests cannot fully prove.

Deliverables:

- built-Web browser harness;
- database create/write/read journey;
- refresh/reload persistence journey;
- complete-backup export/mutate/restore journey;
- restart-level settings/profile persistence test adapter;
- profile isolation journey covering bookmarks/progress/history.

Exit criteria:

- deterministic fictional fixtures;
- no production credentials;
- CI artifacts/logs are privacy-safe;
- failures distinguish product defects from browser/runner setup defects.

## Workstream F — Performance evidence

Goal: turn performance work into measurable engineering rather than speculative optimization.

Measurements:

- cold/warm application initialization;
- database open/seed time;
- question selection over large generated banks;
- JSON/CSV/quiz-pack encode/decode;
- complete-backup encode/decode/validation;
- statistics query latency;
- memory behavior for large imports.

Exit criteria:

- hardware, OS, Flutter/Dart version, dataset sizes, and methodology are documented;
- regression budgets are recorded;
- optimizations include before/after evidence.

## Workstream G — Optional private-room transport

Goal: only if justified, implement networking behind the existing disabled/fail-closed boundary without coupling core quiz logic to a remote service.

Required security cases before enablement:

- room authorization;
- malformed and oversized messages;
- duplicate/replayed messages;
- disconnect/reconnect behavior;
- timeouts;
- host/participant state divergence;
- privacy-sensitive logging;
- abuse/rate limits where applicable;
- transport unavailable/offline behavior.

Exit criteria:

- offline solo/local functionality remains unaffected;
- transport can be disabled without code forks;
- threat model and tests are reviewed before enabled-by-default behavior is considered.

## Workstream H — Distribution and packaging

Goal: move from compile evidence toward polished distribution while keeping secrets outside source control.

Deliverables to evaluate by target:

- Android signed app bundle/store metadata;
- iOS signed/archive/App Store flow;
- Windows packaging/installer and optional signing;
- macOS archive/signing/notarization;
- Linux package format(s) and desktop metadata/icon integration;
- Web deployment headers/cache/WASM MIME behavior.

Cross-target invariants:

- canonical application identity remains `io.github.sanskarin.quizforge`;
- deterministic QuizForge branding remains structurally validated;
- published artifacts receive checksums;
- signing credentials never enter the public repository.

## Suggested commit discipline

Keep implementation workstreams isolated. Prefer commits such as:

- `feat: add portable file adapter interface`
- `test: cover file adapter cancellation paths`
- `feat: add versioned quiz pack codec`
- `test: harden quiz pack malformed input handling`
- `feat: add profile accuracy trend query`
- `perf: record large-bank benchmark baseline`
- `docs: document 2.18.12 compatibility contract`

Do not create empty or artificial commits solely to increase commit count.

**Made by the Sanskar**
