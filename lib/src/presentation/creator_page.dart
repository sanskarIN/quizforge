import 'dart:async';

import 'package:flutter/material.dart';

import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../domain/question.dart';

final class CreatorPage extends StatefulWidget {
  const CreatorPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

final class _CreatorPageState extends State<CreatorPage> {
  final TextEditingController _prompt = TextEditingController();
  final TextEditingController _category = TextEditingController();
  final TextEditingController _choices = TextEditingController();
  final TextEditingController _answers = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _explanation = TextEditingController();
  final TextEditingController _timeLimit = TextEditingController();

  QuestionType _type = QuestionType.multipleChoice;
  Difficulty _difficulty = Difficulty.easy;
  bool _saving = false;
  List<String> _validationErrors = const <String>[];

  @override
  void dispose() {
    _prompt.dispose();
    _category.dispose();
    _choices.dispose();
    _answers.dispose();
    _tags.dispose();
    _explanation.dispose();
    _timeLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Question preview = _buildQuestion();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text('Create a question', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          const Text('Build, validate, and preview questions before adding them to the local bank.'),
          const SizedBox(height: AppSpacing.xl),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool wide = constraints.maxWidth >= 900;
              final Widget form = _buildForm(context);
              final Widget previewPanel = _PreviewPanel(
                question: preview,
                errors: _validationErrors,
              );
              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: previewPanel),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  form,
                  const SizedBox(height: AppSpacing.lg),
                  previewPanel,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            DropdownMenu<QuestionType>(
              initialSelection: _type,
              label: const Text('Question type'),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: QuestionType.values
                  .map(
                    (QuestionType type) => DropdownMenuEntry<QuestionType>(
                      value: type,
                      label: _typeLabel(type),
                    ),
                  )
                  .toList(growable: false),
              onSelected: (QuestionType? value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _prompt,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Prompt'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownMenu<Difficulty>(
              initialSelection: _difficulty,
              label: const Text('Difficulty'),
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: Difficulty.values
                  .map(
                    (Difficulty value) => DropdownMenuEntry<Difficulty>(
                      value: value,
                      label: value.name,
                    ),
                  )
                  .toList(growable: false),
              onSelected: (Difficulty? value) {
                if (value != null) {
                  setState(() => _difficulty = value);
                }
              },
            ),
            if (_type == QuestionType.multipleChoice ||
                _type == QuestionType.multiSelect) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _choices,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Choices',
                  helperText: 'Enter one choice per line.',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _answers,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Correct answer${_type == QuestionType.multiSelect ? 's' : ''}',
                helperText: _type == QuestionType.trueFalse
                    ? 'Enter true or false.'
                    : 'Enter one accepted answer per line.',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags',
                helperText: 'Comma separated, for example: science, basics',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _explanation,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Explanation'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _timeLimit,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Optional time limit (seconds)',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () {
                      unawaited(_save());
                    },
              icon: const Icon(Icons.add),
              label: Text(_saving ? 'Adding…' : 'Add to question bank'),
            ),
          ],
        ),
      ),
    );
  }

  Question _buildQuestion() {
    return Question(
      id: _generatedId(),
      type: _type,
      prompt: _prompt.text.trim(),
      choices: _type == QuestionType.multipleChoice ||
              _type == QuestionType.multiSelect
          ? _lines(_choices.text)
          : const <String>[],
      correctAnswers: _lines(_answers.text).toSet(),
      category: _category.text.trim(),
      difficulty: _difficulty,
      tags: _tags.text
          .split(',')
          .map((String value) => value.trim())
          .where((String value) => value.isNotEmpty)
          .toList(growable: false),
      explanation: _explanation.text.trim(),
      timeLimitSeconds: int.tryParse(_timeLimit.text.trim()),
    );
  }

  Future<void> _save() async {
    final Question question = _buildQuestion();
    final List<String> errors = question.validate();
    setState(() => _validationErrors = errors);
    if (errors.isNotEmpty) {
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.controller.addQuestion(question);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question added to the local bank.')),
      );
      _clearForm();
    } on Object catch (error) {
      if (mounted) {
        setState(() => _validationErrors = <String>['$error']);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _clearForm() {
    _prompt.clear();
    _category.clear();
    _choices.clear();
    _answers.clear();
    _tags.clear();
    _explanation.clear();
    _timeLimit.clear();
    setState(() => _validationErrors = const <String>[]);
  }

  String _generatedId() {
    final String category = normalizeAnswer(_category.text)
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final String prefix = category.isEmpty ? 'question' : category;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }

  static List<String> _lines(String value) => value
      .split(RegExp(r'\r?\n'))
      .map((String item) => item.trim())
      .where((String item) => item.isNotEmpty)
      .toList(growable: false);

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

final class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.question,
    required this.errors,
  });

  final Question question;
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final List<String> currentErrors = question.validate();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Preview', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              question.prompt.isEmpty ? 'Your prompt will appear here.' : question.prompt,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            if (question.choices.isNotEmpty)
              ...question.choices.map(
                (String choice) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.circle_outlined, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(choice)),
                    ],
                  ),
                ),
              ),
            if (question.type == QuestionType.shortAnswer)
              const Text('Short-answer text field'),
            if (question.type == QuestionType.trueFalse)
              const Text('True / False choices'),
            const SizedBox(height: AppSpacing.md),
            if (errors.isNotEmpty || currentErrors.isNotEmpty) ...<Widget>[
              Text(
                'Validation',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final String error in errors.isNotEmpty ? errors : currentErrors)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.error_outline, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
            ] else
              const Row(
                children: <Widget>[
                  Icon(Icons.check_circle_outline, size: 18),
                  SizedBox(width: AppSpacing.sm),
                  Text('Ready to save'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
