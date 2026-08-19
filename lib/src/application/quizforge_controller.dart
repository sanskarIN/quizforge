import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/logging/app_logger.dart';
import '../data/app_database.dart';
import '../data/profile_preferences.dart';
import '../data/question_bank_codec.dart';
import '../data/question_repository.dart';
import '../data/settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/profile.dart';
import '../domain/question.dart';
import '../domain/question_deduplicator.dart';
import '../domain/quiz_engine.dart';
import '../domain/quiz_result.dart';

final class QuizForgeController extends ChangeNotifier {
  QuizForgeController({
    required this.database,
    required this.questionRepository,
    required this.settingsRepository,
    required this.profilePreferences,
    AppLogger? logger,
    this.quizEngine = const QuizEngine(),
    this.codec = const QuestionBankCodec(),
    this.deduplicator = const QuestionDeduplicator(),
  }) : logger = logger ?? AppLogger();

  final AppDatabase database;
  final QuestionRepository questionRepository;
  final SettingsRepository settingsRepository;
  final ProfilePreferences profilePreferences;
  final AppLogger logger;
  final QuizEngine quizEngine;
  final QuestionBankCodec codec;
  final QuestionDeduplicator deduplicator;

  bool _loading = true;
  String? _errorMessage;
  List<Question> _questions = const <Question>[];
  List<PlayerProfile> _profiles = const <PlayerProfile>[];
  List<LeaderboardEntry> _leaderboard = const <LeaderboardEntry>[];
  PlayerProfile? _activeProfile;
  Set<String> _bookmarkIds = const <String>{};
  ProgressSummary _progress = const ProgressSummary();
  AppSettings _settings = const AppSettings();

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<Question> get questions => List<Question>.unmodifiable(_questions);
  List<PlayerProfile> get profiles => List<PlayerProfile>.unmodifiable(_profiles);
  List<LeaderboardEntry> get leaderboard =>
      List<LeaderboardEntry>.unmodifiable(_leaderboard);
  PlayerProfile? get activeProfile => _activeProfile;
  Set<String> get bookmarkIds => Set<String>.unmodifiable(_bookmarkIds);
  ProgressSummary get progress => _progress;
  AppSettings get settings => _settings;

