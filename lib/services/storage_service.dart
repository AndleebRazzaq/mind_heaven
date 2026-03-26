import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../models/mood_entry.dart';

/// Persists check-ins and journal entries for analytics.
class StorageService {
  static const _keyCheckIns = 'mind_heaven_check_ins';
  static const _keyJournalEntries = 'mind_heaven_journal_entries';

  Future<List<MoodEntry>> getCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_keyCheckIns);
    if (json == null) return [];
    return json.map((e) => _MoodEntryFromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  Future<void> addCheckIn(MoodEntry entry) async {
    final list = await getCheckIns();
    list.add(entry);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyCheckIns,
      list.map((e) => jsonEncode(_moodEntryToJson(e))).toList(),
    );
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList(_keyJournalEntries);
    if (json == null) return [];
    return json.map((e) => _journalEntryFromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
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

  static Map<String, dynamic> _moodEntryToJson(MoodEntry e) => {
        'id': e.id,
        'dateTime': e.dateTime.toIso8601String(),
        'moodLabel': e.moodLabel,
        'stressLevel': e.stressLevel,
      };

  static MoodEntry _MoodEntryFromJson(Map<String, dynamic> m) => MoodEntry(
        id: m['id'] as String,
        dateTime: DateTime.parse(m['dateTime'] as String),
        moodLabel: m['moodLabel'] as String,
        stressLevel: (m['stressLevel'] as num).toDouble(),
      );

  static Map<String, dynamic> _journalEntryToJson(JournalEntry e) => {
        'id': e.id,
        'dateTime': e.dateTime.toIso8601String(),
        'content': e.content,
        'distortion': e.detectedDistortion?.name,
        'reframe': e.reframe,
        'plantSuggestion': e.plantSuggestion,
        'moodLabel': e.moodLabel,
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
      reframe: m['reframe'] as String?,
      plantSuggestion: m['plantSuggestion'] as String?,
      moodLabel: m['moodLabel'] as String?,
    );
  }
}
