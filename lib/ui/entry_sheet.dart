import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/category.dart';
import '../domain/day.dart';
import '../domain/entry_draft.dart';
import '../domain/journal.dart';
import '../domain/mood.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'mood_style.dart';
import 'option_icons.dart';
import 'step_slider.dart';

/// Opens the entry sheet (design-concept §3, DESIGN_SYSTEM §2.2) for [day]
/// (default: the logical today). [initialMood] pre-picks a face, e.g. from
/// the first-run mood row.
Future<void> showEntrySheet(
  BuildContext context, {
  Day? day,
  Mood? initialMood,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) => EntrySheet(day: day, initialMood: initialMood),
);

class EntrySheet extends ConsumerStatefulWidget {
  const EntrySheet({super.key, this.day, this.initialMood});

  final Day? day;
  final Mood? initialMood;

  @override
  ConsumerState<EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<EntrySheet> {
  EntryDraft? _draft;
  late Day _today;
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _load(Journal journal, Day day) {
    final d = EntryDraft.forDay(journal, day);
    if (d.isNew && widget.initialMood != null && _draft == null) {
      d.mood = widget.initialMood;
    }
    _draft = d;
    _note.text = d.note;
  }

  Future<void> _save() async {
    final draft = _draft!;
    draft.note = _note.text;
    await ref
        .read(journalRepositoryProvider)
        .saveEntry(draft, ref.read(clockProvider).now());
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete(String dateLabel) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l10n.deleteEntryTitle),
        content: Text(l10n.deleteEntryBody(dateLabel)),
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
    await ref.read(journalRepositoryProvider).deleteEntry(_draft!.day);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final async = ref.watch(journalProvider);
    if (!async.hasValue) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final journal = async.value!;
    _today = logicalToday(ref);
    if (_draft == null) _load(journal, widget.day ?? _today);
    final draft = _draft!;
    final day = draft.day;

    final dateText = DateFormat.MMMEd(locale).format(day.noon);
    final relative = day == _today
        ? l10n.dayToday
        : day == _today.addDays(-1)
        ? l10n.dayYesterday
        : null;
    final now = ref.read(clockProvider).now();
    final lateNight = draft.isNew && day == _today && Day.of(now) != _today;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: ‹ day ›  ✕
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.previousDay,
                  icon: const Icon(Symbols.chevron_left_rounded),
                  onPressed: () =>
                      setState(() => _load(journal, day.addDays(-1))),
                ),
                Expanded(
                  child: Text(
                    relative == null
                        ? dateText
                        : l10n.dayHeader(relative, dateText),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.nextDay,
                  icon: const Icon(Symbols.chevron_right_rounded),
                  onPressed: day.isBefore(_today)
                      ? () => setState(() => _load(journal, day.addDays(1)))
                      : null,
                ),
                IconButton(
                  tooltip: l10n.close,
                  icon: const Icon(Symbols.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (lateNight)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
              child: Text(
                l10n.lateNightHint(
                  MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(now),
                    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                      context,
                    ),
                  ),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MoodPicker(
                    value: draft.mood,
                    onChanged: (m) => setState(() => draft.mood = m),
                  ),
                  const SizedBox(height: 16),
                  for (final c in journal.visibleCategories)
                    _CategoryBlock(
                      category: c,
                      draft: draft,
                      onChanged: () => setState(() {}),
                    ),
                  TextField(
                    controller: _note,
                    minLines: 1,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: l10n.notePlaceholder,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (!draft.isNew)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        icon: const Icon(Symbols.delete_rounded),
                        label: Text(l10n.deleteEntry),
                        onPressed: () => _delete(dateText),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: draft.canSave ? _save : null,
                  child: Text(draft.canSave ? l10n.save : l10n.saveNeedsMood),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Five faces, one tap (§3.1). Selection = a ring + 1.15× scale; the others
/// dim — never an indigo fill, since indigo is a mood here (DESIGN_SYSTEM §1).
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.value, required this.onChanged});

  final Mood? value;
  final ValueChanged<Mood> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final m in Mood.values)
          Expanded(
            child: Semantics(
              button: true,
              selected: value == m,
              child: InkResponse(
                onTap: () => onChanged(m),
                radius: 32,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      AnimatedScale(
                        scale: value == m ? 1.15 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: AnimatedOpacity(
                          opacity: value == null || value == m ? 1 : 0.6,
                          duration: const Duration(milliseconds: 120),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: value == m
                                    ? theme.colorScheme.onSurface
                                    : Colors.transparent,
                              ),
                            ),
                            child: ExcludeSemantics(
                              child: MoodFace(m, size: 44),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        MoodStyle.label(m, l10n),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: value == m ? FontWeight.w700 : null,
                          color: value == m
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.category,
    required this.draft,
    required this.onChanged,
  });

  final Category category;
  final EntryDraft draft;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = category;
    final options = c.visibleOptions;
    if (options.isEmpty) return const SizedBox.shrink();
    final pending = draft.isPending(c);
    final neutral = MoodStyle.neutral(theme.brightness);
    final selected = draft.selectedIn(c);

    Widget header({String? value}) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(c.name, style: theme.textTheme.titleSmall),
          const SizedBox(width: 8),
          Text(
            (c.mode == CategoryMode.one ? l10n.modeOne : l10n.modeAny)
                .toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          if (value != null)
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: pending || value == '–'
                    ? (value == '–'
                          ? theme.colorScheme.onSurfaceVariant
                          : neutral)
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );

    if (c.showsSlider) {
      final index = options.indexWhere((o) => selected.contains(o.id));
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header(
              value: index < 0
                  ? '–'
                  : pending
                  ? '${options[index].name} · ${l10n.defaultTag}'
                  : options[index].name,
            ),
            StepSlider(
              labels: [for (final o in options) o.name],
              selected: index < 0 ? null : index,
              pending: pending,
              onChanged: (i) {
                draft.setOne(c, options[i].id);
                onChanged();
              },
              onClear: () {
                draft.clear(c);
                onChanged();
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                _OptionChip(
                  option: o,
                  selected: selected.contains(o.id),
                  pending: pending && selected.contains(o.id),
                  onTap: () {
                    draft.tap(c, o.id);
                    onChanged();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// An option chip: orange tint when picked; a pending default is neutral with
/// a small DEFAULT tag (DESIGN_SYSTEM §2.2).
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.option,
    required this.selected,
    required this.pending,
    required this.onTap,
  });

  final OptionItem option;
  final bool selected;
  final bool pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final neutral = MoodStyle.neutral(theme.brightness);
    final accent = pending ? neutral : scheme.primary;
    final bg = selected
        ? accent.withValues(alpha: pending ? 0.18 : 0.15)
        : Colors.transparent;
    final fg = selected && !pending ? scheme.primary : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: bg,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? Colors.transparent : scheme.outlineVariant,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  optionIcon(option.icon),
                  size: 18,
                  color: selected ? accent : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  option.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pending) ...[
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).defaultTag.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: neutral,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
