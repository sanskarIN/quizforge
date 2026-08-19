import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_config.dart';
import 'package:quizforge/src/domain/quiz_engine.dart';
import 'package:quizforge/src/domain/quiz_result.dart';

void main() {
  const QuizEngine engine = QuizEngine();

  group('QuizEngine.evaluate', () {
    test('multiple choice is case and whitespace insensitive', () {
      final Question question = _question(
        id: 'mc',
        type: QuestionType.multipleChoice,
        choices: const <String>['Blue', 'Green'],
        answers: const <String>{'Blue'},
      );

      final QuestionEvaluation evaluation =
          engine.evaluate(question, const <String>['  BLUE ']);

      expect(evaluation.correct, isTrue);
      expect(evaluation.score, 1);
    });

    test('true false accepts canonical case-insensitive values', () {
      final Question question = Question(
        id: 'tf',
        type: QuestionType.trueFalse,
        prompt: 'The test runner is deterministic.',
        correctAnswers: const <String>{'true'},
        category: 'Testing',
        difficulty: Difficulty.easy,
      );

      expect(engine.evaluate(question, const <String>[' TRUE ']).correct, isTrue);
      expect(engine.evaluate(question, const <String>['false']).correct, isFalse);
    });

    test('multi-select requires exact set', () {
      final Question question = _question(
        id: 'multi',
        type: QuestionType.multiSelect,
        choices: const <String>['A', 'B', 'C'],
        answers: const <String>{'A', 'B'},
      );

      expect(engine.evaluate(question, const <String>['A', 'B']).correct, isTrue);
      expect(engine.evaluate(question, const <String>['A']).correct, isFalse);
      expect(
        engine.evaluate(question, const <String>['A', 'B', 'C']).correct,
        isFalse,
      );
    });

    test('short answer accepts any configured equivalent', () {
      final Question question = Question(
        id: 'short',
        type: QuestionType.shortAnswer,
        prompt: 'Circle constant?',
        correctAnswers: const <String>{'pi', 'π'},
        category: 'Math',
        difficulty: Difficulty.easy,
      );

      expect(engine.evaluate(question, const <String>['PI']).correct, isTrue);
      expect(engine.evaluate(question, const <String>['3.14']).correct, isFalse);
    });
  });

  group('QuizEngine.selectQuestions', () {
    test('selection is deterministic for the same seed', () {
      final List<Question> bank = List<Question>.generate(
        12,
        (int index) => Question(
          id: 'q$index',
          type: QuestionType.shortAnswer,
          prompt: 'Question $index?',
          correctAnswers: <String>{'$index'},
          category: index.isEven ? 'Even' : 'Odd',
          difficulty: Difficulty.easy,
        ),
      );
      const QuizConfig config = QuizConfig(questionCount: 5, seed: 42);

      final List<String> first = engine
          .selectQuestions(bank, config)
          .map((Question item) => item.id)
          .toList();
      final List<String> second = engine
          .selectQuestions(bank, config)
          .map((Question item) => item.id)
          .toList();

      expect(first, second);
      expect(first, hasLength(5));
    });

    test('filters by category difficulty and tag', () {
      final List<Question> bank = <Question>[
        Question(
          id: 'match',
          type: QuestionType.shortAnswer,
          prompt: 'Match?',
          correctAnswers: const <String>{'yes'},
          category: 'Science',
          difficulty: Difficulty.hard,
          tags: const <String>['space'],
        ),
        Question(
          id: 'miss',
          type: QuestionType.shortAnswer,
          prompt: 'Miss?',
          correctAnswers: const <String>{'no'},
          category: 'Science',
          difficulty: Difficulty.easy,
          tags: const <String>['space'],
        ),
      ];

      final List<Question> selected = engine.selectQuestions(
        bank,
        const QuizConfig(
          category: 'science',
          difficulty: Difficulty.hard,
          tags: <String>{'SPACE'},
          questionCount: 10,
        ),
      );

      expect(selected.map((Question item) => item.id), <String>['match']);
    });
  });

  test('result computes percentage and best streak', () {
    final DateTime start = DateTime(2026, 1, 1, 10);
    final QuizResult result = engine.finish(
      startedAt: start,
      completedAt: start.add(const Duration(minutes: 2)),
      evaluations: const <QuestionEvaluation>[
        QuestionEvaluation(
          questionId: '1',
          submittedAnswers: <String>{'a'},
          correct: true,
          score: 1,
        ),
        QuestionEvaluation(
          questionId: '2',
          submittedAnswers: <String>{'b'},
          correct: true,
          score: 1,
        ),
        QuestionEvaluation(
          questionId: '3',
          submittedAnswers: <String>{'c'},
          correct: false,
          score: 0,
        ),
      ],
    );

    expect(result.percentage, closeTo(66.666, 0.01));
    expect(result.bestStreak, 2);
    expect(result.duration, const Duration(minutes: 2));
  });
}

Question _question({
  required String id,
  required QuestionType type,
  required List<String> choices,
  required Set<String> answers,
}) {
  return Question(
    id: id,
    type: type,
    prompt: 'Pick the answer.',
    choices: choices,
    correctAnswers: answers,
    category: 'Demo',
    difficulty: Difficulty.easy,
  );
}
