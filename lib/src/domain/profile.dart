final class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.displayName,
    this.createdAt,
  });

  final String id;
  final String displayName;
  final DateTime? createdAt;

  List<String> validate() {
    final List<String> errors = <String>[];
    final String name = displayName.trim();
    if (id.trim().isEmpty) {
      errors.add('Profile id is required.');
    }
    if (name.length < 2 || name.length > 32) {
      errors.add('Display name must be between 2 and 32 characters.');
    }
    return errors;
  }
}

final class ProgressSummary {
  const ProgressSummary({
    this.quizCount = 0,
    this.questionCount = 0,
    this.correctCount = 0,
    this.bestStreak = 0,
    this.totalSeconds = 0,
  });

  final int quizCount;
  final int questionCount;
  final int correctCount;
  final int bestStreak;
  final int totalSeconds;

  double get accuracy =>
      questionCount == 0 ? 0 : (correctCount / questionCount) * 100;

  Duration get playTime => Duration(seconds: totalSeconds);
}

final class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.questionCount,
    required this.correctCount,
  });

  final String category;
  final int questionCount;
  final int correctCount;

  double get accuracy =>
      questionCount == 0 ? 0 : (correctCount / questionCount) * 100;
}

final class AttemptSummary {
  const AttemptSummary({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.correctCount,
    required this.questionCount,
    required this.bestStreak,
    required this.earnedScore,
  });

  final int id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int correctCount;
  final int questionCount;
  final int bestStreak;
  final double earnedScore;

  double get accuracy =>
      questionCount == 0 ? 0 : (correctCount / questionCount) * 100;

  Duration get duration => completedAt.difference(startedAt);
}

final class LeaderboardEntry {
  const LeaderboardEntry({
    required this.profileId,
    required this.displayName,
    required this.points,
    required this.accuracy,
  });

  final String profileId;
  final String displayName;
  final int points;
  final double accuracy;
}
