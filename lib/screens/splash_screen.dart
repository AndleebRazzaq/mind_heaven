import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app/router.dart';
import '../features/auth/data/repositories/session_repository_impl.dart';
import '../features/onboarding/data/repositories/onboarding_state_repository_impl.dart';
import '../features/splash/presentation/splash_controller.dart';
import '../services/auth_service.dart';

/// First screen: logo and app name, then route to onboarding or welcome.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _logoAsset = 'assets/logo/reframed_logo.svg';

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
      backgroundColor: const Color(0xFF0C8CEB),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                _logoAsset,
                width: 130,
                height: 130,
                placeholderBuilder: (_) =>
                    const Icon(Icons.psychology, size: 90, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Mind Heaven',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
