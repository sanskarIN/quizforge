enum AppThemeMode {
  system,
  light,
  dark,
}

final class AppSettings {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.largeText = false,
    this.reducedMotion = false,
    this.screenReaderHints = true,
    this.confirmBeforeExitQuiz = true,
  });

  final AppThemeMode themeMode;
  final bool largeText;
  final bool reducedMotion;
  final bool screenReaderHints;
  final bool confirmBeforeExitQuiz;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? largeText,
    bool? reducedMotion,
    bool? screenReaderHints,
    bool? confirmBeforeExitQuiz,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      largeText: largeText ?? this.largeText,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      screenReaderHints: screenReaderHints ?? this.screenReaderHints,
      confirmBeforeExitQuiz:
          confirmBeforeExitQuiz ?? this.confirmBeforeExitQuiz,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'themeMode': themeMode.name,
        'largeText': largeText,
        'reducedMotion': reducedMotion,
        'screenReaderHints': screenReaderHints,
        'confirmBeforeExitQuiz': confirmBeforeExitQuiz,
      };

  static AppSettings fromJson(Map<String, Object?> json) {
    final Object? rawTheme = json['themeMode'];
    final AppThemeMode theme = rawTheme is String
        ? AppThemeMode.values.firstWhere(
            (AppThemeMode value) => value.name == rawTheme,
            orElse: () => AppThemeMode.system,
          )
        : AppThemeMode.system;
    return AppSettings(
      themeMode: theme,
      largeText: _boolValue(json['largeText'], fallback: false),
      reducedMotion: _boolValue(json['reducedMotion'], fallback: false),
      screenReaderHints: _boolValue(
        json['screenReaderHints'],
        fallback: true,
      ),
      confirmBeforeExitQuiz: _boolValue(
        json['confirmBeforeExitQuiz'],
        fallback: true,
      ),
    );
  }

  static bool _boolValue(Object? value, {required bool fallback}) =>
      value is bool ? value : fallback;
}
