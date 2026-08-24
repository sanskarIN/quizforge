import '../data/app_database_progress.dart';
import '../domain/profile.dart';
import 'quizforge_controller.dart';

extension QuizForgeControllerProgress on QuizForgeController {
  Future<List<AttemptSummary>> loadRecentAttempts({int limit = 10}) {
    final PlayerProfile? profile = activeProfile;
    if (profile == null) {
      return Future<List<AttemptSummary>>.value(const <AttemptSummary>[]);
    }
    return database.loadRecentAttempts(profile.id, limit: limit);
  }
}
