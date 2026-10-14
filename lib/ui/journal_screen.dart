import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/journal.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'entry_row.dart';
import 'entry_sheet.dart';
import 'month_calendar.dart';

/// The Journal tab (DESIGN_SYSTEM §2.1): a month calendar of mood faces over
/// that month's entries, newest first; `Log today` / `Edit today` FAB. An
/// empty journal opens with the first-run card.
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  /// The shown month (year, month); null = the logical today's month.
  (int, int)? _month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final today = logicalToday(ref);
    final journal = ref.watch(journalProvider).value ?? Journal.empty;
    final (year, month) = _month ?? (today.year, today.month);
    final isCurrent = year == today.year && month == today.month;
    final monthTitle = DateFormat.yMMMM(locale).format(DateTime(year, month));
    final monthName = DateFormat.MMMM(locale).format(DateTime(year, month));
    final entries = [
      for (final e in journal.entries)
        if (e.day.year == year && e.day.month == month) e,
    ];
    final loggedToday = journal.entryOn(today) != null;

    void shift(int by) {
      final d = DateTime(year, month + by);
      setState(() => _month = (d.year, d.month));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.previousMonth,
          icon: const Icon(Symbols.chevron_left_rounded),
          onPressed: () => shift(-1),
        ),
        title: Text(monthTitle),
        actions: [
          IconButton(
            tooltip: l10n.nextMonth,
            icon: const Icon(Symbols.chevron_right_rounded),
            onPressed: isCurrent ? null : () => shift(1),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'journal-fab',
        icon: Icon(loggedToday ? Symbols.edit_rounded : Symbols.add_rounded),
        label: Text(loggedToday ? l10n.editToday : l10n.logToday),
        onPressed: () => showEntrySheet(context, day: today),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 96 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (journal.isEmpty) const FirstRunCard(),
          Card(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: MonthCalendar(
                year: year,
                month: month,
                journal: journal,
                today: today,
                onTapDay: (d) => showEntrySheet(context, day: d),
              ),
            ),
          ),
          if (entries.isEmpty && !journal.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.monthEmpty(monthName),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (entries.isNotEmpty)
            Card(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const Divider(height: 1, indent: 66),
                    EntryRow(
                      entry: entries[i],
                      journal: journal,
                      onTap: () => showEntrySheet(context, day: entries[i].day),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown while the journal is empty: "How was today?" with the five faces —
/// a tap opens today's entry with that mood picked.
class FirstRunCard extends ConsumerWidget {
  const FirstRunCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = logicalToday(ref);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: theme.colorScheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.journalEmptyTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.journalEmptyBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            MoodPicker(
              value: null,
              onChanged: (m) =>
                  showEntrySheet(context, day: today, initialMood: m),
            ),
          ],
        ),
      ),
    );
  }
}
