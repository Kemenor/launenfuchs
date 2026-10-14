import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/backup/backup_service.dart' show pickDocument;
import '../data/import/daylio.dart';
import '../data/import/import_writer.dart';
import '../domain/category.dart';
import '../domain/daylio_backup.dart';
import '../domain/daylio_plan.dart';
import '../domain/day.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'option_icons.dart';

/// The Daylio import (design-concept §7.2, DESIGN_SYSTEM §2.5): a full-screen
/// stepper — File · Categories · Options · Defaults · Review. Nothing is
/// written before the final button; the Daylio file is never touched.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ImportScreen()));

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  int _step = 0;
  DaylioAnalysis? _analysis;
  DaylioMapping? _mapping;
  bool _repeat = false;
  String? _error;
  bool _busy = false;

  ImportPlan? get _plan => _analysis == null || _mapping == null
      ? null
      : planImport(_analysis!, _mapping!);

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    try {
      final path = await pickDocument();
      if (path == null) return;
      final backup = parseDaylioBackup(await File(path).readAsBytes());
      final saved = await loadSavedMapping(ref.read(databaseProvider));
      final analysis = DaylioAnalysis.of(backup);
      final mapping = analysis.suggestedMapping(saved: saved);
      for (final g in analysis.groups) {
        if (g.id == ungroupedId) mapping.groups[g.id]!.name = l10n.importOther;
      }
      setState(() {
        _analysis = analysis;
        _mapping = mapping;
        _repeat = saved.groups.isNotEmpty || saved.tags.isNotEmpty;
      });
    } on DaylioFormatException {
      setState(() => _error = l10n.importNotDaylio);
    } catch (e) {
      setState(() => _error = l10n.importReadFailed('$e'));
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final plan = _plan!;
    final journal = await ref.read(journalRepositoryProvider).loadJournal();
    if (!mounted) return;
    if (!journal.isEmpty) {
      final scheme = Theme.of(context).colorScheme;
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(l10n.importReplaceTitle),
          content: Text(l10n.importWillReplace),
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
              child: Text(l10n.importReplaceAction),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _busy = true);
    try {
      await writeImport(
        ref.read(databaseProvider),
        plan,
        now: ref.read(clockProvider).now(),
        lastDay: _analysis!.lastDay ?? Day.of(ref.read(clockProvider).now()),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importDone(plan.entries.length))),
      );
    } catch (e) {
      setState(() {
        _busy = false;
        _error = l10n.importReadFailed('$e');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = [
      l10n.importStepFile,
      l10n.importStepCategories,
      l10n.importStepOptions,
      l10n.importStepDefaults,
      l10n.importStepReview,
    ];
    final last = _step == steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.close,
          icon: const Icon(Symbols.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l10n.importTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: _StepBar(steps: steps, current: _step),
        ),
      ),
      body: switch (_step) {
        0 => _FileStep(
          analysis: _analysis,
          repeat: _repeat,
          error: _error,
          onPick: _pick,
        ),
        1 => _CategoriesStep(
          analysis: _analysis!,
          mapping: _mapping!,
          onChanged: () => setState(() {}),
        ),
        2 => _OptionsStep(
          analysis: _analysis!,
          mapping: _mapping!,
          onChanged: () => setState(() {}),
        ),
        3 => _DefaultsStep(
          analysis: _analysis!,
          mapping: _mapping!,
          plan: _plan!,
          onChanged: () => setState(() {}),
        ),
        _ => _ReviewStep(analysis: _analysis!, plan: _plan!, error: _error),
      },
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              if (_step > 0)
                TextButton(
                  onPressed: _busy ? null : () => setState(() => _step--),
                  child: Text(l10n.back),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _analysis == null || _busy
                    ? null
                    : last
                    ? _import
                    : () => setState(() => _step++),
                child: Text(
                  last ? l10n.importButton(_plan!.entries.length) : l10n.next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.current});
  final List<String> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: 3,
                      color: i < current
                          ? scheme.primary.withValues(alpha: 0.45)
                          : i == current
                          ? scheme.primary
                          : scheme.outlineVariant,
                    ),
                  ),
                ),
                child: Text(
                  steps[i].toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: i == current
                        ? scheme.primary
                        : i < current
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- shared bits -------------------------------------------------------------

Widget _section(BuildContext context, String title) => Padding(
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
  child: Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
);

class _Info extends StatelessWidget {
  const _Info(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const amber = Color(0xFFE0A33B);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.info_rounded, size: 18, color: amber),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

/// Keep · Merge · Drop.
class _ActionPicker extends StatelessWidget {
  const _ActionPicker({
    required this.value,
    required this.onChanged,
    this.allowMerge = true,
  });

  final MapAction value;
  final ValueChanged<MapAction> onChanged;
  final bool allowMerge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<MapAction>(
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      segments: [
        ButtonSegment(value: MapAction.keep, label: Text(l10n.importKeep)),
        if (allowMerge)
          ButtonSegment(value: MapAction.merge, label: Text(l10n.importMerge)),
        ButtonSegment(value: MapAction.drop, label: Text(l10n.importDrop)),
      ],
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.struck = false,
  });
  final String initial;
  final ValueChanged<String> onChanged;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      initialValue: initial,
      enabled: !struck,
      onChanged: onChanged,
      style: theme.textTheme.titleSmall?.copyWith(
        decoration: struck ? TextDecoration.lineThrough : null,
        color: struck ? const Color(0xFFA8988C) : null,
      ),
      decoration: InputDecoration(
        isDense: true,
        labelText: AppLocalizations.of(context).importName,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

// --- steps -------------------------------------------------------------------

class _FileStep extends StatelessWidget {
  const _FileStep({
    required this.analysis,
    required this.repeat,
    required this.error,
    required this.onPick,
  });

  final DaylioAnalysis? analysis;
  final bool repeat;
  final String? error;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final a = analysis;
    String date(Day? d) =>
        d == null ? '–' : DateFormat.yMMMd(locale).format(d.noon);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l10n.importPickBody, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonalIcon(
            icon: const Icon(Symbols.upload_file_rounded),
            label: Text(l10n.importPickButton),
            onPressed: onPick,
          ),
        ),
        if (error != null) _Info(error!),
        if (a != null) ...[
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                children: [
                  _kv(
                    context,
                    l10n.importDays,
                    '${a.days.length} · ${date(a.firstDay)} – ${date(a.lastDay)}',
                  ),
                  _kv(context, l10n.importNotes, '${a.noteCount}'),
                  _kv(context, l10n.importPhotos, '${a.backup.photoCount}'),
                  if (a.mergedDayCount > 0)
                    _kv(context, l10n.importMergedDays, '${a.mergedDayCount}'),
                ],
              ),
            ),
          ),
          if (repeat) _Info(l10n.importRepeatHint),
        ],
      ],
    );
  }
}

