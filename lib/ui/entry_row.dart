import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/journal.dart';
import 'mood_style.dart';
import 'option_icons.dart';

/// A journal list row: face · date + time · option icons · first line of
/// the note (DESIGN_SYSTEM §2.1).
class EntryRow extends StatelessWidget {
  const EntryRow({
    super.key,
    required this.entry,
    required this.journal,
    required this.onTap,
  });

  final Entry entry;
  final Journal journal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMEd(locale).format(entry.day.noon);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.loggedAt),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    // Options in category order, then option order.
    final icons = <IconData>[
      for (final c in journal.categories)
        for (final o in c.options)
          if (entry.optionIds.contains(o.id)) optionIcon(o.icon),
    ];
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoodFace(entry.mood, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: date, style: theme.textTheme.titleSmall),
                        TextSpan(
                          text: '  $time',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (icons.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final i in icons)
                            Icon(i, size: 18, color: muted),
                        ],
                      ),
                    ),
                  if (entry.hasNote)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        entry.note!.trim().split('\n').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
