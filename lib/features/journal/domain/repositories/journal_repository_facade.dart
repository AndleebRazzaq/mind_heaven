import '../../../../../domain/repositories/journal_repository.dart';

abstract class JournalRepositoryFacade {
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  });

  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  });
}
