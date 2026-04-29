import '../../../../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/journal_repository_facade.dart';

class JournalRepositoryFacadeImpl implements JournalRepositoryFacade {
  final JournalRepository _repository;

  JournalRepositoryFacadeImpl(this._repository);

  @override
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) {
    return _repository.analyzeAndSave(
      text,
      userReportedIntensity: userReportedIntensity,
      stressBefore: stressBefore,
    );
  }

  @override
  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  }) {
    return _repository.savePostReflectionRating(
      entryId: entryId,
      stressAfter: stressAfter,
    );
  }
}
