# Performance

QuizForge optimizes measured user-facing bottlenecks rather than adding speculative complexity.

## Current performance model

Core quiz scoring and selection are in-memory operations over the loaded question bank. Persistence is local SQLite. The starter bank is small, so no artificial loading delay, pagination, cache layer, or isolate is introduced for it.

## Initial engineering budgets

These are development targets to guide investigation, not claims of measured production performance:

- avoid synchronous work that predictably blocks the UI for a frame during normal quiz interaction;
- keep navigation/input responsive under a representative local bank;
- avoid repeated full-database queries during a single screen build;
- use indexed columns for existing category/difficulty/profile-history lookup patterns;
- keep release assets purposeful and avoid unnecessarily large media;
- keep import behavior bounded and user-driven.

Actual release measurements must state hardware, OS, Flutter version, build mode, dataset size, and methodology.

## Database considerations

Current indexes cover question category, question difficulty, and profile attempt history. Indexes should be added only for demonstrated query patterns because unnecessary indexes increase write/storage cost.

Attempt + answer writes are transactional. Question-bank inserts are transactional. This improves consistency and avoids partially persisted multi-row operations.

## Large question banks

Before release, benchmark fictional banks such as 1k, 10k, and—if a real use case warrants it—larger sets. Measure:

- database open/load time;
- search/filter latency;
- deterministic selection latency;
- JSON/CSV encode/decode time and memory;
- creator/save latency;
- question-bank scroll performance;
- app memory after loading a large bank.

If measured costs become significant, consider database-backed filtered queries, incremental loading, list virtualization/pagination, background isolate parsing, and stream-based import/export. Do not add these mechanisms solely to satisfy a feature count.

## UI profiling

Use Flutter profile/release modes and DevTools rather than debug-mode frame timings for performance conclusions. Investigate excessive rebuilds, layout thrashing, long raster/UI frames, unnecessary allocations, and oversized widget subtrees.

The current controller exposes application state through one notifier. If profiling shows broad rebuild cost at scale, split state into focused listenable units before adopting a larger state-management dependency.

## Import/export

Current codecs operate on strings in memory. That is appropriate for the baseline but can become expensive for large question banks. A measured threshold should trigger migration to chunked/file streaming or isolate parsing.

The parser must remain validation-first and deterministic after optimization.

## Web

Web performance testing should use the built release artifact. Validate initial load size, SQLite/Drift runtime initialization, persistence, import memory usage, reload behavior, and browser-storage quota failure handling.

## Benchmark record template

When measurements are added, record:

```text
Date:
Commit:
Flutter/Dart:
Platform/OS:
Hardware:
Build mode:
Dataset:
Scenario:
Runs/warm-up:
Metric:
Result:
Regression threshold:
Notes:
```

Do not put unmeasured numbers in the README as performance claims.
