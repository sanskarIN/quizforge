import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  test('rejects a completion time before the start time', () {
    final DateTime start = DateTime(2026, 8, 19, 12);

    expect(
      () => QuizResult(
        startedAt: start,
        completedAt: start.subtract(const Duration(seconds: 1)),
        evaluations: const <QuestionEvaluation>[],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('copies evaluations into an unmodifiable result list', () {
    final DateTime start = DateTime(2026, 8, 19, 12);
    final List<QuestionEvaluation> source = <QuestionEvaluation>[
      const QuestionEvaluation(
        questionId: 'q1',
        submittedAnswers: <String>{'answer'},
        correct: true,
        score: 1,
      ),
    ];
    final QuizResult result = QuizResult(
      startedAt: start,
      completedAt: start.add(const Duration(seconds: 1)),
      evaluations: source,
    );

    source.clear();

    expect(result.evaluations, hasLength(1));
    expect(
      () => result.evaluations.add(
        const QuestionEvaluation(
          questionId: 'q2',
          submittedAnswers: <String>{},
          correct: false,
          score: 0,
        ),
      ),
      throwsUnsupportedError,
    );
  });
}
