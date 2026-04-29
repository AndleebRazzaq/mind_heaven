import 'package:flutter/material.dart';
import '../app/router.dart';
import '../features/onboarding/data/repositories/onboarding_state_repository_impl.dart';
import '../features/onboarding/presentation/onboarding_controller.dart';

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
      title: 'Your thoughts can feel overwhelming sometimes.',
      subtitle:
          'You’re not alone. Reframed gives you a calm space to slow down and make sense of what’s going on inside your mind.',
      imageAsset: 'assets/onboarding/onboard_1.jpg',
    ),
    _OnboardingPage(
      title: 'Understand what you’re feeling.',
      subtitle:
          'Identify your emotions and the situations behind them — so you’re not just reacting, but becoming aware.',
      imageAsset: 'assets/onboarding/onboard_2.jpg',
    ),
    _OnboardingPage(
      title: 'Not every thought is true.',
      subtitle:
          'Sometimes our mind exaggerates or assumes the worst. Learn to recognize these patterns and take back control.',
      imageAsset: 'assets/onboarding/onboard_3.jpg',
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
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade500,
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),
                        SizedBox(
                          height: 240,
                          child: ClipRect(
                            child: Align(
                              alignment: Alignment.center,
                              heightFactor: 0.6,
                              child: Image.asset(
                                p.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => const Icon(
                                  Icons.psychology,
                                  size: 100,
                                  color: Color(0xFFB4C6FC),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                        Text(
                          p.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.grey.shade400,
                                height: 1.5,
                                fontSize: 16,
                              ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? const Color(0xFFB4C6FC)
                              : const Color(0xFF2C2C30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _currentPage == _pages.length - 1
                        ? _finish
                        : () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8A6BFF), Color(0xFFE4A4C1)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
