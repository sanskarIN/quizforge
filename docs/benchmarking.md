# Benchmarking QuizForge

`tool/benchmark.dart` provides a deterministic, credential-free benchmark harness for domain selection and question-bank serialization.

## Run

After `flutter pub get`:

```bash
dart run tool/benchmark.dart
```

The default generated bank contains 10,000 fictional questions. Supply another size when investigating scaling behavior:

```bash
dart run tool/benchmark.dart 1000
dart run tool/benchmark.dart 10000
dart run tool/benchmark.dart 50000
```

The accepted range is 1–100,000 questions so accidental command-line input cannot create an unbounded fixture.

## Scenarios

The harness measures:

- deterministic selection of 50 questions;
- JSON encoding;
- JSON decoding and semantic count/error validation;
- CSV encoding;
- CSV decoding and semantic count/error validation.

Each scenario receives three warm-up runs followed by seven measured runs. Output is newline-delimited JSON containing the sorted run times and median microseconds. A final summary records bank size and UTF-8 payload sizes.

## Recording results

Benchmark numbers are meaningful only with environment metadata. When committing measured results, record:

- date;
- commit SHA;
- Flutter and Dart versions;
- OS and architecture;
- CPU and memory;
- build/runtime mode;
- bank size;
- command;
- median and individual runs;
- whether the machine was under unusual load.

Do not publish one machine's timing as a universal performance guarantee.

## Regression use

The benchmark is initially an observational harness rather than a fixed CI threshold. Establish a regression threshold only after collecting stable measurements on a controlled runner. A threshold that is tighter than normal runner variance creates noisy CI and should be avoided.

If measurements show user-visible stalls for realistic banks, profile the exact hot path before introducing pagination, background isolates, streaming parsers, or caching. Keep parsing validation and deterministic quiz semantics unchanged when optimizing.

See also [`performance.md`](performance.md).
