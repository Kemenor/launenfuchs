import 'dart:async';

import 'package:drift/drift.dart';

import '../../domain/category.dart';
import '../../domain/day.dart';
import '../../domain/entry_draft.dart';
import '../../domain/journal.dart' as dom;
import '../../domain/mood.dart';
import '../../domain/starter.dart';
import '../db/database.dart';

/// Journal persistence: loads the whole [dom.Journal] snapshot (small — a few
/// thousand rows after years) and writes entries. The UI watches
/// [watchJournal]; every write re-emits it.
class JournalRepository {
  JournalRepository(this.db);

  final AppDatabase db;

  List<TableInfo> get _tables => [
    db.categories,
    db.categorySpans,
    db.categoryOptions,
    db.entries,
    db.entryOptions,
    db.periods,
    db.moodLabels,
  ];

  /// The journal now, then again after every change to its tables.
  ///
  /// Subscribes to table updates *before* the first load, so a write racing
  /// the initial query (the first-run seeding) is never missed; overlapping
  /// changes collapse into one reload.
  Stream<dom.Journal> watchJournal() {
    late final StreamController<dom.Journal> controller;
    StreamSubscription<void>? updates;
    var loading = false;
    var dirty = false;

    Future<void> refresh() async {
      if (loading) {
        dirty = true;
        return;
      }
      loading = true;
      try {
        do {
          dirty = false;
          final journal = await loadJournal();
          if (!controller.isClosed) controller.add(journal);
        } while (dirty && !controller.isClosed);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      } finally {
        loading = false;
      }
    }

    controller = StreamController<dom.Journal>(
      onListen: () {
        updates = db
            .tableUpdates(TableUpdateQuery.onAllTables(_tables))
            .listen((_) => refresh());
        refresh();
      },
      onCancel: () => updates?.cancel(),
    );
    return controller.stream;
  }

  Future<dom.Journal> loadJournal() async {
    final cats = await db.select(db.categories).get();
    final spans = await db.select(db.categorySpans).get();
    final opts = await (db.select(
      db.categoryOptions,
    )..orderBy([(o) => OrderingTerm(expression: o.sort)])).get();
    final entries = await db.select(db.entries).get();
    final links = await db.select(db.entryOptions).get();
    final periods = await (db.select(
      db.periods,
    )..orderBy([(p) => OrderingTerm(expression: p.startDay)])).get();
    final labels = await db.select(db.moodLabels).get();

    final optionIdsByEntry = <int, Set<int>>{};
    for (final l in links) {
      (optionIdsByEntry[l.entryId] ??= {}).add(l.optionId);
    }
    return dom.Journal(
      categories: [
        for (final c in cats)
          dom.Category(
            id: c.id,
            name: c.name,
            icon: c.icon,
            mode: c.mode,
            display: c.display,
            defaultOptionId: c.defaultOptionId,
            sort: c.sort,
            hidden: c.hidden,
            spans: [
              for (final s in spans)
                if (s.categoryId == c.id)
                  dom.DaySpan(
                    Day.parse(s.fromDay),
                    s.toDay == null ? null : Day.parse(s.toDay!),
                  ),
            ],
            options: [
              for (final o in opts)
                if (o.categoryId == c.id)
                  dom.OptionItem(
                    id: o.id,
                    categoryId: o.categoryId,
                    name: o.name,
                    icon: o.icon,
                    sort: o.sort,
                    hidden: o.hidden,
                  ),
            ],
          ),
      ],
      entries: [
        for (final e in entries)
          dom.Entry(
            id: e.id,
            day: Day.parse(e.day),
            loggedAt: e.loggedAt,
            mood: Mood.fromValue(e.mood),
            note: e.note,
            optionIds: optionIdsByEntry[e.id] ?? const {},
          ),
      ],
      moodLabels: {
        for (final l in labels)
          if (l.label != null && l.label!.trim().isNotEmpty)
            l.value: l.label!.trim(),
      },
      periods: [
        for (final p in periods)
          dom.Period(
            id: p.id,
            name: p.name,
            start: Day.parse(p.startDay),
            end: p.endDay == null ? null : Day.parse(p.endDay!),
            away: p.away,
            icon: p.icon,
          ),
      ],
    );
  }

