import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import '../domain/quiz_config.dart';
import 'quiz_page.dart';
import 'quiz_setup_page.dart';

final class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<String> categories = controller.questions
        .map((Question question) => question.category)
        .toSet()
        .toList()
      ..sort();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(
            strings.dashboardTitle,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.dashboardSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 1000
                  ? 4
                  : constraints.maxWidth >= 700
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: columns == 1 ? 2.4 : 1.55,
                children: <Widget>[
                  _ActionCard(
                    icon: Icons.today_outlined,
                    title: strings.dailyQuiz,
                    description: strings.dailyQuizDescription,
                    actionLabel: strings.playDaily,
                    onPressed: () => _openDaily(context),
                  ),
                  _ActionCard(
                    icon: Icons.shuffle,
                    title: strings.randomPractice,
                    description: strings.randomPracticeDescription,
                    actionLabel: strings.startPractice,
                    onPressed: () => _openPractice(context),
                  ),
                  _ActionCard(
                    icon: Icons.timer_outlined,
                    title: strings.timedSprint,
                    description: strings.timedSprintDescription,
                    actionLabel: strings.startSprint,
                    onPressed: () => _openTimed(context),
                  ),
                  _ActionCard(
                    icon: Icons.tune,
                    title: strings.buildQuiz,
                    description: strings.buildQuizDescription,
                    actionLabel: strings.customize,
                    onPressed: () => _openBuilder(context),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(strings.progress, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.md,
                children: <Widget>[
                  _Metric(
                    label: strings.quizzes,
                    value: '${controller.progress.quizCount}',
                  ),
                  _Metric(
                    label: strings.accuracy,
                    value: '${controller.progress.accuracy.toStringAsFixed(0)}%',
                  ),
                  _Metric(
                    label: strings.bestStreak,
                    value: '${controller.progress.bestStreak}',
                  ),
                  _Metric(
                    label: strings.bookmarks,
                    value: '${controller.bookmarkIds.length}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(strings.categories, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (categories.isEmpty)
            Text(strings.noCategories)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories
                  .map((String category) => Chip(label: Text(category)))
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Future<void> _openDaily(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final List<Question> questions = controller.quizEngine.dailyQuiz(
      controller.questions,
      now,
      questionCount: 10,
    );
    await _pushQuiz(
      context,
      title: strings.dailyQuizTitle,
      questions: questions,
      config: QuizConfig(
        questionCount: 10,
        seed: now.year * 10000 + now.month * 100 + now.day,
      ),
    );
  }

  Future<void> _openPractice(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QuizConfig config = QuizConfig(
      questionCount: 10,
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    final List<Question> questions =
        controller.quizEngine.selectQuestions(controller.questions, config);
    await _pushQuiz(
      context,
      title: strings.randomPracticeTitle,
      questions: questions,
      config: config,
    );
  }

  Future<void> _openTimed(BuildContext context) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final QuizConfig config = QuizConfig(
      questionCount: 5,
      timed: true,
      defaultSecondsPerQuestion: 20,
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    final List<Question> questions =
        controller.quizEngine.selectQuestions(controller.questions, config);
    await _pushQuiz(
      context,
      title: strings.timedSprintTitle,
      questions: questions,
      config: config,
    );
  }

  Future<void> _openBuilder(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QuizSetupPage(controller: controller),
      ),
    );
  }

  Future<void> _pushQuiz(
    BuildContext context, {
    required String title,
    required List<Question> questions,
    required QuizConfig config,
  }) async {
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).noQuestionsForQuiz)),
      );
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QuizPage(
          controller: controller,
          questions: questions,
          title: title,
          config: config,
        ),
      ),
    );
  }
}

final class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 32),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: Text(description)),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onPressed, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

final class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
