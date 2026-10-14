import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/category.dart';
import '../../domain/daylio_plan.dart';
import '../../domain/day.dart';
import '../db/database.dart';

const _source = 'daylio';

/// Writes an [ImportPlan] (design-concept §7.2 step 5) in ONE transaction:
/// every category, option and entry is replaced; **periods and settings
/// stay** (they are launenfuchs-only). The mapping is saved for the next
/// import (§7.3). A failure anywhere rolls everything back.
Future<void> writeImport(
  AppDatabase db,
  ImportPlan plan, {
  required DateTime now,
  required Day lastDay,
}) => db.transaction(() async {
  await db.delete(db.entryOptions).go();
  await db.delete(db.entries).go();
  // Defaults point at options; clear them before the options go.
  await db
      .update(db.categories)
      .write(const CategoriesCompanion(defaultOptionId: Value(null)));
  await db.delete(db.categoryOptions).go();
  await db.delete(db.categorySpans).go();
  await db.delete(db.categories).go();

  final optionOfTag = <int, int>{};
  var sort = 0;
  for (final c in plan.categories) {
    final cid = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: c.name,
            icon: c.icon,
            mode: c.mode,
            display: Value(c.display),
            sort: Value(sort++),
            createdAt: now,
          ),
        );
    await db
        .into(db.categorySpans)
        .insert(
          CategorySpansCompanion.insert(
            categoryId: cid,
            fromDay: (c.trackedFrom ?? lastDay).key,
          ),
        );
    var osort = 0;
    for (final o in c.options) {
      optionOfTag[o.sourceTagId] = await db
          .into(db.categoryOptions)
          .insert(
            CategoryOptionsCompanion.insert(
              categoryId: cid,
              name: o.name,
              icon: o.icon,
              sort: Value(osort++),
            ),
          );
    }
    final d = c.defaultTagId;
    if (d != null && optionOfTag[d] != null) {
      await (db.update(db.categories)..where((t) => t.id.equals(cid))).write(
        CategoriesCompanion(defaultOptionId: Value(optionOfTag[d])),
      );
    }
  }

  for (final e in plan.entries) {
    final id = await db
        .into(db.entries)
        .insert(
          EntriesCompanion.insert(
            day: e.day.key,
            loggedAt: e.loggedAt,
            mood: e.mood,
            note: Value(e.note),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db.batch((b) {
      b.insertAll(db.entryOptions, [
        for (final t in e.tagIds)
          if (optionOfTag[t] != null)
            EntryOptionsCompanion.insert(
              entryId: id,
              optionId: optionOfTag[t]!,
            ),
      ]);
    });
  }

  await saveMapping(db, plan.mapping);
  await db
      .into(db.appSettings)
      .insert(
        const AppSettingsCompanion(id: Value(1), onboardingDone: Value(true)),
        onConflict: DoUpdate(
          (_) => const AppSettingsCompanion(onboardingDone: Value(true)),
        ),
      );
});

/// Persists [m] (replacing the previous Daylio mapping).
Future<void> saveMapping(AppDatabase db, DaylioMapping m) async {
  await (db.delete(db.importMaps)..where((t) => t.source.equals(_source))).go();
  await db.batch((b) {
    b.insertAll(db.importMaps, [
      for (final MapEntry(key: id, value: g) in m.groups.entries)
        ImportMapsCompanion.insert(
          source: _source,
          kind: 'group',
          sourceId: id,
          action: g.action.name,
          targetId: Value(g.mergeInto),
          choice: Value(
            jsonEncode({
              'name': g.name,
              'icon': g.icon,
              'mode': g.mode.name,
              'display': g.display.name,
            }),
          ),
        ),
      for (final MapEntry(key: id, value: t) in m.tags.entries)
        ImportMapsCompanion.insert(
          source: _source,
          kind: 'tag',
          sourceId: id,
          action: t.action.name,
          targetId: Value(t.mergeInto),
          choice: Value(jsonEncode({'name': t.name, 'icon': t.icon})),
        ),
    ]);
  });
}

/// The mapping saved by the last import, or an empty one.
Future<SavedMapping> loadSavedMapping(AppDatabase db) async {
  final rows = await (db.select(
    db.importMaps,
  )..where((t) => t.source.equals(_source))).get();
  final groups = <int, GroupChoice>{};
  final tags = <int, TagChoice>{};
  for (final r in rows) {
    final action = MapAction.values.asNameMap()[r.action] ?? MapAction.keep;
    final c = r.choice == null
        ? const <String, dynamic>{}
        : jsonDecode(r.choice!) as Map<String, dynamic>;
    if (r.kind == 'group') {
      groups[r.sourceId] = GroupChoice(
        action: action,
        name: c['name'] as String? ?? '',
        icon: c['icon'] as String? ?? 'label',
        mode: CategoryMode.values.asNameMap()[c['mode']] ?? CategoryMode.any,
        display:
            CategoryDisplay.values.asNameMap()[c['display']] ??
            CategoryDisplay.chips,
        mergeInto: r.targetId,
      );
    } else {
      tags[r.sourceId] = TagChoice(
        action: action,
        name: c['name'] as String? ?? '',
        icon: c['icon'] as String? ?? 'label',
        mergeInto: r.targetId,
      );
    }
  }
  return SavedMapping(groups: groups, tags: tags);
}
