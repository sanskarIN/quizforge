final class QuestionEvaluation {
  const QuestionEvaluation({
    required this.questionId,
    required this.submittedAnswers,
    required this.correct,
    required this.score,
  });

  final String questionId;
  final Set<String> submittedAnswers;
  final bool correct;
  final double score;
}

final class QuizResult {
  QuizResult({
    required this.startedAt,
    required this.completedAt,
    required Iterable<QuestionEvaluation> evaluations,
  }) : evaluations = List<QuestionEvaluation>.unmodifiable(evaluations) {
    if (completedAt.isBefore(startedAt)) {
      throw ArgumentError('Completion time cannot be before start time.');
    }
  }

  final DateTime startedAt;
  final DateTime completedAt;
  final List<QuestionEvaluation> evaluations;

  int get correctCount =>
      evaluations.where((QuestionEvaluation item) => item.correct).length;

  int get totalCount => evaluations.length;

  double get earnedScore => evaluations.fold<double>(
        0,
        (double total, QuestionEvaluation item) => total + item.score,
      );

  double get percentage => totalCount == 0 ? 0 : (earnedScore / totalCount) * 100;

  int get bestStreak {
    int current = 0;
    int best = 0;
    for (final QuestionEvaluation evaluation in evaluations) {
      if (evaluation.correct) {
        current += 1;
        if (current > best) {
          best = current;
        }
      } else {
        current = 0;
      }
    }
    return best;
  }

  Duration get duration => completedAt.difference(startedAt);
}
