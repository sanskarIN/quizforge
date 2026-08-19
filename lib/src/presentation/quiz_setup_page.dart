import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import '../domain/quiz_config.dart';
import 'quiz_page.dart';

final class QuizSetupPage extends StatefulWidget {
  const QuizSetupPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

final class _QuizSetupPageState extends State<QuizSetupPage> {
  String _category = 'all';
  String _difficulty = 'all';
  final Set<String> _tags = <String>{};
  int _questionCount = 10;
  bool _timed = false;
  int _secondsPerQuestion = 30;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final List<String> categories = widget.controller.questions
        .map((Question question) => question.category)
        .toSet()
        .toList()
      ..sort();
    final List<String> tags = widget.controller.questions
        .expand((Question question) => question.tags)
        .toSet()
        .toList()
      ..sort();
    final int available = _matchingQuestions().length;
    final int maximumCount = available == 0 ? 1 : available.clamp(1, 100).toInt();
    final int effectiveCount = _questionCount.clamp(1, maximumCount).toInt();

    return Scaffold(
      appBar: AppBar(title: Text(strings.quizSetupTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                Text(
                  strings.quizSetupHeading,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(strings.quizSetupDescription),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DropdownMenu<String>(
                          initialSelection: _category,
                          label: Text(strings.category),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: <DropdownMenuEntry<String>>[
                            DropdownMenuEntry<String>(
                              value: 'all',
                              label: strings.allCategories,
                            ),
                            ...categories.map(
                              (String category) => DropdownMenuEntry<String>(
                                value: category,
                                label: category,
                              ),
                            ),
                          ],
                          onSelected: (String? value) {
                            if (value != null) {
                              setState(() {
                                _category = value;
                                _normalizeCount();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        DropdownMenu<String>(
                          initialSelection: _difficulty,
                          label: Text(strings.difficulty),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: <DropdownMenuEntry<String>>[
                            DropdownMenuEntry<String>(
                              value: 'all',
                              label: strings.allDifficulties,
                            ),
                            ...Difficulty.values.map(
                              (Difficulty value) => DropdownMenuEntry<String>(
                                value: value.name,
                                label: _difficultyLabel(strings, value),
                              ),
                            ),
                          ],
                          onSelected: (String? value) {
                            if (value != null) {
                              setState(() {
                                _difficulty = value;
                                _normalizeCount();
                              });
                            }
                          },
                        ),
                        if (tags.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            strings.tagsAllMustMatch,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: tags.map((String tag) {
                              return FilterChip(
                                label: Text('#$tag'),
                                selected: _tags.contains(tag),
                                onSelected: (bool selected) {
                                  setState(() {
                                    if (selected) {
                                      _tags.add(tag);
                                    } else {
                                      _tags.remove(tag);
                                    }
                                    _normalizeCount();
                                  });
                                },
                              );
                            }).toList(growable: false),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                strings.questions,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Text('$effectiveCount / $available'),
                          ],
                        ),
                        Slider(
                          value: effectiveCount.toDouble(),
                          min: 1,
                          max: maximumCount.toDouble(),
                          divisions: maximumCount <= 1 ? null : maximumCount - 1,
                          label: '$effectiveCount',
                          onChanged: available == 0
                              ? null
                              : (double value) {
                                  setState(() => _questionCount = value.round());
                                },
                        ),
                        const Divider(),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(strings.timedMode),
                          subtitle: Text(strings.timedModeDescription),
                          value: _timed,
                          onChanged: (bool value) => setState(() => _timed = value),
                        ),
                        if (_timed) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          DropdownMenu<int>(
                            initialSelection: _secondsPerQuestion,
                            label: Text(strings.defaultSecondsPerQuestion),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: const <DropdownMenuEntry<int>>[
                              DropdownMenuEntry<int>(value: 10, label: '10 s'),
                              DropdownMenuEntry<int>(value: 20, label: '20 s'),
                              DropdownMenuEntry<int>(value: 30, label: '30 s'),
                              DropdownMenuEntry<int>(value: 45, label: '45 s'),
                              DropdownMenuEntry<int>(value: 60, label: '60 s'),
                              DropdownMenuEntry<int>(value: 90, label: '90 s'),
                              DropdownMenuEntry<int>(value: 120, label: '120 s'),
                            ],
                            onSelected: (int? value) {
                              if (value != null) {
                                setState(() => _secondsPerQuestion = value);
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        FilledButton.icon(
                          onPressed: available == 0 ? null : _startQuiz,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(strings.startCustomQuiz),
                        ),
                      ],
                    ),
                  ),
                ),
                if (available == 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.info_outline),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(strings.noMatchingSetupQuestions)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Question> _matchingQuestions() {
    final Difficulty? difficulty = _difficulty == 'all'
        ? null
        : Difficulty.values.byName(_difficulty);
    return widget.controller.questions.where((Question question) {
      final bool categoryMatches =
          _category == 'all' || question.category == _category;
      final bool difficultyMatches =
          difficulty == null || question.difficulty == difficulty;
      final Set<String> questionTags = question.tags.map(normalizeAnswer).toSet();
      final bool tagMatches =
          _tags.map(normalizeAnswer).every(questionTags.contains);
      return categoryMatches && difficultyMatches && tagMatches;
    }).toList(growable: false);
  }

  void _normalizeCount() {
    final int available = _matchingQuestions().length;
    final int maxCount = available.clamp(1, 100).toInt();
    _questionCount = _questionCount.clamp(1, maxCount).toInt();
  }

  void _startQuiz() {
    final int available = _matchingQuestions().length;
    if (available == 0) {
      return;
    }
    final int maxCount = available.clamp(1, 100).toInt();
    final QuizConfig config = QuizConfig(
      category: _category == 'all' ? null : _category,
      difficulty: _difficulty == 'all'
          ? null
          : Difficulty.values.byName(_difficulty),
      tags: Set<String>.of(_tags),
      questionCount: _questionCount.clamp(1, maxCount).toInt(),
      timed: _timed,
      defaultSecondsPerQuestion: _secondsPerQuestion,
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    final List<Question> selected = widget.controller.quizEngine.selectQuestions(
      widget.controller.questions,
      config,
    );
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QuizPage(
          controller: widget.controller,
          questions: selected,
          title: AppLocalizations.of(context).customQuizTitle,
          config: config,
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
}
