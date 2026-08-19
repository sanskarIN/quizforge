import 'dart:convert';

import '../domain/app_settings.dart';
import '../domain/profile.dart';
import '../domain/question.dart';
import '../domain/quiz_result.dart';
import 'app_database_backup.dart';

final class LocalBackupPayload {
  const LocalBackupPayload({
    required this.createdAt,
    required this.database,
    required this.settings,
    required this.activeProfileId,
  });

  final DateTime createdAt;
  final DatabaseBackupSnapshot database;
  final AppSettings settings;
  final String? activeProfileId;
}

final class LocalBackupCodec {
  const LocalBackupCodec();

  static const String format = 'quizforge-local-backup';
  static const int formatVersion = 1;
  static const int maxSourceCharacters = 10 * 1024 * 1024;

  String encode(LocalBackupPayload payload) {
    final List<String> errors = payload.database.validate();
    if (errors.isNotEmpty) {
      throw StateError('Cannot encode invalid backup state: ${errors.first}');
    }
    final Set<String> profileIds = payload.database.profiles
        .map((PlayerProfile profile) => profile.id)
        .toSet();
    final String? activeProfileId = payload.activeProfileId;
    if (activeProfileId != null && !profileIds.contains(activeProfileId)) {
      throw StateError('Active profile is not present in the backup database.');
    }

    final Map<String, Object?> document = <String, Object?>{
      'format': format,
      'version': formatVersion,
      'createdAt': payload.createdAt.toUtc().toIso8601String(),
      'settings': _encodeSettings(payload.settings),
      'activeProfileId': activeProfileId,
      'database': <String, Object?>{
        'questions': payload.database.questions.map(_encodeQuestion).toList(),
        'profiles': payload.database.profiles.map(_encodeProfile).toList(),
        'attempts': payload.database.attempts.map(_encodeAttempt).toList(),
        'bookmarks': payload.database.bookmarks.map(_encodeBookmark).toList(),
      },
    };
    return const JsonEncoder.withIndent('  ').convert(document);
  }

  LocalBackupPayload decode(String source) {
    if (source.length > maxSourceCharacters) {
      throw const FormatException('Backup archive is larger than the supported limit.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      rethrow;
    }
    final Map<String, Object?> root = _expectMap(decoded, 'backup archive');
    if (_expectString(root['format'], 'format') != format) {
      throw const FormatException('Unsupported backup archive format.');
    }
    final int version = _expectInt(root['version'], 'version');
    if (version != formatVersion) {
      throw FormatException('Unsupported backup archive version: $version.');
    }
    final DateTime createdAt = _expectDateTime(root['createdAt'], 'createdAt');
    final AppSettings settings = _decodeSettings(root['settings']);
    final String? activeProfileId = _optionalString(
      root['activeProfileId'],
      'activeProfileId',
    );
    final Map<String, Object?> databaseMap =
        _expectMap(root['database'], 'database');
    final DatabaseBackupSnapshot database = DatabaseBackupSnapshot(
      questions: _expectList(databaseMap['questions'], 'database.questions')
          .map(_decodeQuestion)
          .toList(growable: false),
      profiles: _expectList(databaseMap['profiles'], 'database.profiles')
          .map(_decodeProfile)
          .toList(growable: false),
      attempts: _expectList(databaseMap['attempts'], 'database.attempts')
          .map(_decodeAttempt)
          .toList(growable: false),
      bookmarks: _expectList(databaseMap['bookmarks'], 'database.bookmarks')
          .map(_decodeBookmark)
          .toList(growable: false),
    );
    final List<String> errors = database.validate();
    if (errors.isNotEmpty) {
      throw FormatException(errors.first);
    }
    if (activeProfileId != null &&
        !database.profiles.any(
          (PlayerProfile profile) => profile.id == activeProfileId,
        )) {
      throw const FormatException(
        'Backup active profile is not present in the profile list.',
      );
    }
    return LocalBackupPayload(
      createdAt: createdAt,
      database: database,
      settings: settings,
      activeProfileId: activeProfileId,
    );
  }

  static Map<String, Object?> _encodeSettings(AppSettings settings) =>
      <String, Object?>{
        'themeMode': settings.themeMode.name,
        'largeText': settings.largeText,
        'reducedMotion': settings.reducedMotion,
        'screenReaderHints': settings.screenReaderHints,
        'confirmBeforeExitQuiz': settings.confirmBeforeExitQuiz,
      };

  static AppSettings _decodeSettings(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'settings');
    final String themeName = _expectString(map['themeMode'], 'settings.themeMode');
    final AppThemeMode themeMode;
    try {
      themeMode = AppThemeMode.values.byName(themeName);
    } on ArgumentError {
      throw FormatException('Unknown theme mode: $themeName.');
    }
    return AppSettings(
      themeMode: themeMode,
      largeText: _expectBool(map['largeText'], 'settings.largeText'),
      reducedMotion: _expectBool(map['reducedMotion'], 'settings.reducedMotion'),
      screenReaderHints:
          _expectBool(map['screenReaderHints'], 'settings.screenReaderHints'),
      confirmBeforeExitQuiz: _expectBool(
        map['confirmBeforeExitQuiz'],
        'settings.confirmBeforeExitQuiz',
      ),
    );
  }

