import 'package:flutter/material.dart';

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
    final ProgressSummary progress = controller.progress;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text('Progress', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Statistics for ${controller.activeProfile?.displayName ?? 'the active profile'}.',
          ),
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
                    label: 'Quizzes completed',
                    value: '${progress.quizCount}',
                  ),
                  _StatCard(
                    icon: Icons.track_changes,
                    label: 'Accuracy',
                    value: '${progress.accuracy.toStringAsFixed(1)}%',
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Best streak',
                    value: '${progress.bestStreak}',
                  ),
                  _StatCard(
                    icon: Icons.schedule_outlined,
                    label: 'Play time',
                    value: _formatDuration(progress.playTime),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Local leaderboard', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Leaderboard points are stored only on this device and are calculated from correct answers plus best-streak bonuses.',
          ),
          const SizedBox(height: AppSpacing.md),
          if (controller.leaderboard.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('Complete a quiz to populate the leaderboard.'),
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
                    subtitle: Text('${entry.accuracy.toStringAsFixed(1)}% accuracy'),
                    trailing: Text(
                      '${entry.points} pts',
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
