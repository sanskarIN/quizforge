import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../application/quizforge_controller.dart';
import '../core/theme/app_theme.dart';
import '../data/question_bank_codec.dart';

final class ImportExportPage extends StatefulWidget {
  const ImportExportPage({required this.controller, super.key});

  final QuizForgeController controller;

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

enum _BankFormat { json, csv }

final class _ImportExportPageState extends State<ImportExportPage> {
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _backupController = TextEditingController();
  _BankFormat _format = _BankFormat.json;
  bool _importing = false;
  bool _restoringBackup = false;
  QuestionBankImportResult? _lastResult;

  @override
  void dispose() {
    _importController.dispose();
    _backupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String formatLabel = _format == _BankFormat.json
        ? strings.json
        : strings.csv;
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
            Text(
              strings.exportLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                onPressed: () {
                  unawaited(_copyExport(exportText));
                },
                icon: const Icon(Icons.copy_all_outlined),
                label: Text(strings.copyExport),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              strings.importLabel,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
                  onPressed: () {
                    unawaited(_pasteInto(_importController));
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
            const SizedBox(height: AppSpacing.xxl),
            const Divider(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              strings.localBackup,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.localBackupDescription),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () {
                  unawaited(_copyLocalBackup());
                },
                icon: const Icon(Icons.backup_outlined),
                label: Text(strings.copyLocalBackup),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              strings.restoreLocalBackup,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(strings.restoreLocalBackupDescription),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _backupController,
              minLines: 6,
              maxLines: 14,
              decoration: InputDecoration(
                labelText: strings.pasteLocalBackup,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () {
                    unawaited(_pasteInto(_backupController));
                  },
                  icon: const Icon(Icons.content_paste),
                  label: Text(strings.paste),
                ),
                FilledButton.icon(
                  onPressed: _restoringBackup
                      ? null
                      : () {
                          unawaited(_restoreLocalBackup());
                        },
                  icon: const Icon(Icons.restore),
                  label: Text(
                    _restoringBackup
                        ? strings.restoringBackup
                        : strings.restoreBackup,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyExport(String exportText) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: exportText));
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.exportCopied)));
    } on Object catch (error) {
      widget.controller.logger.warning(
        'question.export.clipboard_write.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.actionFailed)));
      }
    }
  }

  Future<void> _pasteInto(TextEditingController controller) async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || data?.text == null) {
        return;
      }
      controller.text = data!.text!;
    } on Object catch (error) {
      widget.controller.logger.warning(
        'clipboard.read.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.actionFailed)));
      }
    }
  }

  Future<void> _import() async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String source = _importController.text.trim();
    if (source.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.pasteQuestionBankFirst)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.importSaveFailed)));
      }
    } finally {
      if (mounted) {
        setState(() => _importing = false);
      }
    }
  }

  Future<void> _copyLocalBackup() async {
    final AppLocalizations strings = AppLocalizations.of(context);
    try {
      final String archive = await widget.controller.exportLocalBackup();
      await Clipboard.setData(ClipboardData(text: archive));
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.localBackupCopied)));
      }
    } on Object catch (error) {
      widget.controller.logger.error(
        'backup.export.ui_failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(strings.actionFailed)));
      }
    }
  }

  Future<void> _restoreLocalBackup() async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final String source = _backupController.text.trim();
    if (source.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.pasteLocalBackup)));
      return;
    }
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            final AppLocalizations dialogStrings = AppLocalizations.of(
              dialogContext,
            );
            return AlertDialog(
              title: Text(dialogStrings.restoreBackupTitle),
              content: Text(dialogStrings.restoreBackupConfirmation),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(dialogStrings.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(dialogStrings.restoreBackup),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _restoringBackup = true);
    try {
      await widget.controller.restoreLocalBackup(source);
      if (mounted) {
        _backupController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupRestoreSuccess),
          ),
        );
      }
    } on Object catch (error) {
      widget.controller.logger.error(
        'backup.restore.ui_failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupRestoreFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _restoringBackup = false);
      }
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
            Text(
              strings.importReport,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                Text(strings.moreErrors(result.errors.length - 10)),
            ],
          ],
        ),
      ),
    );
  }
}