  /// Saves [draft] as the entry for its day (insert or replace — one entry per
  /// day). Pending defaults are in `draft.optionIds` and are stored like any
  /// pick. [now] stamps `loggedAt` on a new entry and `updatedAt` always.
  Future<void> saveEntry(EntryDraft draft, DateTime now) async {
    final mood = draft.mood;
    if (mood == null) throw StateError('An entry needs a mood');
    await db.transaction(() async {
      final key = draft.day.key;
      final existing = await (db.select(
        db.entries,
      )..where((e) => e.day.equals(key))).getSingleOrNull();
      final int id;
      if (existing == null) {
        id = await db
            .into(db.entries)
            .insert(
              EntriesCompanion.insert(
                day: key,
                loggedAt: now,
                mood: mood.value,
                note: Value(draft.noteOrNull),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        id = existing.id;
        await (db.update(db.entries)..where((e) => e.id.equals(id))).write(
          EntriesCompanion(
            mood: Value(mood.value),
            note: Value(draft.noteOrNull),
            updatedAt: Value(now),
          ),
        );
        await (db.delete(
          db.entryOptions,
        )..where((l) => l.entryId.equals(id))).go();
      }
      for (final optionId in draft.optionIds) {
        await db
            .into(db.entryOptions)
            .insert(
              EntryOptionsCompanion.insert(entryId: id, optionId: optionId),
            );
      }
    });
  }

  /// Deletes the entry for [day] (and its option links, by cascade).
  Future<void> deleteEntry(Day day) =>
      (db.delete(db.entries)..where((e) => e.day.equals(day.key))).go();

  // --- periods ---------------------------------------------------------------

  /// Inserts ([id] null) or updates a period (§2.5).
  Future<void> savePeriod({
    int? id,
    required String name,
    required Day start,
    Day? end,
    bool away = false,
  }) async {
    final row = PeriodsCompanion(
      name: Value(name),
      startDay: Value(start.key),
      endDay: Value(end?.key),
      away: Value(away),
    );
    if (id == null) {
      await db.into(db.periods).insert(row);
    } else {
      await (db.update(db.periods)..where((p) => p.id.equals(id))).write(row);
    }
  }

  Future<void> deletePeriod(int id) =>
      (db.delete(db.periods)..where((p) => p.id.equals(id))).go();

  // --- first run -------------------------------------------------------------

  Future<bool> onboardingDone() async {
    final row = await db.select(db.appSettings).getSingleOrNull();
    return row?.onboardingDone ?? false;
  }

  Future<void> markOnboardingDone() => db
      .into(db.appSettings)
      .insert(
        const AppSettingsCompanion(id: Value(1), onboardingDone: Value(true)),
        onConflict: DoUpdate(
          (_) => const AppSettingsCompanion(onboardingDone: Value(true)),
        ),
      );

  /// Seeds the starter set once, on a fresh install (§2.7). Tracking spans
  /// open on [today].
  Future<void> seedStarterSetIfNeeded(
    List<StarterCategory> set,
    Day today,
    DateTime now,
  ) async {
    if (await onboardingDone()) return;
    await db.transaction(() async {
      final any = await (db.select(db.categories)..limit(1)).get();
      if (any.isEmpty) await insertCategories(set, today, now);
      await markOnboardingDone();
    });
  }

  /// Inserts [set] after any existing categories, each with an open span from
  /// [from]. Returns the new category ids in order.
  Future<List<int>> insertCategories(
    List<StarterCategory> set,
    Day from,
    DateTime now,
  ) async {
    final existing = await db.select(db.categories).get();
    var sort = existing.length;
    final ids = <int>[];
    for (final c in set) {
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
      ids.add(cid);
      await db
          .into(db.categorySpans)
          .insert(
            CategorySpansCompanion.insert(categoryId: cid, fromDay: from.key),
          );
      var osort = 0;
      for (final o in c.options) {
        final oid = await db
            .into(db.categoryOptions)
            .insert(
              CategoryOptionsCompanion.insert(
                categoryId: cid,
                name: o.name,
                icon: o.icon,
                sort: Value(osort++),
              ),
            );
        if (o.isDefault && c.mode == CategoryMode.one) {
          await (db.update(db.categories)..where((t) => t.id.equals(cid)))
              .write(CategoriesCompanion(defaultOptionId: Value(oid)));
        }
      }
    }
    return ids;
  }
}
