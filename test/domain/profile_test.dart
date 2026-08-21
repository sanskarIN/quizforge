import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/profile.dart';

void main() {
  group('PlayerProfile', () {
    test('accepts a normal local display name', () {
      const PlayerProfile profile = PlayerProfile(
        id: 'profile-1',
        displayName: 'Local Player',
      );

      expect(profile.validate(), isEmpty);
    });

    test('rejects blank ids and out-of-range display names', () {
      const PlayerProfile profile = PlayerProfile(id: ' ', displayName: 'A');

      expect(profile.validate(), hasLength(2));
    });
  });

  group('ProgressSummary', () {
    test('calculates accuracy and play time', () {
      const ProgressSummary summary = ProgressSummary(
        quizCount: 3,
        questionCount: 20,
        correctCount: 15,
        bestStreak: 6,
        totalSeconds: 125,
      );

      expect(summary.accuracy, 75);
      expect(summary.playTime, const Duration(seconds: 125));
    });

    test('reports zero accuracy with no answers', () {
      expect(const ProgressSummary().accuracy, 0);
    });
  });

  test('category progress calculates accuracy', () {
    const CategoryProgress progress = CategoryProgress(
      category: 'Science',
      questionCount: 8,
      correctCount: 6,
    );

    expect(progress.accuracy, 75);
  });
}
