import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_store.dart';

final class OnboardingRepository implements OnboardingStore {
  OnboardingRepository({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _completedKey = 'onboarding.completed';

  @override
  Future<bool> isCompleted() async =>
      await _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> markCompleted() => _preferences.setBool(_completedKey, true);

  @override
  Future<void> reset() => _preferences.remove(_completedKey);
}
