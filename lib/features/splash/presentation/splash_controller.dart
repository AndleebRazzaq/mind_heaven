import '../../auth/domain/repositories/session_repository.dart';
import '../../onboarding/domain/repositories/onboarding_state_repository.dart';

enum SplashTarget { onboarding, welcome, shell }

class SplashController {
  final SessionRepository _sessionRepository;
  final OnboardingStateRepository _onboardingRepository;

  SplashController({
    required SessionRepository sessionRepository,
    required OnboardingStateRepository onboardingRepository,
  }) : _sessionRepository = sessionRepository,
       _onboardingRepository = onboardingRepository;

  Future<SplashTarget> resolveTarget() async {
    final onboardingDone = await _onboardingRepository.isCompleted();
    if (!onboardingDone) return SplashTarget.onboarding;
    final signedIn = await _sessionRepository.isSignedIn();
    return signedIn ? SplashTarget.shell : SplashTarget.welcome;
  }
}
