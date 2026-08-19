import '../domain/question.dart';

abstract interface class QuestionStore {
  Future<List<Question>> loadAll();

  Future<void> saveAll(Iterable<Question> questions);
}
