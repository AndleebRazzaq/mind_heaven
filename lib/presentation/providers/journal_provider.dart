import 'package:flutter/foundation.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../models/cbt_intervention.dart';
import '../../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository;

  JournalProvider(this._repository);

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
