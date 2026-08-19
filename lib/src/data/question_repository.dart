import '../domain/question.dart';
import 'app_database.dart';
import 'demo_questions.dart';

final class QuestionRepository {
  const QuestionRepository(this.database);

  final AppDatabase database;

  Future<List<Question>> loadAll() async {
    final List<Question> questions = await database.loadQuestions();
    if (questions.isNotEmpty) {
      return questions;
    }
    final List<Question> starter = buildDemoQuestions();
    await database.upsertQuestions(starter);
    return database.loadQuestions();
  }

  Future<void> saveAll(Iterable<Question> questions) =>
      database.upsertQuestions(questions);
}
