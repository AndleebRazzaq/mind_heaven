import 'package:flutter_test/flutter_test.dart';
import 'package:mind_heaven/core/intervention/intervention_builder.dart';
import 'package:mind_heaven/data/repositories/journal_repository_impl.dart';
import 'package:mind_heaven/models/cbt_intervention.dart';
import 'package:mind_heaven/models/journal_entry.dart';
import 'package:mind_heaven/services/storage_service.dart';

class _FakeStorageService extends StorageService {
  final List<JournalEntry> saved = [];

  @override
  Future<void> addJournalEntry(JournalEntry entry) async {
    saved.add(entry);
  }
}

class _FakeInterventionBuilder extends InterventionBuilder {
  _FakeInterventionBuilder() : super();

  @override
  Future<JournalInterventionResult> buildForJournal(String text) async {
    final intervention = CBTIntervention(
      distortionExplanation: 'dist',
      emotionalAcknowledgment: 'ack',
      interventionMode: 'Direct CBT correction',
      cbtTechnique: 'Evidence examination',
      reframeGuidance: 'reframe',
      copingExerciseTitle: 'exercise',
      copingExerciseDescription: 'desc',
      plantSuggestion: 'Lavender',
      moodLabel: 'Anxiety',
      confidence: 0.82,
    );
    return JournalInterventionResult(
      intervention: intervention,
      distortionType: DistortionType.magnification,
      emotionLabel: 'Anxiety',
      emotionConfidence: 0.74,
    );
  }
}

void main() {
  test('JournalRepositoryImpl analyzeAndSave saves and returns result', () async {
    final fakeStorage = _FakeStorageService();
    final repo = JournalRepositoryImpl(
      storage: fakeStorage,
      localBuilder: _FakeInterventionBuilder(),
      useRemote: false,
    );

    final result = await repo.analyzeAndSave(
      'I always fail',
      userReportedIntensity: 8,
    );

    expect(result.intervention.plantSuggestion, 'Lavender');
    expect(fakeStorage.saved.length, 1);
    expect(fakeStorage.saved.first.content, 'I always fail');
  });

  test('JournalRepositoryImpl throws on empty text', () async {
    final fakeStorage = _FakeStorageService();
    final repo = JournalRepositoryImpl(
      storage: fakeStorage,
      localBuilder: _FakeInterventionBuilder(),
      useRemote: false,
    );

    expect(() => repo.analyzeAndSave('   '), throwsException);
  });
}
