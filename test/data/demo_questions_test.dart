import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/demo_questions.dart';
import 'package:quizforge/src/domain/question.dart';

void main() {
  test('starter question bank is valid and duplicate-free', () {
    final List<Question> questions = buildDemoQuestions();

    expect(questions, isNotEmpty);
    expect(
      questions.expand((Question question) => question.validate()),
      isEmpty,
    );
    expect(
      questions.map((Question question) => question.id).toSet(),
      hasLength(questions.length),
    );
    expect(
      questions.map((Question question) => question.fingerprint).toSet(),
      hasLength(questions.length),
    );
  });

  test('starter bank exercises every supported question type', () {
    final Set<QuestionType> types = buildDemoQuestions()
        .map((Question question) => question.type)
        .toSet();

    expect(types, QuestionType.values.toSet());
  });

  test('starter bank spans multiple practice categories', () {
    final Set<String> categories = buildDemoQuestions()
        .map((Question question) => question.category)
        .toSet();

    expect(categories.length, greaterThanOrEqualTo(4));
    expect(
      categories,
      containsAll(<String>['Science', 'Computing', 'Mathematics', 'Geography']),
    );
  });
}
