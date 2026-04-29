import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

/// Persists check-ins and journal entries for analytics.
class StorageService {
  static const _keyJournalEntries = 'mind_heaven_journal_entries';

  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_keyJournalEntries);
    if (json == null) return [];
    return json
        .map(
          (e) => _journalEntryFromJson(jsonDecode(e) as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    final list = await getJournalEntries();
    list.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyJournalEntries,
      list.map((e) => jsonEncode(_journalEntryToJson(e))).toList(),
    );
  }

  Future<void> updateJournalEntry(String id, JournalEntry updated) async {
    final list = await getJournalEntries();
    final idx = list.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    list[idx] = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyJournalEntries,
      list.map((e) => jsonEncode(_journalEntryToJson(e))).toList(),
    );
  }

  static Map<String, dynamic> _journalEntryToJson(JournalEntry e) => {
    'id': e.id,
    'dateTime': e.dateTime.toIso8601String(),
    'content': e.content,
    'distortion': e.detectedDistortion?.name,
    'distortionLabel': e.detectedDistortionLabel,
    'confidenceLevel': e.confidenceLevel,
    'reframe': e.reframe,
    'eventSummary': e.eventSummary,
    'coreBelief': e.coreBelief,
    'behavioralShiftPrompt': e.behavioralShiftPrompt,
    'reframeGenerationMode': e.reframeGenerationMode,
    'plantSuggestion': e.plantSuggestion,
    'moodLabel': e.moodLabel,
    'stressBefore': e.stressBefore,
    'stressAfter': e.stressAfter,
    'tags': e.tags,
  };

  static JournalEntry _journalEntryFromJson(Map<String, dynamic> m) {
    DistortionType? d;
    if (m['distortion'] != null) {
      final name = m['distortion'] as String;
      try {
        d = DistortionType.values.firstWhere((e) => e.name == name);
      } catch (_) {
        d = null;
      }
    }
    return JournalEntry(
      id: m['id'] as String,
      dateTime: DateTime.parse(m['dateTime'] as String),
      content: m['content'] as String,
      detectedDistortion: d,
      detectedDistortionLabel: m['distortionLabel'] as String?,
      confidenceLevel: m['confidenceLevel'] as String?,
      reframe: m['reframe'] as String?,
      eventSummary: m['eventSummary'] as String?,
      coreBelief: m['coreBelief'] as String?,
      behavioralShiftPrompt: m['behavioralShiftPrompt'] as String?,
      reframeGenerationMode: m['reframeGenerationMode'] as String?,
      plantSuggestion: m['plantSuggestion'] as String?,
      moodLabel: m['moodLabel'] as String?,
      stressBefore: (m['stressBefore'] as num?)?.toDouble(),
      stressAfter: (m['stressAfter'] as num?)?.toDouble(),
      tags: ((m['tags'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
