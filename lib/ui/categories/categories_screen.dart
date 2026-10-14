import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/category.dart';
import '../../domain/journal.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../option_icons.dart';
import 'category_editor_screen.dart';
import 'dialogs.dart';

/// Settings › Categories & options (DESIGN_SYSTEM §2.4): drag to reorder,
/// tap to edit, hidden categories at the bottom with Bring back.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final journal = ref.watch(journalProvider).value ?? Journal.empty;
    final repo = ref.read(categoryRepositoryProvider);
    final visible = [
      for (final c in journal.categories)
        if (!c.hidden) c,
    ];
    final hidden = [
      for (final c in journal.categories)
        if (c.hidden) c,
    ];

    void edit(Category c) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryEditorScreen(categoryId: c.id),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'categories-fab',
        icon: const Icon(Symbols.add_rounded),
        label: Text(l10n.newCategory),
        onPressed: () async {
          final r = await showNameIconDialog(context, title: l10n.newCategory);
          if (r == null) return;
          final id = await repo.createCategory(
            name: r.$1,
            icon: r.$2,
            mode: CategoryMode.any,
            today: logicalToday(ref),
            now: ref.read(clockProvider).now(),
          );
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CategoryEditorScreen(categoryId: id),
              ),
            );
          }
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverReorderableList(
            itemCount: visible.length,
            onReorderItem: (from, to) {
              final ids = [for (final c in visible) c.id];
              ids.insert(to, ids.removeAt(from));
              repo.reorderCategories([...ids, for (final c in hidden) c.id]);
            },
            itemBuilder: (context, i) {
              final c = visible[i];
              return Material(
                key: ValueKey(c.id),
                child: ListTile(
                  leading: Icon(
                    optionIcon(c.icon),
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(c.name),
                  subtitle: Text(
                    l10n.categoryRowSubtitle(
                      c.mode == CategoryMode.one
                          ? l10n.importModeOne
                          : l10n.importModeAny,
                      c.visibleOptions.length,
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Symbols.drag_indicator_rounded),
                  ),
                  onTap: () => edit(c),
                ),
              );
            },
          ),
          if (hidden.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
                child: Text(
                  l10n.hiddenSection.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SliverList.list(
              children: [
                for (final c in hidden)
                  ListTile(
                    leading: Icon(
                      optionIcon(c.icon),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      c.name,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: c.spans.isEmpty || c.spans.last.to == null
                        ? null
                        : Text(
                            l10n.hiddenSpanSubtitle(
                              DateFormat.yMMMd(
                                locale,
                              ).format(c.spans.last.to!.noon),
                            ),
                          ),
                    trailing: TextButton(
                      onPressed: () =>
                          repo.bringBackCategory(c.id, logicalToday(ref)),
                      child: Text(l10n.bringBack),
                    ),
                    onTap: () => edit(c),
                  ),
              ],
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(height: 96 + MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
