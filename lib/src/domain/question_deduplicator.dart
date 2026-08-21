import 'question.dart';

final class DuplicateReport {
  const DuplicateReport({required this.unique, required this.duplicates});

  final List<Question> unique;
  final List<Question> duplicates;
}

final class QuestionDeduplicator {
  const QuestionDeduplicator();

  DuplicateReport partition(
    Iterable<Question> questions, {
    Iterable<Question> existing = const <Question>[],
  }) {
    final Set<String> seenIds = existing
        .map((Question item) => item.id)
        .toSet();
    final Set<String> seenFingerprints = existing
        .map((Question item) => item.fingerprint)
        .toSet();
    final List<Question> unique = <Question>[];
    final List<Question> duplicates = <Question>[];

    for (final Question question in questions) {
      final bool isDuplicate =
          seenIds.contains(question.id) ||
          seenFingerprints.contains(question.fingerprint);
      if (isDuplicate) {
        duplicates.add(question);
        continue;
      }
      unique.add(question);
      seenIds.add(question.id);
      seenFingerprints.add(question.fingerprint);
    }

    return DuplicateReport(
      unique: List<Question>.unmodifiable(unique),
      duplicates: List<Question>.unmodifiable(duplicates),
    );
  }
}
