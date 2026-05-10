import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../presentation/providers/journal_provider.dart';

class AllEntriesScreen extends StatelessWidget {
  const AllEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101216),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Entries',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, _) {
          if (journalProvider.isLoading && journalProvider.entries.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF8A6BFF)),
              ),
            );
          }

          final entries = journalProvider.entries;
          if (entries.isEmpty) {
            return const Center(
              child: Text(
                'No entries yet.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              IconData icon = Icons.note_alt_outlined;
              Color iconColor = const Color(0xFFB4C6FC);

              if (entry.tags.contains('savoring')) {
                icon = Icons.local_florist_outlined;
                iconColor = const Color(0xFFE4A4C1);
              } else if (entry.tags.contains('ai-journal')) {
                icon = Icons.auto_awesome;
                iconColor = const Color(0xFF8A6BFF);
              } else if (entry.tags.contains('check-in')) {
                icon = Icons.published_with_changes;
                iconColor = const Color(0xFFB4C6FC);
              }

              String displayTitle = 'Journal Entry';
              if (entry.tags.contains('savoring')) {
                displayTitle = 'Savoring';
              } else if (entry.tags.contains('ai-journal')) {
                displayTitle = 'AI Journal';
              } else if (entry.tags.contains('check-in')) {
                displayTitle = 'Check-in';
              }

              return _CompletedEntryItem(
                entry: entry,
                icon: icon,
                iconColor: iconColor,
                title: displayTitle,
                subtitle: entry.content,
              );
            },
          );
        },
      ),
    );
  }
}

class _CompletedEntryItem extends StatelessWidget {
  final JournalEntry entry;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _CompletedEntryItem({
    required this.entry,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14161B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.dateTime.day}/${entry.dateTime.month}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade700, size: 16),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => _EntryDetailSheet(
              entry: entry,
              title: title,
              icon: icon,
              iconColor: iconColor,
            ),
          );
        },
      ),
    );
  }
}

class _EntryDetailSheet extends StatelessWidget {
  final JournalEntry entry;
  final String title;
  final IconData icon;
  final Color iconColor;

  const _EntryDetailSheet({
    required this.entry,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d - h:mm a');
    final isAiJournal = entry.tags.contains('ai-journal');
    final isCheckIn = entry.tags.contains('check-in');
    final isSavoring = entry.tags.contains('savoring');

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF14161B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(entry.dateTime),
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAiJournal || isCheckIn) ...[
                      if (entry.moodLabel != null && entry.moodLabel!.isNotEmpty) ...[
                        _DetailSectionTitle('Mood', color: const Color(0xFFB4C6FC)),
                        const SizedBox(height: 8),
                        Text(
                          entry.moodLabel!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (isAiJournal) ...[
                      if (entry.detectedDistortionLabel != null && entry.detectedDistortionLabel!.isNotEmpty) ...[
                        _DetailSectionTitle('Pattern', color: const Color(0xFF8A6BFF)),
                        const SizedBox(height: 8),
                        Text(
                          entry.detectedDistortionLabel!,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (entry.reframe != null && entry.reframe!.isNotEmpty) ...[
                        _DetailSectionTitle('Reframe', color: const Color(0xFF8A6BFF)),
                        const SizedBox(height: 8),
                        Text(
                          entry.reframe!,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (isSavoring && entry.eventSummary != null) ...[
                        _DetailSectionTitle('Contextual factor', color: const Color(0xFFE4A4C1)),
                      const SizedBox(height: 8),
                      Text(
                        entry.eventSummary!,
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _DetailSectionTitle('Entry', color: iconColor),
                    const SizedBox(height: 8),
                    Text(
                      entry.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  const _DetailSectionTitle(this.title, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
