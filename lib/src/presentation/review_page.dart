import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import '../domain/quiz_result.dart';

final class ReviewPage extends StatelessWidget {
  const ReviewPage({
    required this.controller,
    required this.questions,
    required this.result,
    super.key,
  });

  final QuizForgeController controller;
  final List<Question> questions;
  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.review)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            _SummaryCard(result: result),
            const SizedBox(height: AppSpacing.lg),
            Text(strings.answerReview, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            for (int index = 0; index < questions.length; index += 1) ...<Widget>[
              _ReviewCard(
                question: questions[index],
                evaluation: result.evaluations[index],
                bookmarked: controller.bookmarkIds.contains(questions[index].id),
                onBookmark: () => controller.toggleBookmark(questions[index].id),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

final class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.md,
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            _Metric(
              label: strings.score,
              value: '${result.percentage.toStringAsFixed(0)}%',
            ),
            _Metric(
              label: strings.correct,
              value: '${result.correctCount}/${result.totalCount}',
            ),
            _Metric(label: strings.bestStreak, value: '${result.bestStreak}'),
            _Metric(label: strings.time, value: _formatDuration(result.duration)),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration value) {
    final int minutes = value.inMinutes;
    final int seconds = value.inSeconds.remainder(60);
    return '${minutes}m ${seconds}s';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

final class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.question,
    required this.evaluation,
    required this.bookmarked,
    required this.onBookmark,
  });

  final Question question;
  final QuestionEvaluation evaluation;
  final bool bookmarked;
  final Future<void> Function() onBookmark;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final IconData statusIcon = evaluation.correct ? Icons.check_circle : Icons.cancel;
    final Color statusColor = evaluation.correct ? colors.primary : colors.error;
    final String statusLabel = evaluation.correct ? strings.correct : strings.incorrect;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  label: statusLabel,
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    question.prompt,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: bookmarked
                      ? strings.removeBookmark
                      : strings.bookmarkQuestion,
                  onPressed: onBookmark,
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${strings.yourAnswer}: ${_displayAnswers(strings, evaluation.submittedAnswers)}',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${strings.correctAnswer}: ${_displayAnswers(strings, question.correctAnswers)}',
            ),
            if (question.explanation.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                question.explanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _displayAnswers(
    AppLocalizations strings,
    Iterable<String> answers,
  ) {
    if (answers.isEmpty) {
      return strings.noAnswer;
    }
    return answers.join(', ');
  }
}
