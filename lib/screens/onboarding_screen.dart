import 'package:flutter/material.dart';
import '../app/router.dart';

/// Multiple onboarding pages: calming style, 3 CBT steps with images.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    const _OnboardingPage(
      imagePath: 'assets/onboarding/onboard_1.png',
      title: 'Understand Your Thoughts',
      subtitle: 'Learn to identify and challenge negative thought patterns.',
    ),
    const _OnboardingPage(
      imagePath: 'assets/onboarding/onboard_2.png',
      title: 'Track Your Emotions',
      subtitle: 'Monitor your emotional state and patterns over time.',
    ),
    const _OnboardingPage(
      imagePath: 'assets/onboarding/onboard_3.png',
      title: 'Build Resilience',
      subtitle: 'Develop a healthier mindset with proven CBT techniques.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? const Color(0xFFB4C6FC)
                              : Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Gradient Button "Elevate" / "Next"
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8A6BFF), Color(0xFFE4A4C1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A6BFF).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _nextPage,
                        child: Center(
                          child: Text(
                            'Next',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101216),
                            ),
                          ),
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

  Widget _buildPage(_OnboardingPage page) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.52).clamp(180.0, 320.0);
        final contentGap = constraints.maxHeight < 480 ? 24.0 : 48.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                page.imagePath,
                height: imageHeight,
                fit: BoxFit.contain,
              ),
              SizedBox(height: contentGap),
              Text(
                page.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                page.subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade400,
                  height: 1.4,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}
