import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

abstract interface class AppSettingsStore {
  Future<AppSettings> load();

  Future<void> save(AppSettings settings);

  Future<void> reset();
}

final class SettingsRepository implements AppSettingsStore {
  SettingsRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _settingsKey = 'settings.v1';
  static const String _themeKey = 'settings.themeMode';
  static const String _largeTextKey = 'settings.largeText';
  static const String _reducedMotionKey = 'settings.reducedMotion';
  static const String _screenReaderHintsKey = 'settings.screenReaderHints';
  static const String _confirmExitKey = 'settings.confirmBeforeExitQuiz';

  static const List<String> _legacyKeys = <String>[
    _themeKey,
    _largeTextKey,
    _reducedMotionKey,
    _screenReaderHintsKey,
    _confirmExitKey,
  ];

  @override
  Future<AppSettings> load() async {
    final String? payload = await _preferences.getString(_settingsKey);
    if (payload != null) {
      try {
        final Object? decoded = jsonDecode(payload);
        if (decoded is Map<Object?, Object?>) {
          return AppSettings.fromJson(
            decoded.map<String, Object?>(
              (Object? key, Object? value) => MapEntry<String, Object?>(
                key.toString(),
                value,
              ),
            ),
          );
        }
      } on FormatException {
        // Fall through to legacy/default settings if local data is malformed.
      }
    }
    return _loadLegacy();
  }

  @override
  Future<void> save(AppSettings settings) async {
    final String payload = jsonEncode(settings.toJson());
    await _preferences.setString(_settingsKey, payload);
  }

  @override
  Future<void> reset() async {
    await _preferences.remove(_settingsKey);
    for (final String key in _legacyKeys) {
      await _preferences.remove(key);
    }
  }

  Future<AppSettings> _loadLegacy() async {
    final String? themeName = await _preferences.getString(_themeKey);
    final AppThemeMode themeMode = AppThemeMode.values.firstWhere(
      (AppThemeMode value) => value.name == themeName,
      orElse: () => AppThemeMode.system,
    );
    return AppSettings(
      themeMode: themeMode,
      largeText: await _preferences.getBool(_largeTextKey) ?? false,
      reducedMotion: await _preferences.getBool(_reducedMotionKey) ?? false,
      screenReaderHints:
          await _preferences.getBool(_screenReaderHintsKey) ?? true,
      confirmBeforeExitQuiz:
          await _preferences.getBool(_confirmExitKey) ?? true,
    );
  }
}
