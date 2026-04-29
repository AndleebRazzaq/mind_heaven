import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/intervention/intervention_builder.dart';
import '../core/network/api_client.dart';
import '../data/remote/journal_remote_data_source.dart';
import '../data/repositories/journal_repository_impl.dart';
import '../services/analytics_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_runtime.dart';
import '../services/firestore_journal_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'app.dart';

class AppDependencies {
  final AuthService authService;
  final StorageService storageService;
  final FirestoreJournalService firestoreJournalService;
  final AnalyticsService analyticsService;
  final JournalRepositoryImpl journalRepository;

  const AppDependencies({
    required this.authService,
    required this.storageService,
    required this.firestoreJournalService,
    required this.analyticsService,
    required this.journalRepository,
  });
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseRuntime.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  if (kDebugMode) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', false);
  }

  final authService = AuthService();
  final notificationService = NotificationService(authService: authService);
  await notificationService.initialize();
  final storageService = StorageService();
  final cloudService = FirestoreJournalService();
  final analyticsService = AnalyticsService(
    storage: storageService,
    authService: authService,
    cloudService: cloudService,
  );
  final apiClient = ApiClient();
  final remote = JournalRemoteDataSource(apiClient);
  final journalRepository = JournalRepositoryImpl(
    storage: storageService,
    localBuilder: InterventionBuilder(),
    authService: authService,
    cloudService: cloudService,
    remote: remote,
    useRemote: true,
  );

  final dependencies = AppDependencies(
    authService: authService,
    storageService: storageService,
    firestoreJournalService: cloudService,
    analyticsService: analyticsService,
    journalRepository: journalRepository,
  );

  runApp(AppRoot(dependencies: dependencies));
}
