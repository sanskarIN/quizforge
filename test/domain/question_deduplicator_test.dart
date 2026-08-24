import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/question_deduplicator.dart';

void main() {
  const QuestionDeduplicator deduplicator = QuestionDeduplicator();

  test('keeps first question and reports repeated id', () {
    final Question first = _question('same', 'First prompt?');
    final Question second = _question('same', 'Second prompt?');

    final DuplicateReport report = deduplicator.partition(<Question>[
      first,
      second,
    ]);

    expect(report.unique, <Question>[first]);
    expect(report.duplicates, <Question>[second]);
  });

  test('detects normalized prompt fingerprint against existing bank', () {
    final Question existing = _question('one', 'What is 2 + 2?');
    final Question incoming = _question('two', '  WHAT   IS 2 + 2? ');

    final DuplicateReport report = deduplicator.partition(
      <Question>[incoming],
      existing: <Question>[existing],
    );

    expect(report.unique, isEmpty);
    expect(report.duplicates.single, incoming);
  });
}

Question _question(String id, String prompt) => Question(
  id: id,
  type: QuestionType.shortAnswer,
  prompt: prompt,
  correctAnswers: const <String>{'4'},
  category: 'Math',
  difficulty: Difficulty.easy,
);
