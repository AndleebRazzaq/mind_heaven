import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/insights_provider.dart';
import '../presentation/providers/journal_provider.dart';
import 'bootstrap.dart';
import 'router.dart';

class AppRoot extends StatelessWidget {
  final AppDependencies dependencies;
  final JournalProvider Function() journalProviderFactory;
  final InsightsProvider Function() insightsProviderFactory;

  const AppRoot({
    super.key,
    required this.dependencies,
    required this.journalProviderFactory,
    required this.insightsProviderFactory,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<JournalProvider>(
          create: (_) => journalProviderFactory(),
        ),
        ChangeNotifierProvider<InsightsProvider>(
          create: (_) => insightsProviderFactory(),
        ),
      ],
      child: MaterialApp(
        title: 'Reframed',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8A6BFF), // Purple from gradient
            onPrimary: Colors.white,
            secondary: Color(0xFFE4A4C1), // Pink from gradient
            onSecondary: Colors.white,
            tertiary: Color(0xFFB4C6FC),
            surface: Color(0xFF14161B),
            onSurface: Colors.white,
            error: Color(0xFFFF7B8A),
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A0A), // Black background
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0A0A), // Black background
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent, // Prevents scroll overlay color changes
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF14161B),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2C2C30)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF8A6BFF), // Purple focus
                width: 1.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
