import 'package:flutter/material.dart';

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
    final int effectiveCount = available == 0
        ? 1
        : _questionCount.clamp(1, available > 100 ? 100 : available);

    return Scaffold(
      appBar: AppBar(title: const Text('Build a quiz')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                Text(
                  'Choose your practice set',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Filter the local question bank, choose timing, then start a deterministic set for this session.',
                ),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        DropdownMenu<String>(
                          initialSelection: _category,
                          label: const Text('Category'),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: <DropdownMenuEntry<String>>[
                            const DropdownMenuEntry<String>(
                              value: 'all',
                              label: 'All categories',
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
                          label: const Text('Difficulty'),
                          expandedInsets: EdgeInsets.zero,
                          dropdownMenuEntries: <DropdownMenuEntry<String>>[
                            const DropdownMenuEntry<String>(
                              value: 'all',
                              label: 'All difficulties',
                            ),
                            ...Difficulty.values.map(
                              (Difficulty value) => DropdownMenuEntry<String>(
                                value: value.name,
                                label: _titleCase(value.name),
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
                            'Tags (all selected tags must match)',
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
                                'Questions',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Text('$effectiveCount of $available available'),
                          ],
                        ),
                        Slider(
                          value: effectiveCount.toDouble(),
                          min: 1,
                          max: (available > 0 ? available.clamp(1, 100) : 1).toDouble(),
                          divisions: available <= 1 ? null : available.clamp(1, 100) - 1,
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
                          title: const Text('Timed mode'),
                          subtitle: const Text(
                            'Automatically submit a question when its timer expires.',
                          ),
                          value: _timed,
                          onChanged: (bool value) => setState(() => _timed = value),
                        ),
                        if (_timed) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          DropdownMenu<int>(
                            initialSelection: _secondsPerQuestion,
                            label: const Text('Default seconds per question'),
                            expandedInsets: EdgeInsets.zero,
                            dropdownMenuEntries: const <DropdownMenuEntry<int>>[
                              DropdownMenuEntry<int>(value: 10, label: '10 seconds'),
                              DropdownMenuEntry<int>(value: 20, label: '20 seconds'),
                              DropdownMenuEntry<int>(value: 30, label: '30 seconds'),
                              DropdownMenuEntry<int>(value: 45, label: '45 seconds'),
                              DropdownMenuEntry<int>(value: 60, label: '60 seconds'),
                              DropdownMenuEntry<int>(value: 90, label: '90 seconds'),
                              DropdownMenuEntry<int>(value: 120, label: '120 seconds'),
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
                          label: const Text('Start custom quiz'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (available == 0) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.info_outline),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'No local questions match these filters. Remove a filter or add/import matching questions.',
                            ),
                          ),
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
    final int maxCount = available.clamp(1, 100);
    _questionCount = _questionCount.clamp(1, maxCount);
  }

  void _startQuiz() {
    final int available = _matchingQuestions().length;
    if (available == 0) {
      return;
    }
    final QuizConfig config = QuizConfig(
      category: _category == 'all' ? null : _category,
      difficulty: _difficulty == 'all'
          ? null
          : Difficulty.values.byName(_difficulty),
      tags: Set<String>.of(_tags),
      questionCount: _questionCount.clamp(1, available.clamp(1, 100)),
      timed: _timed,
      defaultSecondsPerQuestion: _secondsPerQuestion,
      seed: DateTime.now().microsecondsSinceEpoch,
    );
    final List<Question> selected =
        widget.controller.quizEngine.selectQuestions(widget.controller.questions, config);
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => QuizPage(
          controller: widget.controller,
          questions: selected,
          title: 'Custom Quiz',
          config: config,
        ),
      ),
    );
  }

  static String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