  Future<void> initialize() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    logger.info('app.initialize.started');
    try {
      _settings = await settingsRepository.load();
      _questions = await questionRepository.loadAll();
      _profiles = await database.loadProfiles();
      if (_profiles.isEmpty) {
        final PlayerProfile defaultProfile = PlayerProfile(
          id: 'local-default',
          displayName: 'Local Player',
          createdAt: DateTime.now(),
        );
        await database.upsertProfile(defaultProfile);
        _profiles = <PlayerProfile>[defaultProfile];
      }
      final String? preferredId = await profilePreferences.loadActiveProfileId();
      _activeProfile = _profiles.firstWhere(
        (PlayerProfile profile) => profile.id == preferredId,
        orElse: () => _profiles.first,
      );
      await profilePreferences.saveActiveProfileId(_activeProfile!.id);
      await _refreshProfileData();
      _leaderboard = await database.loadLeaderboard();
      logger.info(
        'app.initialize.completed',
        fields: <String, Object?>{
          'questionCount': _questions.length,
          'profileCount': _profiles.length,
        },
      );
    } on Object catch (error) {
      logger.error(
        'app.initialize.failed',
        fields: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      _errorMessage = 'Unable to initialize QuizForge. Please try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  List<Question> searchQuestions(
    String query, {
    String? category,
    Difficulty? difficulty,
    bool bookmarkedOnly = false,
  }) {
    final String normalizedQuery = normalizeAnswer(query);
    return _questions.where((Question question) {
      final bool queryMatches = normalizedQuery.isEmpty ||
          normalizeAnswer(question.prompt).contains(normalizedQuery) ||
          normalizeAnswer(question.category).contains(normalizedQuery) ||
          question.tags.any(
            (String tag) => normalizeAnswer(tag).contains(normalizedQuery),
          );
      final bool categoryMatches = category == null ||
          normalizeAnswer(question.category) == normalizeAnswer(category);
      final bool difficultyMatches =
          difficulty == null || question.difficulty == difficulty;
      final bool bookmarkMatches =
          !bookmarkedOnly || _bookmarkIds.contains(question.id);
      return queryMatches &&
          categoryMatches &&
          difficultyMatches &&
          bookmarkMatches;
    }).toList(growable: false);
  }

  Future<void> addQuestion(Question question) async {
    final List<String> errors = question.validate();
    if (errors.isNotEmpty) {
      logger.warning(
        'question.create.rejected',
        fields: <String, Object?>{'errorCount': errors.length},
      );
      throw ArgumentError(errors.join(' '));
    }
    final DuplicateReport report =
        deduplicator.partition(<Question>[question], existing: _questions);
    if (report.unique.isEmpty) {
      logger.warning('question.create.duplicate');
      throw ArgumentError('A question with the same id or content already exists.');
    }
    await questionRepository.saveAll(report.unique);
    _questions = <Question>[..._questions, ...report.unique];
    _errorMessage = null;
    logger.info('question.create.completed');
    notifyListeners();
  }

  Future<QuestionBankImportResult> importJson(String source) async {
    final QuestionBankImportResult result =
        codec.decodeJson(source, existing: _questions);
    await _persistImportResult(result, format: 'json');
    return result;
  }

  Future<QuestionBankImportResult> importCsv(String source) async {
    final QuestionBankImportResult result =
        codec.decodeCsv(source, existing: _questions);
    await _persistImportResult(result, format: 'csv');
    return result;
  }

  String exportJson() => codec.encodeJson(_questions);

  String exportCsv() => codec.encodeCsv(_questions);

  Future<void> createProfile(String displayName) async {
    final PlayerProfile profile = PlayerProfile(
      id: 'profile-${DateTime.now().microsecondsSinceEpoch}',
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
    );
    final List<String> errors = profile.validate();
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
    await database.upsertProfile(profile);
    _profiles = <PlayerProfile>[..._profiles, profile];
    _leaderboard = await database.loadLeaderboard();
    await selectProfile(profile.id);
    logger.info(
      'profile.create.completed',
      fields: <String, Object?>{'profileCount': _profiles.length},
    );
  }

  Future<void> selectProfile(String profileId) async {
    final PlayerProfile selected = _profiles.firstWhere(
      (PlayerProfile profile) => profile.id == profileId,
      orElse: () => throw ArgumentError('Unknown profile id.'),
    );
    _activeProfile = selected;
    await profilePreferences.saveActiveProfileId(selected.id);
    await _refreshProfileData();
    logger.info('profile.select.completed');
    notifyListeners();
  }

  Future<void> toggleBookmark(String questionId) async {
    final PlayerProfile? profile = _activeProfile;
    if (profile == null) {
      throw StateError('No active profile.');
    }
    final bool nextValue = !_bookmarkIds.contains(questionId);
    await database.setBookmark(
      profileId: profile.id,
      questionId: questionId,
      bookmarked: nextValue,
    );
    final Set<String> updated = Set<String>.of(_bookmarkIds);
    if (nextValue) {
      updated.add(questionId);
    } else {
      updated.remove(questionId);
    }
    _bookmarkIds = updated;
    logger.info(
      'bookmark.changed',
      fields: <String, Object?>{'bookmarked': nextValue},
    );
    notifyListeners();
  }

  Future<void> recordResult(QuizResult result) async {
    final PlayerProfile? profile = _activeProfile;
    if (profile == null) {
      throw StateError('No active profile.');
    }
    await database.saveAttempt(profile.id, result);
    _progress = await database.loadProgress(profile.id);
    _leaderboard = await database.loadLeaderboard();
    logger.info(
      'quiz.completed',
      fields: <String, Object?>{
        'questionCount': result.totalCount,
        'correctCount': result.correctCount,
        'bestStreak': result.bestStreak,
      },
    );
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await settingsRepository.save(settings);
    logger.info('settings.updated');
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _persistImportResult(
    QuestionBankImportResult result, {
    required String format,
  }) async {
    if (result.questions.isNotEmpty) {
      await questionRepository.saveAll(result.questions);
      _questions = <Question>[..._questions, ...result.questions];
      notifyListeners();
    }
    logger.info(
      'question.import.completed',
      fields: <String, Object?>{
        'format': format,
        'acceptedCount': result.questions.length,
        'duplicateCount': result.duplicates.length,
        'errorCount': result.errors.length,
      },
    );
  }

  Future<void> _refreshProfileData() async {
    final PlayerProfile? profile = _activeProfile;
    if (profile == null) {
      _bookmarkIds = const <String>{};
      _progress = const ProgressSummary();
      return;
    }
    _bookmarkIds = await database.loadBookmarkIds(profile.id);
    _progress = await database.loadProgress(profile.id);
  }

  @override
  void dispose() {
    unawaited(database.close());
    super.dispose();
  }
}
