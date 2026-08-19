import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ActiveProfilePreferences {
  Future<String?> loadActiveProfileId();

  Future<void> saveActiveProfileId(String profileId);

  Future<void> clearActiveProfileId();
}

final class ProfilePreferences implements ActiveProfilePreferences {
  ProfilePreferences({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _activeProfileKey = 'profiles.activeId';

  @override
  Future<String?> loadActiveProfileId() =>
      _preferences.getString(_activeProfileKey);

  @override
  Future<void> saveActiveProfileId(String profileId) =>
      _preferences.setString(_activeProfileKey, profileId);

  @override
  Future<void> clearActiveProfileId() => _preferences.remove(_activeProfileKey);
}
