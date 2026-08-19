import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/question_bank_codec.dart';

final class ImportExportPage extends StatefulWidget {
  const ImportExportPage({
    required this.controller,
    super.key,
  });

  final QuizForgeController controller;

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

enum _BankFormat { json, csv }

final class _ImportExportPageState extends State<ImportExportPage> {
  final TextEditingController _importController = TextEditingController();
  _BankFormat _format = _BankFormat.json;
  bool _importing = false;
  QuestionBankImportResult? _lastResult;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String exportText = _format == _BankFormat.json
        ? widget.controller.exportJson()
        : widget.controller.exportCsv();
    return Scaffold(
      appBar: AppBar(title: const Text('Import / export')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SegmentedButton<_BankFormat>(
              segments: const <ButtonSegment<_BankFormat>>[
                ButtonSegment<_BankFormat>(
                  value: _BankFormat.json,
                  icon: Icon(Icons.data_object),
                  label: Text('JSON'),
                ),
                ButtonSegment<_BankFormat>(
                  value: _BankFormat.csv,
                  icon: Icon(Icons.table_chart_outlined),
                  label: Text('CSV'),
                ),
              ],
              selected: <_BankFormat>{_format},
              onSelectionChanged: (Set<_BankFormat> value) {
                setState(() => _format = value.single);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Export', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'The preview contains your complete local question bank. Copy it and save it with the matching file extension.',
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: TextField(
                controller: TextEditingController(text: exportText),
                readOnly: true,
                maxLines: null,
                minLines: 6,
                decoration: const InputDecoration(labelText: 'Export preview'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: exportText));
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question bank copied to clipboard.')),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy export'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Import', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Paste a QuizForge JSON or CSV question bank. Invalid rows are rejected and duplicate ids/content are skipped.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _importController,
              minLines: 8,
              maxLines: 16,
              decoration: InputDecoration(
                labelText: 'Paste ${_format.name.toUpperCase()} data',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () async {
                    final ClipboardData? data =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _importController.text = data!.text!;
                    }
                  },
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Paste'),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: _importing
                      ? null
                      : () {
                          unawaited(_import());
                        },
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(_importing ? 'Importing…' : 'Validate and import'),
                ),
              ],
            ),
            if (_lastResult != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              _ImportSummary(result: _lastResult!),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _import() async {
    final String source = _importController.text.trim();
    if (source.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste question-bank data first.')),
      );
      return;
    }
    setState(() => _importing = true);
    try {
      final QuestionBankImportResult result = _format == _BankFormat.json
          ? await widget.controller.importJson(source)
          : await widget.controller.importCsv(source);
      if (mounted) {
        setState(() => _lastResult = result);
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }
}

final class _ImportSummary extends StatelessWidget {
  const _ImportSummary({required this.result});

  final QuestionBankImportResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Import report', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text('Imported: ${result.questions.length}'),
            Text('Duplicates skipped: ${result.duplicates.length}'),
            Text('Errors: ${result.errors.length}'),
            if (result.errors.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              for (final String error in result.errors.take(10))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $error'),
                ),
              if (result.errors.length > 10)
                Text('…and ${result.errors.length - 10} more errors.'),
            ],
          ],
        ),
      ),
    );
  }
}
