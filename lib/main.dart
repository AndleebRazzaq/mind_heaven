import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/intervention/intervention_builder.dart';
import 'core/network/api_client.dart';
import 'data/remote/journal_remote_data_source.dart';
import 'data/repositories/journal_repository_impl.dart';
import 'presentation/providers/insights_provider.dart';
import 'presentation/providers/journal_provider.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService();
    final apiClient = ApiClient();
    final remote = JournalRemoteDataSource(apiClient);
    final journalRepository = JournalRepositoryImpl(
      storage: storage,
      localBuilder: InterventionBuilder(),
      remote: remote,
      useRemote: false, // Set true when FastAPI is ready
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JournalProvider(journalRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => InsightsProvider(AnalyticsService())..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Mind Heaven',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: Colors.blue.shade400,
            onPrimary: Colors.black,
            secondary: Colors.blue.shade300,
            onSecondary: Colors.black,
            tertiary: const Color(0xFF4ECDC4),
            surface: const Color(0xFF0D0D0D),
            onSurface: Colors.white,
            error: Colors.red.shade400,
            onError: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade900),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
