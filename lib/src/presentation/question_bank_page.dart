import 'dart:async';

import 'package:flutter/material.dart';

import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import 'import_export_page.dart';

final class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({
    required this.controller,
    super.key,
  });

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
    final List<String> categories = widget.controller.questions
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Question bank',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        unawaited(
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) => ImportExportPage(
                                controller: widget.controller,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.import_export),
                      label: const Text('Import / export'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search questions, categories, or tags',
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
                      label: const Text('Category'),
                      dropdownMenuEntries: <DropdownMenuEntry<String?>>[
                        const DropdownMenuEntry<String?>(
                          value: null,
                          label: 'All categories',
                        ),
                        ...categories.map(
                          (String category) => DropdownMenuEntry<String?>(
                            value: category,
                            label: category,
                          ),
                        ),
                      ],
                      onSelected: (String? value) => setState(() => _category = value),
                    ),
                    DropdownMenu<Difficulty?>(
                      initialSelection: _difficulty,
                      label: const Text('Difficulty'),
                      dropdownMenuEntries: <DropdownMenuEntry<Difficulty?>>[
                        const DropdownMenuEntry<Difficulty?>(
                          value: null,
                          label: 'All difficulties',
                        ),
                        ...Difficulty.values.map(
                          (Difficulty value) => DropdownMenuEntry<Difficulty?>(
                            value: value,
                            label: value.name,
                          ),
                        ),
                      ],
                      onSelected: (Difficulty? value) =>
                          setState(() => _difficulty = value),
                    ),
                    FilterChip(
                      label: const Text('Bookmarks only'),
                      selected: _bookmarkedOnly,
                      onSelected: (bool value) =>
                          setState(() => _bookmarkedOnly = value),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('${results.length} question${results.length == 1 ? '' : 's'}'),
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
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (BuildContext context, int index) {
                      final Question question = results[index];
                      return _QuestionCard(
                        question: question,
                        bookmarked:
                            widget.controller.bookmarkIds.contains(question.id),
                        onBookmark: () {
                          unawaited(widget.controller.toggleBookmark(question.id));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
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
                  tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark question',
                  onPressed: onBookmark,
                  icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                Chip(label: Text(question.category)),
                Chip(label: Text(question.difficulty.name)),
                Chip(label: Text(question.type.name)),
                for (final String tag in question.tags) Chip(label: Text('#$tag')),
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
}

final class _EmptyBank extends StatelessWidget {
  const _EmptyBank();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text('No questions match', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text('Adjust the search or filters and try again.'),
          ],
        ),
      ),
    );
  }
}
