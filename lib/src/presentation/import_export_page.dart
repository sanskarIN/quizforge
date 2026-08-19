import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
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
    final AppLocalizations strings = AppLocalizations.of(context);
    final String formatLabel = _formatLabel(strings, _format);
    final String exportText = _format == _BankFormat.json
        ? widget.controller.exportJson()
        : widget.controller.exportCsv();
    return Scaffold(
      appBar: AppBar(title: Text(strings.importExport)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            SegmentedButton<_BankFormat>(
              segments: <ButtonSegment<_BankFormat>>[
                ButtonSegment<_BankFormat>(
                  value: _BankFormat.json,
                  icon: const Icon(Icons.data_object),
                  label: Text(strings.json),
                ),
                ButtonSegment<_BankFormat>(
                  value: _BankFormat.csv,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(strings.csv),
                ),
              ],
              selected: <_BankFormat>{_format},
              onSelectionChanged: (Set<_BankFormat> value) {
                setState(() => _format = value.single);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(strings.export, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.exportDescription),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: strings.exportPreviewSemantics(formatLabel),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 280),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    exportText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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
                    SnackBar(content: Text(strings.exportCopied)),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
                label: Text(strings.copyExport),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(strings.import, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.importDescription),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _importController,
              minLines: 8,
              maxLines: 16,
              decoration: InputDecoration(
                labelText: strings.pasteFormatData(formatLabel),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
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
                  label: Text(strings.paste),
                ),
                FilledButton.icon(
                  onPressed: _importing
                      ? null
                      : () {
                          unawaited(_import());
                        },
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(
                    _importing ? strings.importing : strings.validateAndImport,
                  ),
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
    final AppLocalizations strings = AppLocalizations.of(context);
    final String source = _importController.text.trim();
    if (source.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.pasteQuestionBankFirst)),
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
    } on Object catch (error) {
      widget.controller.logger.error(
        'question.import.persist.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.importSaveFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  static String _formatLabel(AppLocalizations strings, _BankFormat format) {
    switch (format) {
      case _BankFormat.json:
        return strings.json;
      case _BankFormat.csv:
        return strings.csv;
    }
  }
}

final class _ImportSummary extends StatelessWidget {
  const _ImportSummary({required this.result});

  final QuestionBankImportResult result;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(strings.importReport, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.importedCount(result.questions.length)),
            Text(strings.duplicatesSkippedCount(result.duplicates.length)),
            Text(strings.errorsCount(result.errors.length)),
            if (result.errors.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              for (final String error in result.errors.take(10))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text('• $error'),
                ),
              if (result.errors.length > 10)
                Text(strings.moreErrorsCount(result.errors.length - 10)),
            ],
          ],
        ),
      ),
    );
  }
}
