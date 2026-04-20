import 'package:flutter/material.dart';
import '../app/router.dart';
import '../services/auth_service.dart';

/// Welcome page: message + Login / Sign up (reference style).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _authInProgress = false;
  static const String _heroAsset =
      'assets/onboarding/onboard_illustration_1.png';

  Future<void> _continueWithGoogle() async {
    setState(() => _authInProgress = true);
    try {
      await AuthService().signInWithGoogle();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.shell, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _authInProgress = false);
    }
  }

  Future<void> _continueAnonymously() async {
    setState(() => _authInProgress = true);
    try {
      await AuthService().signInAnonymously();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.shell, (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _authInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Image.asset(_heroAsset, height: 290, fit: BoxFit.contain),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 26,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3E3E3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Welcome to Mind Heaven',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF161B22),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Manage your well-being, track your progress, and grow with healthy habits.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF727272),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _authInProgress
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.authLogin),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1387E8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _authInProgress
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushNamed(AppRoutes.authSignUp),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF1387E8),
                          width: 2,
                        ),
                        foregroundColor: const Color(0xFF1387E8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _authInProgress ? null : _continueWithGoogle,
                        child: const Text('Google'),
                      ),
                      const Text(
                        '•',
                        style: TextStyle(color: Color(0xFF9A9A9A)),
                      ),
                      TextButton(
                        onPressed: _authInProgress
                            ? null
                            : _continueAnonymously,
                        child: const Text('Guest'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_authInProgress)
                    const LinearProgressIndicator(minHeight: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
