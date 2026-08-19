abstract interface class OnboardingStore {
  Future<bool> isCompleted();

  Future<void> markCompleted();

  Future<void> reset();
}
