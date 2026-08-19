import 'dart:convert';

import '../domain/question.dart';
import '../domain/question_deduplicator.dart';

final class QuestionBankImportResult {
  const QuestionBankImportResult({
    required this.questions,
    required this.duplicates,
    required this.errors,
  });

  final List<Question> questions;
  final List<Question> duplicates;
  final List<String> errors;

  bool get isSuccess => errors.isEmpty;
}

final class QuestionBankCodec {
  const QuestionBankCodec({
    this.deduplicator = const QuestionDeduplicator(),
  });

  final QuestionDeduplicator deduplicator;

  String encodeJson(Iterable<Question> questions) {
    final Map<String, Object?> payload = <String, Object?>{
      'format': 'quizforge-question-bank',
      'version': 1,
      'questions': questions.map((Question item) => item.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  QuestionBankImportResult decodeJson(
    String source, {
    Iterable<Question> existing = const <Question>[],
  }) {
    try {
      final Object? decoded = jsonDecode(source);
      if (decoded is! Map<String, Object?>) {
        return _error('JSON root must be an object.');
      }
      final Object? rawQuestions = decoded['questions'];
      if (rawQuestions is! List<Object?>) {
        return _error('JSON field "questions" must be an array.');
      }
      final List<Question> parsed = <Question>[];
      final List<String> errors = <String>[];
      for (int index = 0; index < rawQuestions.length; index += 1) {
        final Object? rawQuestion = rawQuestions[index];
        if (rawQuestion is! Map<String, Object?>) {
          errors.add('Question ${index + 1}: expected an object.');
          continue;
        }
        try {
          final Question question = Question.fromJson(rawQuestion);
          final List<String> validation = question.validate();
          if (validation.isNotEmpty) {
            errors.add('Question ${index + 1}: ${validation.join(' ')}');
          } else {
            parsed.add(question);
          }
        } on Object catch (error) {
          errors.add('Question ${index + 1}: $error');
        }
      }
      final DuplicateReport report =
          deduplicator.partition(parsed, existing: existing);
      return QuestionBankImportResult(
        questions: report.unique,
        duplicates: report.duplicates,
        errors: List<String>.unmodifiable(errors),
      );
    } on FormatException catch (error) {
      return _error('Invalid JSON: ${error.message}');
    }
  }

  String encodeCsv(Iterable<Question> questions) {
    const List<String> headers = <String>[
      'id',
      'type',
      'prompt',
      'choices',
      'correctAnswers',
      'category',
      'difficulty',
      'tags',
      'explanation',
      'timeLimitSeconds',
    ];
    final StringBuffer buffer = StringBuffer()..writeln(headers.join(','));
    for (final Question question in questions) {
      final List<String> cells = <String>[
        question.id,
        question.type.name,
        question.prompt,
        jsonEncode(question.choices),
        jsonEncode(question.correctAnswers.toList()..sort()),
        question.category,
        question.difficulty.name,
        jsonEncode(question.tags),
        question.explanation,
        question.timeLimitSeconds?.toString() ?? '',
      ];
      buffer.writeln(cells.map(_escapeCsvCell).join(','));
    }
    return buffer.toString();
  }

  QuestionBankImportResult decodeCsv(
    String source, {
    Iterable<Question> existing = const <Question>[],
  }) {
    final List<List<String>> rows;
    try {
      rows = _parseCsv(source);
    } on FormatException catch (error) {
      return _error('Invalid CSV: ${error.message}');
    }
    if (rows.isEmpty) {
      return _error('CSV is empty.');
    }

    const List<String> expectedHeaders = <String>[
      'id',
      'type',
      'prompt',
      'choices',
      'correctAnswers',
      'category',
      'difficulty',
      'tags',
      'explanation',
      'timeLimitSeconds',
    ];
    if (rows.first.length != expectedHeaders.length ||
        !_sameList(rows.first, expectedHeaders)) {
      return _error('CSV header does not match the QuizForge format.');
    }

    final List<Question> parsed = <Question>[];
    final List<String> errors = <String>[];
    for (int index = 1; index < rows.length; index += 1) {
      final List<String> row = rows[index];
      if (row.every((String cell) => cell.trim().isEmpty)) {
        continue;
      }
      if (row.length != expectedHeaders.length) {
        errors.add('Row ${index + 1}: expected ${expectedHeaders.length} columns.');
        continue;
      }
      try {
        final Question question = Question(
          id: row[0],
          type: QuestionType.values.byName(row[1]),
          prompt: row[2],
          choices: _jsonStringList(row[3]),
          correctAnswers: _jsonStringList(row[4]).toSet(),
          category: row[5],
          difficulty: Difficulty.values.byName(row[6]),
          tags: _jsonStringList(row[7]),
          explanation: row[8],
          timeLimitSeconds:
              row[9].trim().isEmpty ? null : int.parse(row[9].trim()),
        );
        final List<String> validation = question.validate();
        if (validation.isNotEmpty) {
          errors.add('Row ${index + 1}: ${validation.join(' ')}');
        } else {
          parsed.add(question);
        }
      } on Object catch (error) {
        errors.add('Row ${index + 1}: $error');
      }
    }

    final DuplicateReport report =
        deduplicator.partition(parsed, existing: existing);
    return QuestionBankImportResult(
      questions: report.unique,
      duplicates: report.duplicates,
      errors: List<String>.unmodifiable(errors),
    );
  }

  static QuestionBankImportResult _error(String message) =>
      QuestionBankImportResult(
        questions: const <Question>[],
        duplicates: const <Question>[],
        errors: <String>[message],
      );

  static List<String> _jsonStringList(String value) {
    final Object? decoded = jsonDecode(value);
    if (decoded is! List<Object?>) {
      throw const FormatException('Expected a JSON string array.');
    }
    return decoded.map((Object? item) {
      if (item is! String) {
        throw const FormatException('Expected a JSON string array.');
      }
      return item;
    }).toList(growable: false);
  }

  static String _escapeCsvCell(String value) {
    final bool needsQuotes = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuotes) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  static bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }
    for (int index = 0; index < left.length; index += 1) {
      if (left[index].trim() != right[index]) {
        return false;
      }
    }
    return true;
  }

  static List<List<String>> _parseCsv(String source) {
    final List<List<String>> rows = <List<String>>[];
    List<String> row = <String>[];
    final StringBuffer cell = StringBuffer();
    bool quoted = false;

    for (int index = 0; index < source.length; index += 1) {
      final String character = source[index];
      if (character == '"') {
        if (quoted && index + 1 < source.length && source[index + 1] == '"') {
          cell.write('"');
          index += 1;
        } else {
          quoted = !quoted;
        }
      } else if (character == ',' && !quoted) {
        row.add(cell.toString());
        cell.clear();
      } else if ((character == '\n' || character == '\r') && !quoted) {
        if (character == '\r' &&
            index + 1 < source.length &&
            source[index + 1] == '\n') {
          index += 1;
        }
        row.add(cell.toString());
        cell.clear();
        rows.add(row);
        row = <String>[];
      } else {
        cell.write(character);
      }
    }

    if (quoted) {
      throw const FormatException('Unclosed quoted field.');
    }
    if (cell.isNotEmpty || row.isNotEmpty) {
      row.add(cell.toString());
      rows.add(row);
    }
    return rows;
  }
}
