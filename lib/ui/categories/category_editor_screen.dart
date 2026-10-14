import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/category.dart';
import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../mood_style.dart';
import '../option_icons.dart';
import 'dialogs.dart';

/// The category editor (DESIGN_SYSTEM §2.4): name + icon, one per day,
/// show as, tracked since, options (drag to reorder; menu: make default ·
/// rename & icon · merge into… · remove…), fill empty days…, remove category….
class CategoryEditorScreen extends ConsumerWidget {
  const CategoryEditorScreen({super.key, required this.categoryId});

  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final journal = ref.watch(journalProvider).value ?? Journal.empty;
    final repo = ref.read(categoryRepositoryProvider);
    Category? c;
    for (final x in journal.categories) {
      if (x.id == categoryId) c = x;
    }
    if (c == null) return Scaffold(appBar: AppBar());
    final cat = c;
    final one = cat.mode == CategoryMode.one;
    final visible = cat.visibleOptions;
    final hiddenOptions = [
      for (final o in cat.options)
        if (o.hidden) o,
    ];
    final since = cat.spans.isEmpty
        ? null
        : cat.spans.map((s) => s.from).reduce((a, b) => a.isBefore(b) ? a : b);

    Future<void> rename() async {
      final r = await showNameIconDialog(
        context,
        title: l10n.renameAndIcon,
        name: cat.name,
        icon: cat.icon,
      );
      if (r != null) await repo.updateCategory(cat.id, name: r.$1, icon: r.$2);
    }

    Future<void> removeCategory() async {
      final n = await repo.categoryDayCount(cat.id);
      if (!context.mounted) return;
      final choice = await showRemoveDialog(
        context,
        name: cat.name,
        dayCount: n,
        isCategory: true,
      );
      if (choice == RemoveChoice.hide) {
        await repo.hideCategory(cat.id, logicalToday(ref));
        if (context.mounted) Navigator.of(context).pop();
      } else if (choice == RemoveChoice.delete) {
        await repo.deleteCategory(cat.id);
        if (context.mounted) Navigator.of(context).pop();
      }
    }

