import 'dart:async';

import 'package:flutter/material.dart';

import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';
import '../domain/quiz_config.dart';
import '../domain/quiz_result.dart';
import 'review_page.dart';

final class QuizPage extends StatefulWidget {
  const QuizPage({
    required this.controller,
    required this.questions,
    required this.title,
    this.config = const QuizConfig(),
    super.key,
  });

  final QuizForgeController controller;
  final List<Question> questions;
  final String title;
  final QuizConfig config;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

final class _QuizPageState extends State<QuizPage> {
  final TextEditingController _shortAnswerController = TextEditingController();
  final Map<String, Set<String>> _answers = <String, Set<String>>{};
  final List<QuestionEvaluation> _evaluations = <QuestionEvaluation>[];

  late final DateTime _startedAt;
  Timer? _timer;
  int _index = 0;
  int _secondsRemaining = 0;
  bool _busy = false;
  bool _allowPop = false;

  Question get _question => widget.questions[_index];

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shortAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No questions match this quiz.')),
      );
    }

    final Question question = _question;
    final double progress = (_index + 1) / widget.questions.length;
    final bool confirmExit = widget.controller.settings.confirmBeforeExitQuiz;
    return PopScope<void>(
      canPop: _allowPop || !confirmExit,
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop && confirmExit && !_allowPop) {
          unawaited(_confirmExit());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            if (widget.config.timed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Center(
                  child: Semantics(
                    label: '$_secondsRemaining seconds remaining',
                    liveRegion: _secondsRemaining <= 5,
                    child: Chip(
                      avatar: const Icon(Icons.timer_outlined, size: 18),
                      label: Text('${_secondsRemaining}s'),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          semanticsLabel:
                              'Question ${_index + 1} of ${widget.questions.length}',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text('${_index + 1}/${widget.questions.length}'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      Chip(label: Text(question.category)),
                      Chip(label: Text(question.difficulty.name)),
                      Chip(label: Text(_typeLabel(question.type))),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Semantics(
                    header: true,
                    hint: widget.controller.settings.screenReaderHints
                        ? _screenReaderHint(question.type)
                        : null,
                    child: Text(
                      question.prompt,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _answerEditor(question),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                unawaited(_submit(forced: true));
                              },
                        child: const Text('Skip'),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _busy
                            ? null
                            : () {
                                unawaited(_submit());
                              },
                        icon: Icon(
                          _index == widget.questions.length - 1
                              ? Icons.flag_outlined
                              : Icons.arrow_forward,
                        ),
                        label: Text(
                          _index == widget.questions.length - 1
                              ? 'Finish quiz'
                              : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _answerEditor(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _singleSelect(question, question.choices);
      case QuestionType.trueFalse:
        return _singleSelect(question, const <String>['True', 'False']);
      case QuestionType.multiSelect:
        final Set<String> selected = _answers[question.id] ?? <String>{};
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: question.choices.map((String choice) {
            final bool active = selected.contains(choice);
            return FilterChip(
              label: Text(choice),
              selected: active,
              onSelected: (bool value) {
                setState(() {
                  final Set<String> next = Set<String>.of(selected);
                  if (value) {
                    next.add(choice);
                  } else {
                    next.remove(choice);
                  }
                  _answers[question.id] = next;
                });
              },
            );
          }).toList(growable: false),
        );
      case QuestionType.shortAnswer:
        return TextField(
          controller: _shortAnswerController,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Your answer',
            hintText: 'Type your answer',
          ),
          onChanged: (String value) {
            _answers[question.id] = <String>{value};
          },
          onSubmitted: (_) {
            if (!_busy) {
              unawaited(_submit());
            }
          },
        );
    }
  }

  Widget _singleSelect(Question question, List<String> choices) {
    final String? selected = (_answers[question.id] ?? <String>{}).firstOrNull;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: choices.map((String choice) {
        return ChoiceChip(
          label: Text(choice),
          selected: selected == choice,
          onSelected: (_) {
            setState(() => _answers[question.id] = <String>{choice});
          },
        );
      }).toList(growable: false),
    );
  }

  Future<void> _submit({bool forced = false}) async {
    if (_busy || widget.questions.isEmpty) {
      return;
    }
    final Set<String> submitted = _answers[_question.id] ?? <String>{};
    final bool hasAnswer = submitted.any((String value) => value.trim().isNotEmpty);
    if (!forced && !hasAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose or enter an answer, or use Skip.')),
      );
      return;
    }

    setState(() => _busy = true);
    _timer?.cancel();
    _evaluations.add(widget.controller.quizEngine.evaluate(_question, submitted));

    if (_index < widget.questions.length - 1) {
      setState(() {
        _index += 1;
        _busy = false;
        _shortAnswerController.text =
            (_answers[_question.id] ?? <String>{}).firstOrNull ?? '';
      });
      _resetTimer();
      return;
    }

    final QuizResult result = widget.controller.quizEngine.finish(
      startedAt: _startedAt,
      completedAt: DateTime.now(),
      evaluations: _evaluations,
    );
    try {
      await widget.controller.recordResult(result);
    } on Object catch (error) {
      widget.controller.logger.error(
        'quiz.result.persist.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The quiz is complete, but its result could not be saved locally.',
            ),
          ),
        );
      }
    }
    if (!mounted) {
      return;
    }
    _allowPop = true;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ReviewPage(
          controller: widget.controller,
          questions: widget.questions,
          result: result,
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final bool confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Leave this quiz?'),
              content: const Text(
                'Your current in-progress answers will not be saved as a completed quiz.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Keep playing'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Leave quiz'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }
    _timer?.cancel();
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  void _resetTimer() {
    _timer?.cancel();
    if (!widget.config.timed || widget.questions.isEmpty) {
      _secondsRemaining = 0;
      return;
    }
    _secondsRemaining =
        _question.timeLimitSeconds ?? widget.config.defaultSecondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
        unawaited(_submit(forced: true));
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  static String _screenReaderHint(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Choose one answer.';
      case QuestionType.trueFalse:
        return 'Choose true or false.';
      case QuestionType.multiSelect:
        return 'Choose every answer that applies.';
      case QuestionType.shortAnswer:
        return 'Enter a short text answer.';
    }
  }

  static String _typeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple choice';
      case QuestionType.trueFalse:
        return 'True / false';
      case QuestionType.multiSelect:
        return 'Multi-select';
      case QuestionType.shortAnswer:
        return 'Short answer';
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
