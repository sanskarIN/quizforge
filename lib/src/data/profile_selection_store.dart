abstract interface class ProfileSelectionStore {
  Future<String?> loadActiveProfileId();

  Future<void> saveActiveProfileId(String profileId);

  Future<void> clearActiveProfileId();
}
