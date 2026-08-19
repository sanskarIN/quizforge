import 'package:shared_preferences/shared_preferences.dart';

final class ProfilePreferences {
  ProfilePreferences({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _activeProfileKey = 'profiles.activeId';

  Future<String?> loadActiveProfileId() =>
      _preferences.getString(_activeProfileKey);

  Future<void> saveActiveProfileId(String profileId) =>
      _preferences.setString(_activeProfileKey, profileId);
}
