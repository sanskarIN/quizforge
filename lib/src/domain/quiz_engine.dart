import 'question.dart';
import 'quiz_config.dart';
import 'quiz_result.dart';

final class QuizEngine {
  const QuizEngine();

  List<Question> selectQuestions(
    Iterable<Question> bank,
    QuizConfig config,
  ) {
    final List<String> configErrors = config.validate();
    if (configErrors.isNotEmpty) {
      throw ArgumentError(configErrors.join(' '));
    }

    final Set<String> normalizedTags =
        config.tags.map(normalizeAnswer).toSet();
    final List<Question> candidates = bank.where((Question question) {
      final bool categoryMatches = config.category == null ||
          normalizeAnswer(question.category) == normalizeAnswer(config.category!);
      final bool difficultyMatches =
          config.difficulty == null || question.difficulty == config.difficulty;
      final Set<String> questionTags =
          question.tags.map(normalizeAnswer).toSet();
      final bool tagMatches = normalizedTags.isEmpty ||
          normalizedTags.every(questionTags.contains);
      return categoryMatches && difficultyMatches && tagMatches;
    }).toList(growable: false);

    final _StableRandom random = _StableRandom(config.seed ?? 0);
    final List<Question> shuffled = List<Question>.of(candidates);
    for (int index = shuffled.length - 1; index > 0; index -= 1) {
      final int swapIndex = random.nextInt(index + 1);
      final Question current = shuffled[index];
      shuffled[index] = shuffled[swapIndex];
      shuffled[swapIndex] = current;
    }

    return shuffled.take(config.questionCount).toList(growable: false);
  }

  List<Question> dailyQuiz(
    Iterable<Question> bank,
    DateTime localDay, {
    int questionCount = 10,
  }) {
    final int daySeed = localDay.year * 10000 + localDay.month * 100 + localDay.day;
    return selectQuestions(
      bank,
      QuizConfig(questionCount: questionCount, seed: daySeed),
    );
  }

  QuestionEvaluation evaluate(
    Question question,
    Iterable<String> submittedAnswers,
  ) {
    final Set<String> submitted = submittedAnswers
        .map(normalizeAnswer)
        .where((String value) => value.isNotEmpty)
        .toSet();
    final Set<String> expected =
        question.correctAnswers.map(normalizeAnswer).toSet();

    final bool correct;
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
      case QuestionType.multiSelect:
        correct = submitted.length == expected.length &&
            submitted.every(expected.contains);
        break;
      case QuestionType.shortAnswer:
        correct = submitted.length == 1 && expected.contains(submitted.single);
        break;
    }

    return QuestionEvaluation(
      questionId: question.id,
      submittedAnswers: submitted,
      correct: correct,
      score: correct ? 1 : 0,
    );
  }

  QuizResult finish({
    required DateTime startedAt,
    required DateTime completedAt,
    required Iterable<QuestionEvaluation> evaluations,
  }) {
    return QuizResult(
      startedAt: startedAt,
      completedAt: completedAt,
      evaluations: evaluations,
    );
  }
}

/// Small deterministic PRNG used only for quiz ordering.
///
/// Park-Miller arithmetic stays below JavaScript's exact-integer limit, so the
/// same seed produces the same sequence on Dart VM and Dart-compiled Web.
final class _StableRandom {
  _StableRandom(int seed) : _state = _normalizeSeed(seed);

  static const int _modulus = 2147483647;
  static const int _multiplier = 48271;

  int _state;

  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) {
      throw ArgumentError.value(
        maxExclusive,
        'maxExclusive',
        'Must be greater than zero.',
      );
    }
    _state = (_state * _multiplier) % _modulus;
    return _state % maxExclusive;
  }

  static int _normalizeSeed(int seed) {
    final int range = _modulus - 1;
    return ((seed % range) + range) % range + 1;
  }
}
