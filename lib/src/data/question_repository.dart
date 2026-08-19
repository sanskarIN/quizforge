import '../domain/question.dart';
import 'app_database.dart';
import 'demo_questions.dart';
import 'question_store.dart';

final class QuestionRepository implements QuestionStore {
  const QuestionRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<Question>> loadAll() async {
    final List<Question> questions = await database.loadQuestions();
    if (questions.isNotEmpty) {
      return questions;
    }
    final List<Question> starter = buildDemoQuestions();
    await database.upsertQuestions(starter);
    return database.loadQuestions();
  }

  @override
  Future<void> saveAll(Iterable<Question> questions) =>
      database.upsertQuestions(questions);
}
