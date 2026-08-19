import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';
import 'settings_store.dart';

final class SettingsRepository implements SettingsStore {
  SettingsRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _themeKey = 'settings.themeMode';
  static const String _largeTextKey = 'settings.largeText';
  static const String _reducedMotionKey = 'settings.reducedMotion';
  static const String _screenReaderHintsKey = 'settings.screenReaderHints';
  static const String _confirmExitKey = 'settings.confirmBeforeExitQuiz';

  static const List<String> _keys = <String>[
    _themeKey,
    _largeTextKey,
    _reducedMotionKey,
    _screenReaderHintsKey,
    _confirmExitKey,
  ];

  @override
  Future<AppSettings> load() async {
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

  @override
  Future<void> save(AppSettings settings) async {
    await _preferences.setString(_themeKey, settings.themeMode.name);
    await _preferences.setBool(_largeTextKey, settings.largeText);
    await _preferences.setBool(_reducedMotionKey, settings.reducedMotion);
    await _preferences.setBool(
      _screenReaderHintsKey,
      settings.screenReaderHints,
    );
    await _preferences.setBool(
      _confirmExitKey,
      settings.confirmBeforeExitQuiz,
    );
  }

  @override
  Future<void> reset() async {
    for (final String key in _keys) {
      await _preferences.remove(key);
    }
  }
}
