import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../domain/mood.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'mood_style.dart';

/// Rename the five levels (design-concept §2.1). The value never changes, so
/// stats stay comparable; an empty field means the localised default.
Future<void> showMoodNamesDialog(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final controllers = {
    for (final m in Mood.values.reversed)
      m: TextEditingController(text: MoodStyle.overrides[m] ?? ''),
  };
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l10n.moodNames),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final MapEntry(key: m, value: ctl) in controllers.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      MoodFace(m, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: ctl,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: MoodStyle.defaultLabel(m, l10n),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            for (final ctl in controllers.values) {
              ctl.clear();
            }
          },
          child: Text(l10n.moodNamesReset),
        ),
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  if (ok == true) {
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      await db.delete(db.moodLabels).go();
      for (final MapEntry(key: m, value: ctl) in controllers.entries) {
        final t = ctl.text.trim();
        if (t.isNotEmpty) {
          await db
              .into(db.moodLabels)
              .insert(
                MoodLabelsCompanion.insert(
                  value: Value(m.value),
                  label: Value(t),
                ),
              );
        }
      }
    });
  }
  for (final ctl in controllers.values) {
    ctl.dispose();
  }
}
