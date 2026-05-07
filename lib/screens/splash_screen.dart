import 'dart:async';

import 'package:flutter/material.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoAsset = 'assets/logo/reframed logo.png';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _navigate();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final completer = Completer<void>();
    _navigationTimer = Timer(
      const Duration(milliseconds: 3000),
      completer.complete,
    );
    await completer.future;
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
      backgroundColor: const Color(0xFF0A0A0A), // Black background
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    _logoAsset,
                    width: 260,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.psychology,
                      size: 100,
                      color: Color(0xFFB4C6FC),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
