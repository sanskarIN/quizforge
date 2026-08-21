import 'dart:convert';

import 'package:quizforge/src/data/question_bank_codec.dart';
import 'package:quizforge/src/domain/question.dart';
import 'package:quizforge/src/domain/quiz_config.dart';
import 'package:quizforge/src/domain/quiz_engine.dart';

void main(List<String> arguments) {
  final int size = _readSize(arguments);
  final List<Question> bank = _buildBank(size);
  const QuizEngine engine = QuizEngine();
  const QuestionBankCodec codec = QuestionBankCodec();

  _measure('select 50 questions', () {
    engine.selectQuestions(
      bank,
      const QuizConfig(questionCount: 50, seed: 20260819),
    );
  });

  late String jsonPayload;
  _measure('encode JSON', () {
    jsonPayload = codec.encodeJson(bank);
  });

  _measure('decode JSON', () {
    final result = codec.decodeJson(jsonPayload);
    if (result.questions.length != bank.length || result.errors.isNotEmpty) {
      throw StateError(
        'JSON benchmark round trip was not semantically complete.',
      );
    }
  });

  late String csvPayload;
  _measure('encode CSV', () {
    csvPayload = codec.encodeCsv(bank);
  });

  _measure('decode CSV', () {
    final result = codec.decodeCsv(csvPayload);
    if (result.questions.length != bank.length || result.errors.isNotEmpty) {
      throw StateError(
        'CSV benchmark round trip was not semantically complete.',
      );
    }
  });

  final Map<String, Object> summary = <String, Object>{
    'bankSize': bank.length,
    'jsonBytes': utf8.encode(jsonPayload).length,
    'csvBytes': utf8.encode(csvPayload).length,
  };
  print(jsonEncode(summary)); // ignore: avoid_print
}

int _readSize(List<String> arguments) {
  if (arguments.isEmpty) {
    return 10000;
  }
  final int? parsed = int.tryParse(arguments.first);
  if (parsed == null || parsed < 1 || parsed > 100000) {
    throw ArgumentError('Size must be an integer between 1 and 100000.');
  }
  return parsed;
}

List<Question> _buildBank(int count) {
  return List<Question>.generate(count, (int index) {
    final int group = index % 20;
    return Question(
      id: 'benchmark-$index',
      type: QuestionType.multipleChoice,
      prompt: 'Benchmark question $index in deterministic group $group?',
      choices: const <String>['Alpha', 'Beta', 'Gamma', 'Delta'],
      correctAnswers: const <String>{'Alpha'},
      category: 'Category ${index % 25}',
      difficulty: Difficulty.values[index % Difficulty.values.length],
      tags: <String>['benchmark', 'group-$group'],
      explanation: 'Fictional deterministic benchmark fixture $index.',
    );
  }, growable: false);
}

void _measure(String label, void Function() operation) {
  for (int warmup = 0; warmup < 3; warmup += 1) {
    operation();
  }

  final List<int> micros = <int>[];
  for (int run = 0; run < 7; run += 1) {
    final Stopwatch stopwatch = Stopwatch()..start();
    operation();
    stopwatch.stop();
    micros.add(stopwatch.elapsedMicroseconds);
  }
  micros.sort();
  final int median = micros[micros.length ~/ 2];
  print(
    jsonEncode(<String, Object>{
      'benchmark': label,
      'medianMicroseconds': median,
      'runsMicroseconds': micros,
    }),
  ); // ignore: avoid_print
}
