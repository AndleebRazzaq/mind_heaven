import 'package:flutter/foundation.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../models/cbt_intervention.dart';

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository;

  JournalProvider(this._repository);

  bool isLoading = false;
  String? error;
  CBTIntervention? intervention;

  Future<void> analyze(String text) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.analyzeAndSave(text);
      intervention = result.intervention;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
