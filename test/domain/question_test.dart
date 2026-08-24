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

    test('rejects blank and normalized duplicate accepted answers', () {
      final Question blank = Question(
        id: 'blank-answer',
        type: QuestionType.shortAnswer,
        prompt: 'Provide an answer.',
        correctAnswers: const <String>{'   '},
        category: 'Testing',
        difficulty: Difficulty.easy,
      );
      final Question duplicates = Question(
        id: 'duplicate-answer',
        type: QuestionType.shortAnswer,
        prompt: 'Provide an answer.',
        correctAnswers: const <String>{'Alpha', ' alpha '},
        category: 'Testing',
        difficulty: Difficulty.easy,
      );

      expect(
        blank.validate(),
        contains('Correct answers must be non-empty and unique.'),
      );
      expect(
        duplicates.validate(),
        contains('Correct answers must be non-empty and unique.'),
      );
    });

    test(
      'JSON parser rejects duplicate accepted answers before set collapse',
      () {
        final Map<String, Object?> json = <String, Object?>{
          'id': 'duplicate-json-answer',
          'type': 'shortAnswer',
          'prompt': 'Provide an answer.',
          'correctAnswers': <String>['Alpha', ' alpha '],
          'category': 'Testing',
          'difficulty': 'easy',
        };

        expect(
          () => Question.fromJson(json),
          throwsA(
            isA<FormatException>().having(
              (FormatException error) => error.message,
              'message',
              'Correct answers must be non-empty and unique.',
            ),
          ),
        );
      },
    );

    test('rejects duplicate tags after normalization', () {
      final Question question = Question(
        id: 'duplicate-tags',
        type: QuestionType.shortAnswer,
        prompt: 'Provide an answer.',
        correctAnswers: const <String>{'answer'},
        category: 'Testing',
        difficulty: Difficulty.easy,
        tags: const <String>['Basics', ' basics '],
      );

      expect(
        question.validate(),
        contains('Tags must be non-empty and unique.'),
      );
    });

    test('rejects custom choices for true false questions', () {
      final Question question = Question(
        id: 'true-false-choices',
        type: QuestionType.trueFalse,
        prompt: 'The fixture is deterministic.',
        choices: const <String>['Yes', 'No'],
        correctAnswers: const <String>{'true'},
        category: 'Testing',
        difficulty: Difficulty.easy,
      );

      expect(
        question.validate(),
        contains('True/false questions must not define custom choices.'),
      );
    });

    test('enforces bounded content and time limits', () {
      final String longPrompt = List<String>.filled(
        Question.maxPromptLength + 1,
        'x',
      ).join();
      final Question question = Question(
        id: 'bounded-question',
        type: QuestionType.shortAnswer,
        prompt: longPrompt,
        correctAnswers: const <String>{'answer'},
        category: 'Testing',
        difficulty: Difficulty.easy,
        timeLimitSeconds: Question.maxTimeLimitSeconds + 1,
      );

      expect(
        question.validate(),
        contains(
          'Prompt must be at most ${Question.maxPromptLength} characters.',
        ),
      );
      expect(
        question.validate(),
        contains(
          'Time limit must not exceed ${Question.maxTimeLimitSeconds} seconds.',
        ),
      );
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
