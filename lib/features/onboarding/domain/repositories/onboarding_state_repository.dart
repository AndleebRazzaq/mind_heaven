abstract class OnboardingStateRepository {
  Future<bool> isCompleted();
  Future<void> setCompleted(bool value);
}
