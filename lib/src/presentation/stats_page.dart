import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/profile.dart';

final class StatsPage extends StatelessWidget {
  const StatsPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ProgressSummary progress = controller.progress;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(strings.progress, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.progressForProfile),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: columns == 1 ? 3.0 : 1.8,
                children: <Widget>[
                  _StatCard(
                    icon: Icons.quiz_outlined,
                    label: strings.quizzesCompleted,
                    value: '${progress.quizCount}',
                  ),
                  _StatCard(
                    icon: Icons.fact_check_outlined,
                    label: strings.questionsAnswered,
                    value: '${progress.questionCount}',
                  ),
                  _StatCard(
                    icon: Icons.track_changes,
                    label: strings.accuracy,
                    value: '${progress.accuracy.toStringAsFixed(1)}%',
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    label: strings.bestStreak,
                    value: '${progress.bestStreak}',
                  ),
                  _StatCard(
                    icon: Icons.schedule_outlined,
                    label: strings.playTime,
                    value: _formatDuration(progress.playTime),
                  ),
                  _StatCard(
                    icon: Icons.bookmark_outline,
                    label: strings.bookmarks,
                    value: '${controller.bookmarkIds.length}',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            strings.categoryPerformance,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.categoryPerformanceDescription),
          const SizedBox(height: AppSpacing.md),
          if (controller.categoryProgress.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(strings.completeQuizForCategoryStats),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.categoryProgress.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final CategoryProgress item = controller.categoryProgress[index];
                  return ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: Text(item.category),
                    subtitle: Text(
                      strings.categoryAnswerSummary(
                        item.correctCount,
                        item.questionCount,
                      ),
                    ),
                    trailing: Text(
                      '${item.accuracy.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            strings.localLeaderboard,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(strings.leaderboardDescription),
          const SizedBox(height: AppSpacing.md),
          if (controller.leaderboard.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(strings.completeQuizForLeaderboard),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.leaderboard.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final LeaderboardEntry entry = controller.leaderboard[index];
                  final bool active = entry.profileId == controller.activeProfile?.id;
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(entry.displayName),
                    subtitle: Text(
                      strings.accuracyValue(entry.accuracy.toStringAsFixed(1)),
                    ),
                    trailing: Text(
                      strings.pointsValue(entry.points),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    selected: active,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration value) {
    if (value.inHours > 0) {
      return '${value.inHours}h ${value.inMinutes.remainder(60)}m';
    }
    return '${value.inMinutes}m ${value.inSeconds.remainder(60)}s';
  }
}

final class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
