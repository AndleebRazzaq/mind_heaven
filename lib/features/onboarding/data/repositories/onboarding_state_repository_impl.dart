import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/onboarding_state_repository.dart';

class OnboardingStateRepositoryImpl implements OnboardingStateRepository {
  static const _key = 'onboarding_seen';

  @override
  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  @override
  Future<void> setCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