    Future<void> fill() async {
      final n = await repo.emptyDayCount(cat.id);
      if (!context.mounted) return;
      if (n == 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.fillEmptyNone)));
        return;
      }
      final target = await showDialog<int>(
        context: context,
        builder: (c) => _FillDialog(category: cat, count: n),
      );
      if (target != null) await repo.fillEmptyDays(cat.id, target);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        actions: [
          IconButton(
            tooltip: l10n.renameAndIcon,
            icon: const Icon(Symbols.edit_rounded),
            onPressed: rename,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          ListTile(
            leading: Icon(
              optionIcon(cat.icon),
              color: theme.colorScheme.primary,
            ),
            title: Text(cat.name, style: theme.textTheme.titleMedium),
            onTap: rename,
          ),
          SwitchListTile(
            title: Text(l10n.pickOnePerDay),
            subtitle: Text(l10n.pickOnePerDayHint),
            value: one,
            onChanged: (v) => repo.updateCategory(
              cat.id,
              mode: v ? CategoryMode.one : CategoryMode.any,
            ),
          ),
          if (one)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.showAs, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SegmentedButton<CategoryDisplay>(
                    showSelectedIcon: false,
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
                    selected: {cat.display},
                    onSelectionChanged: (s) =>
                        repo.updateCategory(cat.id, display: s.first),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.showAsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ListTile(
            leading: const Icon(Symbols.event_rounded),
            title: Text(l10n.trackedSince),
            subtitle: Text(l10n.importTrackedSinceHint),
            trailing: Text(
              since == null ? '–' : DateFormat.yMMMd(locale).format(since.noon),
              style: theme.textTheme.titleSmall,
            ),
            onTap: () async {
              final today = logicalToday(ref);
              final picked = await showDatePicker(
                context: context,
                initialDate: (since ?? today).noon,
                firstDate: Day(today.year - 20, 1, 1).noon,
                lastDate: today.noon,
              );
              if (picked != null) {
                await repo.setTrackedSince(cat.id, Day.of(picked));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              l10n.optionsSection.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            onReorderItem: (from, to) {
              final ids = [for (final o in visible) o.id];
              ids.insert(to, ids.removeAt(from));
              repo.reorderOptions([
                ...ids,
                for (final o in hiddenOptions) o.id,
              ]);
            },
            children: [
              for (var i = 0; i < visible.length; i++)
                Material(
                  key: ValueKey(visible[i].id),
                  child: _OptionRow(
                    category: cat,
                    option: visible[i],
                    index: i,
                    journal: journal,
                  ),
                ),
            ],
          ),
          for (final o in hiddenOptions)
            ListTile(
              leading: Icon(
                optionIcon(o.icon),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                o.name,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              subtitle: Text(l10n.hiddenSection),
              trailing: TextButton(
                onPressed: () => repo.setOptionHidden(o.id, false),
                child: Text(l10n.bringBack),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton.icon(
                icon: const Icon(Symbols.add_rounded),
                label: Text(l10n.newOption),
                onPressed: () async {
                  final r = await showNameIconDialog(
                    context,
                    title: l10n.newOption,
                    icon: cat.icon,
                  );
                  if (r != null) {
                    await repo.addOption(cat.id, name: r.$1, icon: r.$2);
                  }
                },
              ),
            ),
          ),
          if (one) ...[
            ListTile(
              leading: const Icon(Symbols.format_color_fill_rounded),
              title: Text(l10n.fillEmptyDays),
              subtitle: Text(l10n.fillEmptyDaysHint),
              onTap: fill,
            ),
          ],
          ListTile(
            leading: Icon(
              Symbols.remove_circle_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(l10n.removeCategory),
            onTap: removeCategory,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends ConsumerWidget {
  const _OptionRow({
    required this.category,
    required this.option,
    required this.index,
    required this.journal,
  });

  final Category category;
  final OptionItem option;
  final int index;
  final Journal journal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ref.read(categoryRepositoryProvider);
    final isDefault = category.defaultOptionId == option.id;
    final neutral = MoodStyle.neutral(theme.brightness);

    Future<void> remove() async {
      final n = await repo.optionDayCount(option.id);
      if (!context.mounted) return;
      if (n == 0) {
        await repo.deleteOption(option.id);
        return;
      }
      final choice = await showRemoveDialog(
        context,
        name: option.name,
        dayCount: n,
        isCategory: false,
      );
      if (choice == RemoveChoice.hide) {
        await repo.setOptionHidden(option.id, true);
      }
      if (choice == RemoveChoice.delete) await repo.deleteOption(option.id);
    }

    Future<void> merge() async {
      final target = await showDialog<int>(
        context: context,
        builder: (_) => _MergeDialog(journal: journal, from: option),
      );
      if (target != null) await repo.mergeOption(option.id, target);
    }

    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Symbols.drag_indicator_rounded),
      ),
      title: Row(
        children: [
          Icon(
            optionIcon(option.icon),
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Flexible(child: Text(option.name, overflow: TextOverflow.ellipsis)),
          if (isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: neutral.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                l10n.defaultTag.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: neutral,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Symbols.more_vert_rounded),
        onSelected: (v) async {
          switch (v) {
            case 'default':
              await repo.setDefault(category.id, isDefault ? null : option.id);
            case 'rename':
              final r = await showNameIconDialog(
                context,
                title: l10n.renameAndIcon,
                name: option.name,
                icon: option.icon,
              );
              if (r != null) {
                await repo.updateOption(option.id, name: r.$1, icon: r.$2);
              }
            case 'merge':
              await merge();
            case 'remove':
              await remove();
          }
        },
        itemBuilder: (_) => [
          if (category.mode == CategoryMode.one)
            PopupMenuItem(
              value: 'default',
              child: Text(isDefault ? l10n.clearDefault : l10n.makeDefault),
            ),
          PopupMenuItem(value: 'rename', child: Text(l10n.renameAndIcon)),
          PopupMenuItem(value: 'merge', child: Text(l10n.mergeInto)),
          PopupMenuItem(value: 'remove', child: Text(l10n.remove)),
        ],
      ),
    );
  }
}

/// Merge target picker + the consequence in words + collisions + red Merge.
class _MergeDialog extends ConsumerStatefulWidget {
  const _MergeDialog({required this.journal, required this.from});
  final Journal journal;
  final OptionItem from;

  @override
  ConsumerState<_MergeDialog> createState() => _MergeDialogState();
}

class _MergeDialogState extends ConsumerState<_MergeDialog> {
  OptionItem? _to;
  int _days = 0;
  int _collisions = 0;

  @override
  void initState() {
    super.initState();
    ref.read(categoryRepositoryProvider).optionDayCount(widget.from.id).then((
      n,
    ) {
      if (mounted) setState(() => _days = n);
    });
  }

  Future<void> _pick(OptionItem o) async {
    final c = await ref
        .read(categoryRepositoryProvider)
        .mergeCollisions(widget.from.id, o.id);
    if (mounted) {
      setState(() {
        _to = o;
        _collisions = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Text(l10n.mergeTitle(widget.from.name)),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in widget.journal.categories)
                if (c.options.any(
                  (o) => o.id != widget.from.id && !o.hidden,
                )) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(c.name, style: theme.textTheme.labelLarge),
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final o in c.options)
                        if (o.id != widget.from.id && !o.hidden)
                          ChoiceChip(
                            avatar: Icon(optionIcon(o.icon), size: 16),
                            label: Text(o.name),
                            selected: _to?.id == o.id,
                            onSelected: (_) => _pick(o),
                          ),
                    ],
                  ),
                ],
              if (_to != null) ...[
                const SizedBox(height: 16),
                Text(l10n.mergeBody(_days, widget.from.name, _to!.name)),
                if (_collisions > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.importCollisions(_collisions),
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  l10n.cantUndo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _to == null ? null : () => Navigator.pop(context, _to!.id),
          child: Text(l10n.mergeAction),
        ),
      ],
    );
  }
}

class _FillDialog extends StatefulWidget {
  const _FillDialog({required this.category, required this.count});
  final Category category;
  final int count;

  @override
  State<_FillDialog> createState() => _FillDialogState();
}

class _FillDialogState extends State<_FillDialog> {
  late int? _to =
      widget.category.defaultOptionId ??
      (widget.category.visibleOptions.isEmpty
          ? null
          : widget.category.visibleOptions.first.id);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.fillEmptyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.fillEmptyBody(widget.count, widget.category.name)),
          const SizedBox(height: 10),
          DropdownButtonFormField<int>(
            initialValue: _to,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final o in widget.category.visibleOptions)
                DropdownMenuItem(value: o.id, child: Text(o.name)),
            ],
            onChanged: (v) => setState(() => _to = v),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.fillEmptyNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _to == null ? null : () => Navigator.pop(context, _to),
          child: Text(l10n.fillEmptyAction(widget.count)),
        ),
      ],
    );
  }
}
