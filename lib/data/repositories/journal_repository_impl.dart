import '../../core/intervention/intervention_builder.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../models/journal_entry.dart';
import '../../services/storage_service.dart';
import '../remote/journal_remote_data_source.dart';

class JournalRepositoryImpl implements JournalRepository {
  final StorageService _storage;
  final InterventionBuilder _localBuilder;
  final JournalRemoteDataSource? _remote;
  final bool useRemote;

  JournalRepositoryImpl({
    required StorageService storage,
    required InterventionBuilder localBuilder,
    JournalRemoteDataSource? remote,
    this.useRemote = false,
  })  : _storage = storage,
        _localBuilder = localBuilder,
        _remote = remote;

  @override
  Future<JournalAnalysisResult> analyzeAndSave(String text) async {
    if (text.trim().isEmpty) throw Exception('Journal text is empty');

    final intervention = useRemote && _remote != null
        ? await _remote.analyzeJournalText(text)
        : (await _localBuilder.buildForJournal(text)).intervention;

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      content: text,
      // Kept unknown for remote unless API returns enum-safe label.
      detectedDistortion: DistortionType.unknown,
      reframe: intervention.reframeGuidance,
      plantSuggestion: intervention.plantSuggestion,
      moodLabel: intervention.moodLabel,
    );
    await _storage.addJournalEntry(entry);
    return JournalAnalysisResult(intervention: intervention, entry: entry);
  }
}
