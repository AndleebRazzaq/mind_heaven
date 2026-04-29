import 'package:flutter/material.dart';
import '../app/router.dart';
import '../features/auth/data/repositories/session_repository_impl.dart';
import '../features/onboarding/data/repositories/onboarding_state_repository_impl.dart';
import '../features/splash/presentation/splash_controller.dart';
import '../services/auth_service.dart';
import '../widgets/reframed_brand_mark.dart';

/// First screen: logo and app name, then route to onboarding or welcome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final controller = SplashController(
      sessionRepository: SessionRepositoryImpl(AuthService()),
      onboardingRepository: OnboardingStateRepositoryImpl(),
    );
    final target = await controller.resolveTarget();
    if (!mounted) return;
    switch (target) {
      case SplashTarget.onboarding:
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        break;
      case SplashTarget.welcome:
        Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
        break;
      case SplashTarget.shell:
        Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ReframedBrandMark(fontSize: 62, underlineWidth: 104),
              const SizedBox(height: 34),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
