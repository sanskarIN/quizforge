import 'dart:convert';

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

final class AppLogger {
  AppLogger({
    void Function(String message)? sink,
    this.minimumLevel = LogLevel.info,
  }) : _sink = sink ?? debugPrint;

  final void Function(String message) _sink;
  final LogLevel minimumLevel;

  void debug(
    String event, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    _write(LogLevel.debug, event, fields);
  }

  void info(
    String event, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    _write(LogLevel.info, event, fields);
  }

  void warning(
    String event, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    _write(LogLevel.warning, event, fields);
  }

  void error(
    String event, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    _write(LogLevel.error, event, fields);
  }

  void _write(LogLevel level, String event, Map<String, Object?> fields) {
    if (level.index < minimumLevel.index) {
      return;
    }
    final Map<String, Object?> payload = <String, Object?>{
      'level': level.name,
      'event': _safeEvent(event),
      'fields': _redactMap(fields),
    };
    _sink(jsonEncode(payload));
  }

  static String _safeEvent(String value) {
    final String normalized = value.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_.-]{1,80}$').hasMatch(normalized)) {
      return 'invalid_event_name';
    }
    return normalized;
  }

  static Map<String, Object?> _redactMap(Map<String, Object?> source) {
    return source.map<String, Object?>((String key, Object? value) {
      if (_sensitiveKey(key)) {
        return MapEntry<String, Object?>(key, '[REDACTED]');
      }
      return MapEntry<String, Object?>(key, _sanitizeValue(value));
    });
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null || value is num || value is bool) {
      return value;
    }
    if (value is String) {
      // Structured logs should carry small machine-oriented labels, not raw
      // question/profile/import content. Long strings are therefore redacted.
      if (value.length > 80 || value.contains('\n') || value.contains('\r')) {
        return '[REDACTED]';
      }
      return value;
    }
    if (value is Iterable<Object?>) {
      return value
          .take(20)
          .map<Object?>(_sanitizeValue)
          .toList(growable: false);
    }
    if (value is Map<String, Object?>) {
      return _redactMap(value);
    }
    return value.runtimeType.toString();
  }

  static bool _sensitiveKey(String key) {
    final String normalized = key.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
    const List<String> fragments = <String>[
      'password',
      'passwd',
      'token',
      'secret',
      'authorization',
      'authheader',
      'apikey',
      'credential',
      'cookie',
      'email',
      'prompt',
      'answer',
      'content',
      'displayname',
      'profilename',
      'importdata',
      'exportdata',
    ];
    return fragments.any(normalized.contains);
  }
}
