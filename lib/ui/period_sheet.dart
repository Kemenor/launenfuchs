import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/day.dart';
import '../domain/journal.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';

/// Create or edit a period (design-concept §2.5, DESIGN_SYSTEM §2.1/§2.3).
/// [start]/[end] prefill a new one (the calendar's range selection).
Future<void> showPeriodSheet(
  BuildContext context, {
  Period? period,
  Day? start,
  Day? end,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => PeriodSheet(period: period, start: start, end: end),
);

class PeriodSheet extends ConsumerStatefulWidget {
  const PeriodSheet({super.key, this.period, this.start, this.end});

  final Period? period;
  final Day? start;
  final Day? end;

  @override
  ConsumerState<PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends ConsumerState<PeriodSheet> {
  late final TextEditingController _name;
  late Day _start;
  Day? _end;
  late bool _ongoing;
  late bool _away;

  @override
  void initState() {
    super.initState();
    final p = widget.period;
    _name = TextEditingController(text: p?.name ?? '');
    final today = logicalToday(ref);
    _start = p?.start ?? widget.start ?? today;
    _end = p?.end ?? widget.end;
    // A fresh range that reaches today is most likely still going on.
    _ongoing = p == null ? (_end == null || _end == today) : p.end == null;
    if (_ongoing && p == null) _end = null;
    _away = p?.away ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<Day?> _pick(Day initial, {Day? first}) async {
    final today = logicalToday(ref);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.noon,
      firstDate: (first ?? Day(today.year - 20, 1, 1)).noon,
      lastDate: Day(today.year + 1, 12, 31).noon,
    );
    return picked == null ? null : Day.of(picked);
  }

  Future<void> _save() async {
    await ref
        .read(journalRepositoryProvider)
        .savePeriod(
          id: widget.period?.id,
          name: _name.text.trim(),
          start: _start,
          end: _ongoing ? null : (_end ?? _start),
          away: _away,
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.periodDelete),
        content: Text(l10n.periodDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(journalRepositoryProvider).deletePeriod(widget.period!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    String date(Day d) => DateFormat.yMMMEd(locale).format(d.noon);
    final valid =
        _name.text.trim().isNotEmpty &&
        (_ongoing || _end == null || !_end!.isBefore(_start));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.period == null ? l10n.periodNew : l10n.periodEdit,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              autofocus: widget.period == null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.importName,
                hintText: l10n.periodNameHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Symbols.event_rounded),
              title: Text(l10n.periodStart),
              trailing: Text(date(_start), style: theme.textTheme.titleSmall),
              onTap: () async {
                final d = await _pick(_start);
                if (d != null) setState(() => _start = d);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.periodOngoing),
              subtitle: Text(l10n.periodOngoingHint),
              value: _ongoing,
              onChanged: (v) => setState(() => _ongoing = v),
            ),
            if (!_ongoing)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Symbols.event_available_rounded),
                title: Text(l10n.periodEnd),
                trailing: Text(
                  date(_end ?? _start),
                  style: theme.textTheme.titleSmall,
                ),
                onTap: () async {
                  final d = await _pick(_end ?? _start, first: _start);
                  if (d != null) setState(() => _end = d);
                },
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.periodAway),
              subtitle: Text(l10n.periodAwayHint),
              value: _away,
              onChanged: (v) => setState(() => _away = v),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: valid ? _save : null,
              child: Text(l10n.periodSave),
            ),
            if (widget.period != null)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                icon: const Icon(Symbols.delete_rounded),
                label: Text(l10n.periodDelete),
                onPressed: _delete,
              ),
          ],
        ),
      ),
    );
  }
}
