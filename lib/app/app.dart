import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'bootstrap.dart';
import 'router.dart';

class AppRoot extends StatelessWidget {
  final AppDependencies dependencies;

  const AppRoot({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        journalRepositoryProvider.overrideWithValue(
          dependencies.journalRepository,
        ),
        analyticsServiceProvider.overrideWithValue(
          dependencies.analyticsService,
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
            primary: Color(0xFF60A5FA),
            onPrimary: Color(0xFF081018),
            secondary: Color(0xFF8B5CF6),
            onSecondary: Color(0xFF0B0614),
            tertiary: Color(0xFF22D3EE),
            surface: Color(0xFF14161B),
            onSurface: Color(0xFFE8EAED),
            error: Color(0xFFFF7B8A),
            onError: Color(0xFF1A0D10),
          ),
          scaffoldBackgroundColor: const Color(0xFF07090D),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF07090D),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF161A21),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A3140)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF60A5FA),
                width: 1.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
