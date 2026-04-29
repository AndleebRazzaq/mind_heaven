import 'package:flutter/material.dart';

import '../features/auth/presentation/auth_flow_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/shell/presentation/main_shell_page.dart';
import '../features/splash/presentation/splash_page.dart';
import '../routes/app_routes.dart';
import '../screens/auth_screen.dart';
import '../screens/welcome_screen.dart';
export '../routes/app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
      case AppRoutes.welcome:
        return MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
          settings: settings,
        );
      case AppRoutes.authLogin:
        return MaterialPageRoute(
          builder: (_) => const AuthFlowPage(initialLogin: true),
          settings: settings,
        );
      case AppRoutes.authSignUp:
        return MaterialPageRoute(
          builder: (_) => const AuthFlowPage(initialLogin: false),
          settings: settings,
        );
      case AppRoutes.shell:
        return MaterialPageRoute(
          builder: (_) => const MainShellPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const AuthScreen(initialLogin: true),
          settings: settings,
        );
    }
  }
}
