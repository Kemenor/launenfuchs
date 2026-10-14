import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import 'tile_catalog.dart';

/// Edit tiles (the checkfuchs pattern, DESIGN_SYSTEM §2.3): one switch row
/// per tile in display order; drag the handle to reorder; switched-off tiles
/// sink below the switched-on ones.
class EditTilesScreen extends ConsumerWidget {
  const EditTilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tiles = effectiveTiles(ref.watch(settingsProvider).statsTiles);
    final ctrl = ref.read(settingsProvider.notifier);

    void store(List<(StatsTile, bool)> list) {
      final on = [
        for (final t in list)
          if (t.$2) t,
      ];
      final off = [
        for (final t in list)
          if (!t.$2) t,
      ];
      ctrl.setStatsTiles([
        for (final (t, v) in [...on, ...off]) (t.id, v),
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editTiles)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
              l10n.editTilesHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 16,
              ),
              itemCount: tiles.length,
              onReorderItem: (from, to) {
                final list = [...tiles];
                list.insert(to, list.removeAt(from));
                store(list);
              },
              itemBuilder: (context, i) {
                final (t, on) = tiles[i];
                return Material(
                  key: ValueKey(t.id),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: i,
                      child: const Icon(Symbols.drag_indicator_rounded),
                    ),
                    title: Text(
                      t.title(l10n),
                      style: on
                          ? null
                          : TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                    trailing: Switch(
                      value: on,
                      onChanged: (v) {
                        final list = [...tiles];
                        list[i] = (t, v);
                        store(list);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
