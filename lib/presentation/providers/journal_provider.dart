import 'package:riverpod/riverpod.dart';

import '../../app/app_providers.dart';
import '../../models/cbt_intervention.dart';
import '../../models/journal_entry.dart';

const _unset = Object();

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(JournalController.new);

  bool isLoading = false;
  String? error;
  CBTIntervention? intervention;
  JournalEntry? lastEntry;

  Future<void> analyze(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.analyzeAndSave(
        text,
        userReportedIntensity: userReportedIntensity,
        stressBefore: stressBefore,
      );
      intervention = result.intervention;
      lastEntry = result.entry;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSession() {
    intervention = null;
    lastEntry = null;
    error = null;
    notifyListeners();
  }

  Future<void> savePostRating(double stressAfter) async {
    final entry = lastEntry;
    if (entry == null) return;
    await _repository.savePostReflectionRating(
      entryId: entry.id,
      stressAfter: stressAfter,
    );
    lastEntry = entry.copyWith(stressAfter: stressAfter);
    notifyListeners();
  }
}
