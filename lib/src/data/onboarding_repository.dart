import 'package:shared_preferences/shared_preferences.dart';

final class OnboardingRepository {
  OnboardingRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _completedKey = 'onboarding.completed';

  Future<bool> isCompleted() async =>
      await _preferences.getBool(_completedKey) ?? false;

  Future<void> markCompleted() => _preferences.setBool(_completedKey, true);

  Future<void> reset() => _preferences.remove(_completedKey);
}
