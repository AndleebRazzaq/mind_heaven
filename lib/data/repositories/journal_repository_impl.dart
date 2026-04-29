import '../../core/intervention/intervention_builder.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../models/journal_entry.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_journal_service.dart';
import '../../services/storage_service.dart';
import '../remote/journal_remote_data_source.dart';

class JournalRepositoryImpl implements JournalRepository {
  final StorageService _storage;
  final InterventionBuilder _localBuilder;
  final JournalRemoteDataSource? _remote;
  final AuthService _authService;
  final FirestoreJournalService _cloudService;
  final bool useRemote;

  JournalRepositoryImpl({
    required StorageService storage,
    required InterventionBuilder localBuilder,
    AuthService? authService,
    FirestoreJournalService? cloudService,
    JournalRemoteDataSource? remote,
    this.useRemote = false,
  })  : _storage = storage,
        _localBuilder = localBuilder,
        _authService = authService ?? AuthService(),
        _cloudService = cloudService ?? FirestoreJournalService(),
        _remote = remote;

  DistortionType _mapDistortionLabel(String? rawLabel) {
    final label = (rawLabel ?? '').trim().toLowerCase();
    if (label.contains('all-or-nothing')) return DistortionType.allOrNothing;
    if (label.contains('overgeneral')) return DistortionType.overgeneralization;
    if (label.contains('mental filter')) return DistortionType.mentalFilter;
    if (label.contains('disqualifying')) return DistortionType.disqualifyingPositive;
    if (label.contains('jumping')) return DistortionType.jumpingToConclusions;
    if (label.contains('mind reading')) return DistortionType.jumpingToConclusions;
    if (label.contains('catastroph') || label.contains('magnification')) {
      return DistortionType.magnification;
    }
    if (label.contains('emotional reasoning')) return DistortionType.emotionalReasoning;
    if (label.contains('should')) return DistortionType.shouldStatements;
    if (label.contains('label')) return DistortionType.labeling;
    if (label.contains('personalization')) return DistortionType.personalization;
    return DistortionType.unknown;
  }

  List<String> _extractTags(String text) {
    final matches = RegExp(r'#([a-zA-Z][a-zA-Z0-9_-]*)').allMatches(text);
    final set = <String>{};
    for (final m in matches) {
      final tag = (m.group(1) ?? '').trim().toLowerCase();
      if (tag.isNotEmpty) set.add(tag);
    }
    return set.toList();
  }

  @override
  Future<JournalAnalysisResult> analyzeAndSave(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    if (text.trim().isEmpty) throw Exception('Journal text is empty');

    final intervention = useRemote && _remote != null
        ? await _remote.analyzeJournalText(
            text,
            userReportedIntensity: userReportedIntensity,
          )
        : (await _localBuilder.buildForJournal(text)).intervention;

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      content: text,
      detectedDistortion: _mapDistortionLabel(intervention.detectedDistortionLabel),
      detectedDistortionLabel: intervention.detectedDistortionLabel,
      confidenceLevel: intervention.confidenceLevel ?? intervention.certainty,
      reframe: intervention.reframeGuidance,
      eventSummary: intervention.eventSummary,
      coreBelief:
          intervention.coreBeliefs.isEmpty ? null : intervention.coreBeliefs.first,
      behavioralShiftPrompt: intervention.behavioralShiftPrompt,
      reframeGenerationMode: intervention.reframeGenerationMode,
      plantSuggestion: intervention.plantSuggestion,
      moodLabel: intervention.moodLabel,
      stressBefore: stressBefore,
      tags: _extractTags(text),
    );
    await _storage.addJournalEntry(entry);
    final user = await _authService.getCurrentUser();
    if (user != null) {
      await _cloudService.saveEntry(uid: user.uid, entry: entry);
    }
    return JournalAnalysisResult(intervention: intervention, entry: entry);
  }

  @override
  Future<void> savePostReflectionRating({
    required String entryId,
    required double stressAfter,
  }) async {
    final entries = await _storage.getJournalEntries();
    JournalEntry? existing;
    for (final entry in entries) {
      if (entry.id == entryId) {
        existing = entry;
        break;
      }
    }
    if (existing == null) return;
    await _storage.updateJournalEntry(
      entryId,
      existing.copyWith(stressAfter: stressAfter),
    );
    final user = await _authService.getCurrentUser();
    if (user != null) {
      await _cloudService.updateStressAfter(
        uid: user.uid,
        entryId: entryId,
        stressAfter: stressAfter,
      );
    }
  }
}
