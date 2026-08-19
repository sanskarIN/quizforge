import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  group('Question', () {
    test('valid multiple choice has no validation errors', () {
      final Question question = Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: 'Which answer is correct?',
        choices: const <String>['A', 'B'],
        correctAnswers: const <String>{'A'},
        category: 'Demo',
        difficulty: Difficulty.easy,
      );

      expect(question.validate(), isEmpty);
    });

    test('rejects correct answer missing from choices', () {
      final Question question = Question(
        id: 'q1',
        type: QuestionType.multipleChoice,
        prompt: 'Which answer is correct?',
        choices: const <String>['A', 'B'],
        correctAnswers: const <String>{'C'},
        category: 'Demo',
        difficulty: Difficulty.easy,
      );

      expect(
        question.validate(),
        contains('Correct answer "C" is not one of the choices.'),
      );
    });

    test('short answer supports multiple accepted answers', () {
      final Question question = Question(
        id: 'q2',
        type: QuestionType.shortAnswer,
        prompt: 'Name the circle constant.',
        correctAnswers: const <String>{'pi', 'π'},
        category: 'Math',
        difficulty: Difficulty.easy,
      );

      expect(question.validate(), isEmpty);
    });

    test('normalization trims lowercases and collapses whitespace', () {
      expect(normalizeAnswer('  Hello   WORLD  '), 'hello world');
    });

    test('fingerprint ignores casing and extra whitespace', () {
      final Question first = Question(
        id: 'first',
        type: QuestionType.shortAnswer,
        prompt: 'What is Flutter?',
        correctAnswers: const <String>{'framework'},
        category: 'Computing',
        difficulty: Difficulty.easy,
      );
      final Question second = Question(
        id: 'second',
        type: QuestionType.shortAnswer,
        prompt: '  WHAT   IS flutter? ',
        correctAnswers: const <String>{'framework'},
        category: ' computing ',
        difficulty: Difficulty.hard,
      );

      expect(first.fingerprint, second.fingerprint);
    });
  });
}
