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
      confirmBeforeExitQuiz: confirmBeforeExitQuiz ?? this.confirmBeforeExitQuiz,
    );
  }
}
