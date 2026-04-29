import 'package:mind_heaven/app/app_providers.dart';
import 'package:mind_heaven/domain/repositories/journal_repository.dart';
import 'package:mind_heaven/models/cbt_intervention.dart';
import 'package:mind_heaven/models/journal_entry.dart';
import 'package:mind_heaven/presentation/providers/journal_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

class _FakeSuccessJournalRepository implements JournalRepository {
  @override
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    final intervention = CBTIntervention(
      distortionExplanation: 'test',
      emotionalAcknowledgment: 'ack',
      interventionMode: 'Direct CBT correction',
      cbtTechnique: 'Cognitive restructuring',
      reframeGuidance: 'reframe',
      copingExerciseTitle: 'exercise',
      copingExerciseDescription: 'description',
      plantSuggestion: 'Lavender',
      moodLabel: 'Anxiety',
      confidence: 0.82,
    );
    final entry = JournalEntry(
      id: '1',
      dateTime: DateTime.now(),
      content: text,
      detectedDistortion: DistortionType.magnification,
      reframe: intervention.reframeGuidance,
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
  test('JournalController analyze success updates intervention', () async {
    final container = ProviderContainer(
      overrides: [
        journalRepositoryProvider.overrideWithValue(
          _FakeSuccessJournalRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(journalControllerProvider.notifier)
        .analyze('I will fail this always');

    final state = container.read(journalControllerProvider);
    expect(state.isLoading, false);
    expect(state.error, isNull);
    expect(state.intervention, isNotNull);
    expect(state.intervention?.plantSuggestion, 'Lavender');
  });

  test('JournalController analyze failure sets error', () async {
    final container = ProviderContainer(
      overrides: [
        journalRepositoryProvider.overrideWithValue(
          _FakeErrorJournalRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(journalControllerProvider.notifier).analyze('text');

    final state = container.read(journalControllerProvider);
    expect(state.isLoading, false);
    expect(state.intervention, isNull);
    expect(state.error, isNotNull);
  });
}
