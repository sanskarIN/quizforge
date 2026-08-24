import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import 'import_export_page.dart';

final class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({required this.controller, super.key});

  final QuizForgeController controller;

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

final class _QuestionBankPageState extends State<QuestionBankPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _category;
  Difficulty? _difficulty;
  bool _bookmarkedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<String> categories =
        widget.controller.questions
            .map((Question question) => question.category)
            .toSet()
            .toList()
          ..sort();
    final List<Question> results = widget.controller.searchQuestions(
      _searchController.text,
      category: _category,
      difficulty: _difficulty,
      bookmarkedOnly: _bookmarkedOnly,
    );

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      strings.questionBank,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        unawaited(
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  ImportExportPage(
                                    controller: widget.controller,
                                  ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.import_export),
                      label: Text(strings.importExport),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: strings.searchQuestions,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    DropdownMenu<String?>(
                      initialSelection: _category,
                      label: Text(strings.category),
                      dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                        DropdownMenuEntry<String?>(
                          value: null,
                          label: strings.allCategories,
                        ),
                        ...categories.map(
                          (String category) => DropdownMenuEntry<String?>(
                            value: category,
                            label: category,
                          ),
                        ),
                      ],
                      onSelected: (String? value) =>
                          setState(() => _category = value),
                    ),
                    DropdownMenu<Difficulty?>(
                      initialSelection: _difficulty,
                      label: Text(strings.difficulty),
                      dropdownMenuEntries: <DropdownMenuEntry<Difficulty?>>[
                        DropdownMenuEntry<Difficulty?>(
                          value: null,
                          label: strings.allDifficultiesFilter,
                        ),
                        ...Difficulty.values.map(
                          (Difficulty value) => DropdownMenuEntry<Difficulty?>(
                            value: value,
                            label: _difficultyLabel(strings, value),
                          ),
                        ),
                      ],
                      onSelected: (Difficulty? value) =>
                          setState(() => _difficulty = value),
                    ),
                    FilterChip(
                      label: Text(strings.bookmarksOnly),
                      selected: _bookmarkedOnly,
                      onSelected: (bool value) =>
                          setState(() => _bookmarkedOnly = value),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(strings.questionCountLabel(results.length)),
              ],
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const _EmptyBank()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final Question question = results[index];
                      return _QuestionCard(
                        question: question,
                        bookmarked: widget.controller.bookmarkIds.contains(
                          question.id,
                        ),
                        onBookmark: () {
                          unawaited(_toggleBookmark(question.id));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBookmark(String questionId) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      await widget.controller.toggleBookmark(questionId);
    } on Object catch (error) {
      widget.controller.logger.error(
        'bookmark.persist.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.actionFailed)));
      }
    }
  }

  static String _difficultyLabel(
    AppLocalizations strings,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return strings.easy;
      case Difficulty.medium:
        return strings.medium;
      case Difficulty.hard:
        return strings.hard;
    }
  }
}

final class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.bookmarked,
    required this.onBookmark,
  });

  final Question question;
  final bool bookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                  icon: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                Chip(label: Text(question.category)),
                Chip(
                  label: Text(_difficultyLabel(strings, question.difficulty)),
                ),
                Chip(label: Text(_questionTypeLabel(strings, question.type))),
                for (final String tag in question.tags)
                  Chip(label: Text('#$tag')),
              ],
            ),
            if (question.explanation.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                question.explanation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _difficultyLabel(
    AppLocalizations strings,
    Difficulty difficulty,
  ) {
    switch (difficulty) {
      case Difficulty.easy:
        return strings.easy;
      case Difficulty.medium:
        return strings.medium;
      case Difficulty.hard:
        return strings.hard;
    }
  }

  static String _questionTypeLabel(
    AppLocalizations strings,
    QuestionType type,
  ) {
    switch (type) {
      case QuestionType.multipleChoice:
        return strings.multipleChoice;
      case QuestionType.trueFalse:
        return strings.trueFalse;
      case QuestionType.multiSelect:
        return strings.multiSelect;
      case QuestionType.shortAnswer:
        return strings.shortAnswer;
    }
  }
}

final class _EmptyBank extends StatelessWidget {
  const _EmptyBank();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(
              strings.noQuestionsMatch,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.adjustSearchFilters),
          ],
        ),
      ),
    );
  }
}
