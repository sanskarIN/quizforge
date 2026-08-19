import 'app_database.dart';

extension AppDatabaseMaintenance on AppDatabase {
  Future<void> renameProfile({
    required String profileId,
    required String displayName,
  }) async {
    await customStatement(
      'UPDATE profiles SET display_name = ? WHERE id = ?',
      <Object?>[displayName.trim(), profileId],
    );
  }

  Future<void> deleteProfile(String profileId) async {
    await transaction(() async {
      await customStatement(
        'DELETE FROM profiles WHERE id = ?',
        <Object?>[profileId],
      );
    });
  }

  Future<void> clearProfileActivity(String profileId) async {
    await transaction(() async {
      await customStatement(
        'DELETE FROM attempts WHERE profile_id = ?',
        <Object?>[profileId],
      );
      await customStatement(
        'DELETE FROM bookmarks WHERE profile_id = ?',
        <Object?>[profileId],
      );
    });
  }

  Future<void> resetAllLocalData() async {
    await transaction(() async {
      // Child tables are listed explicitly so the operation is predictable even
      // if foreign-key cascade behavior changes in a future migration.
      await customStatement('DELETE FROM attempt_answers');
      await customStatement('DELETE FROM attempts');
      await customStatement('DELETE FROM bookmarks');
      await customStatement('DELETE FROM profiles');
      await customStatement('DELETE FROM questions');
    });
  }
}