Widget _kv(BuildContext context, String k, String v) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    children: [
      Expanded(child: Text(k)),
      Text(
        v,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    ],
  ),
);

class _CategoriesStep extends StatelessWidget {
  const _CategoriesStep({
    required this.analysis,
    required this.mapping,
    required this.onChanged,
  });

  final DaylioAnalysis analysis;
  final DaylioMapping mapping;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        for (final g in analysis.groups)
          Builder(
            builder: (context) {
              final c = mapping.groups[g.id]!;
              final stats = analysis.groupStats[g.id];
              final others = [
                for (final o in analysis.groups)
                  if (o.id != g.id &&
                      mapping.groups[o.id]!.action != MapAction.drop)
                    o,
              ];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            optionIcon(c.icon),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _NameField(
                              key: ValueKey('g${g.id}'),
                              initial: c.name,
                              struck: c.action == MapAction.drop,
                              onChanged: (v) => c.name = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          l10n.importUsedOn(stats?.usedDays ?? 0),
                          (stats?.multiDays ?? 0) > 0
                              ? l10n.importTwoOn(stats!.multiDays)
                              : l10n.importNeverTwo,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ActionPicker(
                        value: c.action,
                        allowMerge: others.isNotEmpty,
                        onChanged: (a) {
                          c.action = a;
                          if (a == MapAction.merge) {
                            c.mergeInto ??= others.first.id;
                          }
                          onChanged();
                        },
                      ),
                      if (c.action == MapAction.merge && others.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: DropdownButtonFormField<int>(
                            initialValue: others.any((o) => o.id == c.mergeInto)
                                ? c.mergeInto
                                : others.first.id,
                            decoration: InputDecoration(
                              labelText: l10n.importMergeInto,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              for (final o in others)
                                DropdownMenuItem(
                                  value: o.id,
                                  child: Text(mapping.groups[o.id]!.name),
                                ),
                            ],
                            onChanged: (v) {
                              c.mergeInto = v;
                              onChanged();
                            },
                          ),
                        ),
                      if (c.action == MapAction.keep) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            SegmentedButton<CategoryMode>(
                              showSelectedIcon: false,
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                              segments: [
                                ButtonSegment(
                                  value: CategoryMode.one,
                                  label: Text(l10n.importModeOne),
                                ),
                                ButtonSegment(
                                  value: CategoryMode.any,
                                  label: Text(l10n.importModeAny),
                                ),
                              ],
                              selected: {c.mode},
                              onSelectionChanged: (s) {
                                c.mode = s.first;
                                onChanged();
                              },
                            ),
                            if (c.mode == CategoryMode.one)
                              SegmentedButton<CategoryDisplay>(
                                showSelectedIcon: false,
                                style: const ButtonStyle(
                                  visualDensity: VisualDensity.compact,
                                ),
                                segments: [
                                  ButtonSegment(
                                    value: CategoryDisplay.chips,
                                    label: Text(l10n.importShowChips),
                                  ),
                                  ButtonSegment(
                                    value: CategoryDisplay.slider,
                                    label: Text(l10n.importShowSlider),
                                  ),
                                ],
                                selected: {c.display},
                                onSelectionChanged: (s) {
                                  c.display = s.first;
                                  onChanged();
                                },
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _OptionsStep extends StatelessWidget {
  const _OptionsStep({
    required this.analysis,
    required this.mapping,
    required this.onChanged,
  });

  final DaylioAnalysis analysis;
  final DaylioMapping mapping;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    // Merge targets: tags that stay (kept, in a surviving group).
    final targets = [
      for (final t in analysis.backup.tags)
        if (mapping.tags[t.id]!.action == MapAction.keep &&
            resolveGroup(mapping, t.groupId ?? ungroupedId) != null)
          t,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final g in analysis.groups)
          if (resolveGroup(mapping, g.id) != null) ...[
            _section(context, mapping.groups[g.id]!.name),
            for (final t in analysis.tagsIn(g.id))
              Builder(
                builder: (context) {
                  final c = mapping.tags[t.id]!;
                  final uses = analysis.tagStats[t.id]?.uses ?? 0;
                  final others = [
                    for (final o in targets)
                      if (o.id != t.id) o,
                  ];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                optionIcon(c.icon),
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _NameField(
                                  key: ValueKey('t${t.id}'),
                                  initial: c.name,
                                  struck: c.action == MapAction.drop,
                                  onChanged: (v) => c.name = v,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            uses == 0
                                ? l10n.importNeverUsed
                                : l10n.importUsedOn(uses),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _ActionPicker(
                            value: c.action,
                            allowMerge: others.isNotEmpty,
                            onChanged: (a) {
                              c.action = a;
                              if (a == MapAction.merge) {
                                c.mergeInto ??= others.first.id;
                              }
                              onChanged();
                            },
                          ),
                          if (c.action == MapAction.merge && others.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: DropdownButtonFormField<int>(
                                initialValue:
                                    others.any((o) => o.id == c.mergeInto)
                                    ? c.mergeInto
                                    : others.first.id,
                                decoration: InputDecoration(
                                  labelText: l10n.importMergeInto,
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  for (final o in others)
                                    DropdownMenuItem(
                                      value: o.id,
                                      child: Text(mapping.tags[o.id]!.name),
                                    ),
                                ],
                                onChanged: (v) {
                                  c.mergeInto = v;
                                  onChanged();
                                },
                              ),
                            ),
                          if (c.action == MapAction.drop && uses > 0)
                            _Info(l10n.importDropLoses(uses)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
      ],
    );
  }
}

class _DefaultsStep extends StatelessWidget {
  const _DefaultsStep({
    required this.analysis,
    required this.mapping,
    required this.plan,
    required this.onChanged,
  });

  final DaylioAnalysis analysis;
  final DaylioMapping mapping;
  final ImportPlan plan;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final ones = [
      for (final c in plan.categories)
        if (c.mode == CategoryMode.one) c,
    ];
    if (ones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.importNoOnePerDay),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        for (final c in ones)
          Builder(
            builder: (context) {
              final d = mapping.defaultsFor(c.sourceGroupId);
              final from = c.trackedFrom;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _section(context, c.name),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<int?>(
                            initialValue: d.defaultTagId,
                            decoration: InputDecoration(
                              labelText: l10n.importDefault,
                              isDense: true,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Text(l10n.importNoDefault),
                              ),
                              for (final o in c.options)
                                DropdownMenuItem<int?>(
                                  value: o.sourceTagId,
                                  child: Text(o.name),
                                ),
                            ],
                            onChanged: (v) {
                              d.defaultTagId = v;
                              onChanged();
                            },
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Symbols.event_rounded),
                            title: Text(l10n.importTrackedSince),
                            subtitle: Text(l10n.importTrackedSinceHint),
                            trailing: Text(
                              from == null
                                  ? '–'
                                  : DateFormat.yMMMd(locale).format(from.noon),
                              style: theme.textTheme.titleSmall,
                            ),
                            onTap: () async {
                              final first = analysis.firstDay;
                              final last = analysis.lastDay;
                              if (first == null || last == null) return;
                              final picked = await showDatePicker(
                                context: context,
                                firstDate: first.noon,
                                lastDate: last.noon,
                                initialDate: (from ?? first).noon,
                              );
                              if (picked != null) {
                                d.trackedFrom = Day.of(picked);
                                onChanged();
                              }
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.importEmptyDays(c.emptyDays),
                            style: theme.textTheme.titleSmall,
                          ),
                          if (c.emptyDays > 0) ...[
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int?>(
                              initialValue: d.fillTagId,
                              decoration: InputDecoration(
                                labelText: l10n.importFillWith,
                                isDense: true,
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text(l10n.importLeaveEmpty),
                                ),
                                for (final o in c.options)
                                  DropdownMenuItem<int?>(
                                    value: o.sourceTagId,
                                    child: Text(o.name),
                                  ),
                              ],
                              onChanged: (v) {
                                d.fillTagId = v;
                                onChanged();
                              },
                            ),
                            if (d.fillTagId != null)
                              _Info(l10n.importFilledNote),
                          ],
                          if (c.collisionDays > 0)
                            _Info(l10n.importCollisions(c.collisionDays)),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({required this.analysis, required this.plan, this.error});

  final DaylioAnalysis analysis;
  final ImportPlan plan;
  final String? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final empty = ref.watch(journalProvider).value?.isEmpty ?? true;
    final filled = plan.categories.fold<int>(0, (n, c) => n + c.filledDays);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                _kv(context, l10n.importDays, '${plan.entries.length}'),
                _kv(context, l10n.importNotes, '${analysis.noteCount}'),
                _kv(
                  context,
                  l10n.importReviewCategories,
                  '${plan.categories.length}',
                ),
                _kv(context, l10n.importReviewOptions, '${plan.optionCount}'),
                if (filled > 0)
                  _kv(context, l10n.importReviewFilled, '$filled'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          empty ? l10n.importEmptyJournal : l10n.importWillReplace,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: empty
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.error,
          ),
        ),
        if (error != null) _Info(error!),
      ],
    );
  }
}
