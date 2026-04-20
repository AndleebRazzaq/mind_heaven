import '../domain/repositories/onboarding_state_repository.dart';

class OnboardingController {
  final OnboardingStateRepository _repository;

  OnboardingController(this._repository);

  Future<void> markCompleted() => _repository.setCompleted(true);
}