  static Map<String, Object?> _encodeQuestion(Question question) =>
      <String, Object?>{
        'id': question.id,
        'type': question.type.name,
        'prompt': question.prompt,
        'choices': question.choices,
        'correctAnswers': question.correctAnswers.toList()..sort(),
        'category': question.category,
        'difficulty': question.difficulty.name,
        'tags': question.tags,
        'explanation': question.explanation,
        'timeLimitSeconds': question.timeLimitSeconds,
      };

  static Question _decodeQuestion(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'question');
    final String typeName = _expectString(map['type'], 'question.type');
    final String difficultyName =
        _expectString(map['difficulty'], 'question.difficulty');
    final QuestionType type;
    final Difficulty difficulty;
    try {
      type = QuestionType.values.byName(typeName);
    } on ArgumentError {
      throw FormatException('Unknown question type: $typeName.');
    }
    try {
      difficulty = Difficulty.values.byName(difficultyName);
    } on ArgumentError {
      throw FormatException('Unknown question difficulty: $difficultyName.');
    }
    return Question(
      id: _expectString(map['id'], 'question.id'),
      type: type,
      prompt: _expectString(map['prompt'], 'question.prompt'),
      choices: _expectStringList(map['choices'], 'question.choices'),
      correctAnswers: _expectStringList(
        map['correctAnswers'],
        'question.correctAnswers',
      ).toSet(),
      category: _expectString(map['category'], 'question.category'),
      difficulty: difficulty,
      tags: _expectStringList(map['tags'], 'question.tags'),
      explanation: _expectString(map['explanation'], 'question.explanation'),
      timeLimitSeconds: _optionalInt(
        map['timeLimitSeconds'],
        'question.timeLimitSeconds',
      ),
    );
  }

  static Map<String, Object?> _encodeProfile(PlayerProfile profile) =>
      <String, Object?>{
        'id': profile.id,
        'displayName': profile.displayName,
        'createdAt': profile.createdAt?.toUtc().toIso8601String(),
      };

  static PlayerProfile _decodeProfile(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'profile');
    return PlayerProfile(
      id: _expectString(map['id'], 'profile.id'),
      displayName: _expectString(map['displayName'], 'profile.displayName'),
      createdAt: _optionalDateTime(map['createdAt'], 'profile.createdAt'),
    );
  }

  static Map<String, Object?> _encodeAttempt(BackupAttempt attempt) =>
      <String, Object?>{
        'profileId': attempt.profileId,
        'startedAt': attempt.startedAt.toUtc().toIso8601String(),
        'completedAt': attempt.completedAt.toUtc().toIso8601String(),
        'correctCount': attempt.correctCount,
        'questionCount': attempt.questionCount,
        'bestStreak': attempt.bestStreak,
        'earnedScore': attempt.earnedScore,
        'evaluations': attempt.evaluations.map(_encodeEvaluation).toList(),
      };

  static BackupAttempt _decodeAttempt(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'attempt');
    return BackupAttempt(
      profileId: _expectString(map['profileId'], 'attempt.profileId'),
      startedAt: _expectDateTime(map['startedAt'], 'attempt.startedAt'),
      completedAt: _expectDateTime(map['completedAt'], 'attempt.completedAt'),
      correctCount: _expectInt(map['correctCount'], 'attempt.correctCount'),
      questionCount: _expectInt(map['questionCount'], 'attempt.questionCount'),
      bestStreak: _expectInt(map['bestStreak'], 'attempt.bestStreak'),
      earnedScore: _expectDouble(map['earnedScore'], 'attempt.earnedScore'),
      evaluations: _expectList(map['evaluations'], 'attempt.evaluations')
          .map(_decodeEvaluation)
          .toList(growable: false),
    );
  }

  static Map<String, Object?> _encodeEvaluation(QuestionEvaluation evaluation) =>
      <String, Object?>{
        'questionId': evaluation.questionId,
        'submittedAnswers': evaluation.submittedAnswers.toList()..sort(),
        'correct': evaluation.correct,
        'score': evaluation.score,
      };

  static QuestionEvaluation _decodeEvaluation(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'evaluation');
    return QuestionEvaluation(
      questionId: _expectString(map['questionId'], 'evaluation.questionId'),
      submittedAnswers: _expectStringList(
        map['submittedAnswers'],
        'evaluation.submittedAnswers',
      ).toSet(),
      correct: _expectBool(map['correct'], 'evaluation.correct'),
      score: _expectDouble(map['score'], 'evaluation.score'),
    );
  }

  static Map<String, Object?> _encodeBookmark(BackupBookmark bookmark) =>
      <String, Object?>{
        'profileId': bookmark.profileId,
        'questionId': bookmark.questionId,
      };

  static BackupBookmark _decodeBookmark(Object? value) {
    final Map<String, Object?> map = _expectMap(value, 'bookmark');
    return BackupBookmark(
      profileId: _expectString(map['profileId'], 'bookmark.profileId'),
      questionId: _expectString(map['questionId'], 'bookmark.questionId'),
    );
  }

  static Map<String, Object?> _expectMap(Object? value, String field) {
    if (value is! Map<String, Object?>) {
      throw FormatException('$field must be an object.');
    }
    return value;
  }

  static List<Object?> _expectList(Object? value, String field) {
    if (value is! List<Object?>) {
      throw FormatException('$field must be a list.');
    }
    return value;
  }

  static List<String> _expectStringList(Object? value, String field) {
    final List<Object?> list = _expectList(value, field);
    if (list.any((Object? item) => item is! String)) {
      throw FormatException('$field must contain only strings.');
    }
    return list.cast<String>().toList(growable: false);
  }

  static String _expectString(Object? value, String field) {
    if (value is! String) {
      throw FormatException('$field must be a string.');
    }
    return value;
  }

  static String? _optionalString(Object? value, String field) {
    if (value == null) {
      return null;
    }
    return _expectString(value, field);
  }

  static bool _expectBool(Object? value, String field) {
    if (value is! bool) {
      throw FormatException('$field must be a boolean.');
    }
    return value;
  }

  static int _expectInt(Object? value, String field) {
    if (value is! int) {
      throw FormatException('$field must be an integer.');
    }
    return value;
  }

  static int? _optionalInt(Object? value, String field) {
    if (value == null) {
      return null;
    }
    return _expectInt(value, field);
  }

  static double _expectDouble(Object? value, String field) {
    if (value is! num) {
      throw FormatException('$field must be a number.');
    }
    final double result = value.toDouble();
    if (!result.isFinite) {
      throw FormatException('$field must be finite.');
    }
    return result;
  }

  static DateTime _expectDateTime(Object? value, String field) {
    final String encoded = _expectString(value, field);
    final DateTime? parsed = DateTime.tryParse(encoded);
    if (parsed == null) {
      throw FormatException('$field must be an ISO-8601 timestamp.');
    }
    return parsed;
  }

  static DateTime? _optionalDateTime(Object? value, String field) {
    if (value == null) {
      return null;
    }
    return _expectDateTime(value, field);
  }
}
