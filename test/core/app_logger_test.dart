import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/core/logging/app_logger.dart';

void main() {
  test('redacts sensitive fields and preserves safe metadata', () {
    final List<String> messages = <String>[];
    final AppLogger logger = AppLogger(sink: messages.add);

    logger.info(
      'quiz.completed',
      fields: <String, Object?>{
        'questionCount': 10,
        'profileName': 'Private Player',
        'email': 'private@example.test',
        'mode': 'daily',
      },
    );

    expect(messages, hasLength(1));
    final Map<String, Object?> payload =
        (jsonDecode(messages.single) as Map<Object?, Object?>)
            .cast<String, Object?>();
    final Map<String, Object?> fields =
        (payload['fields'] as Map<Object?, Object?>).cast<String, Object?>();

    expect(payload['event'], 'quiz.completed');
    expect(fields['questionCount'], 10);
    expect(fields['mode'], 'daily');
    expect(fields['profileName'], '[REDACTED]');
    expect(fields['email'], '[REDACTED]');
  });

  test('redacts long or multiline strings even with a safe key', () {
    final List<String> messages = <String>[];
    final AppLogger logger = AppLogger(sink: messages.add);

    logger.warning(
      'import.rejected',
      fields: <String, Object?>{
        'reason': 'x' * 100,
        'details': 'line one\nline two',
      },
    );

    final Map<String, Object?> payload =
        (jsonDecode(messages.single) as Map<Object?, Object?>)
            .cast<String, Object?>();
    final Map<String, Object?> fields =
        (payload['fields'] as Map<Object?, Object?>).cast<String, Object?>();
    expect(fields['reason'], '[REDACTED]');
    expect(fields['details'], '[REDACTED]');
  });

  test('filters events below minimum level', () {
    final List<String> messages = <String>[];
    final AppLogger logger = AppLogger(
      sink: messages.add,
      minimumLevel: LogLevel.warning,
    );

    logger.info('app.ready');
    logger.warning('app.warning');

    expect(messages, hasLength(1));
  });
}
