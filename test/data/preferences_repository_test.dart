import 'package:flutter_test/flutter_test.dart';
import 'package:quizforge/src/data/profile_preferences.dart';
import 'package:quizforge/src/data/settings_repository.dart';

void main() {
  test('settings repository construction does not require plugin binding', () {
    expect(() => SettingsRepository(), returnsNormally);
  });

  test('profile preferences construction does not require plugin binding', () {
    expect(() => ProfilePreferences(), returnsNormally);
  });
}
