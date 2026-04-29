import 'package:riverpod/riverpod.dart';

import '../../app/app_providers.dart';
import '../../models/cbt_intervention.dart';
import '../../models/journal_entry.dart';

const _unset = Object();

final journalControllerProvider =
    NotifierProvider<JournalController, JournalState>(JournalController.new);

class JournalState {
  final bool isLoading;
  final String? error;
  final CBTIntervention? intervention;
  final JournalEntry? lastEntry;

  const JournalState({
    this.isLoading = false,
    this.error,
    this.intervention,
    this.lastEntry,
  });

  JournalState copyWith({
    bool? isLoading,
    Object? error = _unset,
    Object? intervention = _unset,
    Object? lastEntry = _unset,
  }) {
    return JournalState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
      intervention: identical(intervention, _unset)
          ? this.intervention
          : intervention as CBTIntervention?,
      lastEntry: identical(lastEntry, _unset)
          ? this.lastEntry
          : lastEntry as JournalEntry?,
    );
  }
}

class JournalController extends Notifier<JournalState> {
  @override
  JournalState build() => const JournalState();

  Future<void> analyze(
    String text, {
    double? userReportedIntensity,
    double? stressBefore,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ref
          .read(journalRepositoryProvider)
          .analyzeAndSave(
            text,
            userReportedIntensity: userReportedIntensity,
            stressBefore: stressBefore,
          );
      state = state.copyWith(
        intervention: result.intervention,
        lastEntry: result.entry,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void clearSession() {
    state = const JournalState();
  }

  Future<void> savePostRating(double stressAfter) async {
    final entry = state.lastEntry;
    if (entry == null) return;
    await ref
        .read(journalRepositoryProvider)
        .savePostReflectionRating(entryId: entry.id, stressAfter: stressAfter);
    state = state.copyWith(lastEntry: entry.copyWith(stressAfter: stressAfter));
  }
}
