import 'package:riverpod/riverpod.dart';

import '../domain/repositories/journal_repository.dart';
import '../services/analytics_models.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  throw UnimplementedError('JournalRepository must be provided by AppRoot.');
});

final analyticsServiceProvider = Provider<AnalyticsReader>((ref) {
  throw UnimplementedError('AnalyticsReader must be provided by AppRoot.');
});
