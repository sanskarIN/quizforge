import 'question.dart';

final class QuizConfig {
  const QuizConfig({
    this.category,
    this.difficulty,
    this.tags = const <String>{},
    this.questionCount = 10,
    this.timed = false,
    this.defaultSecondsPerQuestion = 30,
    this.seed,
  });

  final String? category;
  final Difficulty? difficulty;
  final Set<String> tags;
  final int questionCount;
  final bool timed;
  final int defaultSecondsPerQuestion;
  final int? seed;

  List<String> validate() {
    final List<String> errors = <String>[];
    if (questionCount <= 0 || questionCount > 100) {
      errors.add('Question count must be between 1 and 100.');
    }
    if (defaultSecondsPerQuestion < 5 || defaultSecondsPerQuestion > 600) {
      errors.add('Time per question must be between 5 and 600 seconds.');
    }
    return errors;
  }
}
