import 'package:flutter_test/flutter_test.dart';
import 'package:mind_heaven/domain/repositories/journal_repository.dart';
import 'package:mind_heaven/models/cbt_intervention.dart';
import 'package:mind_heaven/models/journal_entry.dart';
import 'package:mind_heaven/presentation/providers/journal_provider.dart';

class _FakeSuccessJournalRepository implements JournalRepository {
  @override
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    final intervention = CBTIntervention(
      distortionDescription: 'test',
      insight: 'ack',
      microInterventionTitle: 'Cognitive restructuring',
      reframe: 'reframe',
      breathingTechnique: 'exercise',
      action: 'description',
      plantSuggestion: 'Lavender',
      moodLabel: 'Anxiety',
      confidence: 0.82,
    );
    final entry = JournalEntry(
      id: '1',
      dateTime: DateTime.now(),
      content: text,
      detectedDistortion: DistortionType.magnification,
      reframe: intervention.reframe,
      plantSuggestion: intervention.plantSuggestion,
      moodLabel: intervention.moodLabel,
    );
    return JournalAnalysisResult(intervention: intervention, entry: entry);
  }

  @override
  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  }) async {}
}

class _FakeErrorJournalRepository implements JournalRepository {
  @override
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    throw Exception('repo failed');
  }

  @override
  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  }) async {}
}

void main() {
  test('JournalProvider analyze success updates intervention', () async {
    final provider = JournalProvider(_FakeSuccessJournalRepository());

    await provider.analyze('I will fail this always');

    expect(provider.isLoading, false);
    expect(provider.error, isNull);
    expect(provider.intervention, isNotNull);
    expect(provider.intervention?.plantSuggestion, 'Lavender');
  });

  test('JournalProvider analyze failure sets error', () async {
    final provider = JournalProvider(_FakeErrorJournalRepository());

    await provider.analyze('text');

    expect(provider.isLoading, false);
    expect(provider.intervention, isNull);
    expect(provider.error, isNotNull);
  });
}
