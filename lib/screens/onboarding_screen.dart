import 'package:flutter/material.dart';
import '../app/router.dart';
import '../features/onboarding/data/repositories/onboarding_state_repository_impl.dart';
import '../features/onboarding/presentation/onboarding_controller.dart';

/// Multiple onboarding pages: calming style, dots, Get started.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const String _onboardAsset =
      'assets/onboarding/onboard_illustration_1.png';
  static const String _altOnboardAsset = 'assets/logo/logo_floral.png';

  static const _pages = [
    _OnboardingPage(
      title: 'Your Mind Matters',
      subtitle:
          'Understand your thoughts, emotions, and patterns to improve your mental well-being.',
      imageAsset: _onboardAsset,
    ),
    _OnboardingPage(
      title: 'rewrite what hurts you',
      subtitle: 'overthinking, doubt, fear —\nwe’ll turn them into clarity.',
      imageAsset: _altOnboardAsset,
    ),
    _OnboardingPage(
      title: 'Build a Healthier Mindset',
      subtitle:
          'Challenge distortions and grow with small, positive changes every day.',
      imageAsset: _altOnboardAsset,
    ),
  ];

  Future<void> _finish() async {
    final controller = OnboardingController(OnboardingStateRepositoryImpl());
    await controller.markCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        Image.asset(
                          p.imageAsset,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                        const Spacer(flex: 2),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: const Color(0xFF161B22),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF737373),
                                height: 1.4,
                              ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentPage == i ? 28 : 12,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF1387E8)
                        : const Color(0xFFD2D2D2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _finish
                      : () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1387E8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: _finish,
              child: const Text(
                'Skip',
                style: TextStyle(color: Color(0xFF737373)),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final String imageAsset;
  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
  });
}
