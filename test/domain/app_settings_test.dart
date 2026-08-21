import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/domain/app_settings.dart';

void main() {
  test('settings JSON round trip preserves all values', () {
    const AppSettings settings = AppSettings(
      themeMode: AppThemeMode.dark,
      largeText: true,
      reducedMotion: true,
      screenReaderHints: false,
      confirmBeforeExitQuiz: false,
    );

    final AppSettings decoded = AppSettings.fromJson(settings.toJson());

    expect(decoded.themeMode, AppThemeMode.dark);
    expect(decoded.largeText, isTrue);
    expect(decoded.reducedMotion, isTrue);
    expect(decoded.screenReaderHints, isFalse);
    expect(decoded.confirmBeforeExitQuiz, isFalse);
  });

  test('settings JSON falls back safely for invalid values', () {
    final AppSettings decoded = AppSettings.fromJson(<String, Object?>{
      'themeMode': 'future-value',
      'largeText': 'yes',
      'reducedMotion': null,
      'screenReaderHints': 1,
      'confirmBeforeExitQuiz': <String>[],
    });

    expect(decoded.themeMode, AppThemeMode.system);
    expect(decoded.largeText, isFalse);
    expect(decoded.reducedMotion, isFalse);
    expect(decoded.screenReaderHints, isTrue);
    expect(decoded.confirmBeforeExitQuiz, isTrue);
  });
}
