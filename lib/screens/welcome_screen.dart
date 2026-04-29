import 'package:flutter/material.dart';

import '../app/router.dart';
import '../widgets/reframed_brand_mark.dart';

/// Welcome page styled after the dark Reframed launch screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _openSignUp(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.authSignUp);
  }

  void _openSignIn(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.authLogin);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xFFA78BFA);
    const textPrimary = Color(0xFFE8EAED);
    const textMuted = Color(0xFFC8CBD2);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 36, 32, 30),
                    child: Column(
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.12),
                        Text(
                          'Welcome to',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const ReframedBrandMark(
                          fontSize: 70,
                          underlineWidth: 120,
                        ),
                        const SizedBox(height: 54),
                        Text(
                          'Guided journaling backed\nby science',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: textPrimary,
                            fontSize: 32,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Spacer(),
                        _GradientButton(
                          label: 'Get started',
                          onTap: () => _openSignUp(context),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () => _openSignUp(context),
                                icon: const Icon(
                                  Icons.business_center_outlined,
                                ),
                                label: const Text('Professional access'),
                                style: TextButton.styleFrom(
                                  foregroundColor: accent,
                                  alignment: Alignment.centerLeft,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _openSignIn(context),
                              style: TextButton.styleFrom(
                                foregroundColor: accent,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('Sign in'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 58),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textMuted,
                              height: 1.55,
                            ),
                            children: const [
                              TextSpan(
                                text:
                                    'By continuing, you agree to Reframed\'s\n',
                              ),
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy.',
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFC084FC)],
          ),
          borderRadius: BorderRadius.circular(9),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 64,
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF17141F),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
