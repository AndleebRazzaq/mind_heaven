import '../../models/cbt_intervention.dart';
import '../../models/journal_entry.dart';

abstract class JournalRepository {
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  });

  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  });

  Future<List<JournalEntry>> getEntries();

  Future<void> saveEntry(JournalEntry entry);
}

class JournalAnalysisResult {
  final CBTIntervention intervention;
  final JournalEntry entry;

  JournalAnalysisResult({required this.intervention, required this.entry});
}
