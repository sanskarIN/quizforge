import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../application/quizforge_controller_progress.dart';
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
          Text(
            strings.progress,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
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
              final double totalSpacing = AppSpacing.md * (columns - 1);
              final double cardWidth =
                  (constraints.maxWidth - totalSpacing) / columns;
              final List<_StatCard> cards = <_StatCard>[
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
              ];
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: cards
                    .map(
                      (_StatCard card) => SizedBox(
                        width: cardWidth,
                        child: card,
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          _RecentAttemptsPanel(
            controller: controller,
            refreshToken:
                '${controller.activeProfile?.id ?? 'none'}:${progress.quizCount}',
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
                  final bool active =
                      entry.profileId == controller.activeProfile?.id;
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

final class _RecentAttemptsPanel extends StatefulWidget {
  const _RecentAttemptsPanel({
    required this.controller,
    required this.refreshToken,
  });

  final QuizForgeController controller;
  final String refreshToken;

  @override
  State<_RecentAttemptsPanel> createState() => _RecentAttemptsPanelState();
}

final class _RecentAttemptsPanelState extends State<_RecentAttemptsPanel> {
  late Future<List<AttemptSummary>> _attempts;

  @override
  void initState() {
    super.initState();
    _attempts = widget.controller.loadRecentAttempts();
  }

  @override
  void didUpdateWidget(_RecentAttemptsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.controller != widget.controller) {
      _attempts = widget.controller.loadRecentAttempts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          strings.quizzesCompleted,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(strings.progressForProfile),
        const SizedBox(height: AppSpacing.md),
        FutureBuilder<List<AttemptSummary>>(
          future: _attempts,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<AttemptSummary>> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(strings.actionFailed),
                ),
              );
            }
            final List<AttemptSummary> attempts =
                snapshot.data ?? const <AttemptSummary>[];
            if (attempts.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(strings.completeQuizForLeaderboard),
                ),
              );
            }
            return Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attempts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final AttemptSummary attempt = attempts[index];
                  final String date = MaterialLocalizations.of(context)
                      .formatShortDate(attempt.completedAt);
                  final String time = TimeOfDay.fromDateTime(attempt.completedAt)
                      .format(context);
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.history_outlined),
                    ),
                    title: Text('$date · $time'),
                    subtitle: Text(
                      '${strings.correct}: ${attempt.correctCount}/${attempt.questionCount} · '
                      '${strings.bestStreak}: ${attempt.bestStreak} · '
                      '${strings.time}: ${StatsPage._formatDuration(attempt.duration)}',
                    ),
                    trailing: Text(
                      '${attempt.accuracy.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
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
          mainAxisSize: MainAxisSize.min,
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
