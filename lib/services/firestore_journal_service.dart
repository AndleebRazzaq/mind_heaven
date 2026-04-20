import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';
import 'firebase_runtime.dart';

class FirestoreJournalService {
  bool get _enabled => FirebaseRuntime.isAvailable;
  
  DistortionType _mapDistortionLabel(String? rawLabel) {
    final label = (rawLabel ?? '').trim().toLowerCase();
    if (label.contains('all-or-nothing')) return DistortionType.allOrNothing;
    if (label.contains('overgeneral')) return DistortionType.overgeneralization;
    if (label.contains('mental filter')) return DistortionType.mentalFilter;
    if (label.contains('disqualifying')) return DistortionType.disqualifyingPositive;
    if (label.contains('jumping') || label.contains('mind reading')) {
      return DistortionType.jumpingToConclusions;
    }
    if (label.contains('catastroph') || label.contains('magnification')) {
      return DistortionType.magnification;
    }
    if (label.contains('emotional reasoning')) return DistortionType.emotionalReasoning;
    if (label.contains('should')) return DistortionType.shouldStatements;
    if (label.contains('label')) return DistortionType.labeling;
    if (label.contains('personalization')) return DistortionType.personalization;
    return DistortionType.unknown;
  }

  // Firestore schema:
  // users/{uid}/journal_entries/{entryId}
  // - text, timestamp
  // - emotion.{label}
  // - distortion.{label, confidenceLevel}
  // - structuredReframe.{composed,eventSummary,coreBelief,behavioralPrompt,generationMode}
  // - stressBefore, stressAfter, plantSuggestion, tags[]
  // Security assumption: reads/writes are allowed only for authenticated owner uid.
  Future<void> saveEntry({
    required String uid,
    required JournalEntry entry,
  }) async {
    if (!_enabled) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal_entries')
        .doc(entry.id)
        .set({
      'text': entry.content,
      'timestamp': entry.dateTime.toIso8601String(),
      'emotion': {
        'label': entry.moodLabel,
      },
      'distortion': {
        'label': entry.detectedDistortionLabel,
        'confidenceLevel': entry.confidenceLevel,
      },
      'structuredReframe': {
        'composed': entry.reframe,
        'eventSummary': entry.eventSummary,
        'coreBelief': entry.coreBelief,
        'behavioralPrompt': entry.behavioralShiftPrompt,
        'generationMode': entry.reframeGenerationMode,
      },
      'stressBefore': entry.stressBefore,
      'stressAfter': entry.stressAfter,
      'plantSuggestion': entry.plantSuggestion,
      'tags': entry.tags,
    });
  }

  Future<void> updateStressAfter({
    required String uid,
    required String entryId,
    required double stressAfter,
  }) async {
    if (!_enabled) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal_entries')
        .doc(entryId)
        .set({'stressAfter': stressAfter}, SetOptions(merge: true));
  }

  Future<List<JournalEntry>> getEntries({required String uid}) async {
    if (!_enabled) return [];
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('journal_entries')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final distortionLabel = (data['distortion'] as Map<String, dynamic>?)?['label'] as String?;
      final emotionLabel = (data['emotion'] as Map<String, dynamic>?)?['label'] as String?;
      final structured = (data['structuredReframe'] as Map<String, dynamic>?) ?? const {};
      final tags = ((data['tags'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList();
      final timestampRaw = (data['timestamp'] as String?) ?? DateTime.now().toIso8601String();
      return JournalEntry(
        id: doc.id,
        dateTime: DateTime.tryParse(timestampRaw) ?? DateTime.now(),
        content: (data['text'] as String?) ?? '',
        detectedDistortion: _mapDistortionLabel(distortionLabel),
        detectedDistortionLabel: distortionLabel,
        confidenceLevel:
            (data['distortion'] as Map<String, dynamic>?)?['confidenceLevel'] as String?,
        reframe: structured['composed'] as String?,
        eventSummary: structured['eventSummary'] as String?,
        coreBelief: structured['coreBelief'] as String?,
        behavioralShiftPrompt: structured['behavioralPrompt'] as String?,
        reframeGenerationMode: structured['generationMode'] as String?,
        plantSuggestion: data['plantSuggestion'] as String?,
        moodLabel: emotionLabel,
        stressBefore: (data['stressBefore'] as num?)?.toDouble(),
        stressAfter: (data['stressAfter'] as num?)?.toDouble(),
        tags: tags,
      );
    }).toList();
  }
}

