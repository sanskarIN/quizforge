import 'package:shared_preferences/shared_preferences.dart';

import 'profile_selection_store.dart';

final class ProfilePreferences implements ProfileSelectionStore {
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
