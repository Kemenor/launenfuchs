import 'package:drift/drift.dart';

import '../../domain/category.dart';
import '../../domain/day.dart';
import '../db/database.dart';

/// Categories and options (design-concept §2.3–§2.4). The rules that keep
/// history honest live here:
/// - **Hide** closes the open tracking span; **bring back** opens a new one —
///   the gap reads *not tracked*, never *nothing logged*.
/// - **Delete for good** is the cascade; **merge** moves an option's days and
///   deletes it; **fill empty days** writes real rows. All confirmed in the UI.
/// - A default is only a pre-selection; changing it never touches past days.
class CategoryRepository {
  CategoryRepository(this.db);
  final AppDatabase db;

  Future<int> createCategory({
    required String name,
    required String icon,
    required CategoryMode mode,
    required Day today,
    required DateTime now,
  }) => db.transaction(() async {
    final count = await db.select(db.categories).get();
    final id = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            icon: icon,
            mode: mode,
            sort: Value(count.length),
            createdAt: now,
          ),
        );
    await db
        .into(db.categorySpans)
        .insert(
          CategorySpansCompanion.insert(categoryId: id, fromDay: today.key),
        );
    return id;
  });

  Future<void> updateCategory(
    int id, {
    String? name,
    String? icon,
    CategoryMode? mode,
    CategoryDisplay? display,
  }) => (db.update(db.categories)..where((c) => c.id.equals(id))).write(
    CategoriesCompanion(
      name: name == null ? const Value.absent() : Value(name),
      icon: icon == null ? const Value.absent() : Value(icon),
      mode: mode == null ? const Value.absent() : Value(mode),
      display: display == null ? const Value.absent() : Value(display),
    ),
  );

  /// Sets (or clears) the default option. Only a pre-selection for new entries.
  Future<void> setDefault(int categoryId, int? optionId) =>
      (db.update(db.categories)..where((c) => c.id.equals(categoryId))).write(
        CategoriesCompanion(defaultOptionId: Value(optionId)),
      );

  Future<void> reorderCategories(List<int> ids) => db.batch((b) {
    for (var i = 0; i < ids.length; i++) {
      b.update(
        db.categories,
        CategoriesCompanion(sort: Value(i)),
        where: (c) => c.id.equals(ids[i]),
      );
    }
  });

  /// Moves the start of the earliest tracking span (§2.3 *Tracked since*).
  Future<void> setTrackedSince(int categoryId, Day from) async {
    final spans =
        await (db.select(db.categorySpans)
              ..where((s) => s.categoryId.equals(categoryId))
              ..orderBy([(s) => OrderingTerm(expression: s.fromDay)]))
            .get();
    if (spans.isEmpty) {
      await db
          .into(db.categorySpans)
          .insert(
            CategorySpansCompanion.insert(
              categoryId: categoryId,
              fromDay: from.key,
            ),
          );
      return;
    }
    await (db.update(db.categorySpans)
          ..where((s) => s.id.equals(spans.first.id)))
        .write(CategorySpansCompanion(fromDay: Value(from.key)));
  }

  /// Hide: off the entry sheet, data kept, the open span closes on [today].
  Future<void> hideCategory(int id, Day today) => db.transaction(() async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(hidden: Value(true)),
    );
    await (db.update(db.categorySpans)
          ..where((s) => s.categoryId.equals(id) & s.toDay.isNull()))
        .write(CategorySpansCompanion(toDay: Value(today.key)));
  });

  /// Bring back: visible again, tracking resumes from [today] (a span closed
  /// today simply reopens; otherwise a new one starts).
  Future<void> bringBackCategory(int id, Day today) => db.transaction(() async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(hidden: Value(false)),
    );
    final closedToday = await (db.select(
      db.categorySpans,
    )..where((s) => s.categoryId.equals(id) & s.toDay.equals(today.key))).get();
    if (closedToday.isNotEmpty) {
      await (db.update(db.categorySpans)
            ..where((s) => s.id.equals(closedToday.first.id)))
          .write(const CategorySpansCompanion(toDay: Value(null)));
    } else {
      await db
          .into(db.categorySpans)
          .insert(
            CategorySpansCompanion.insert(categoryId: id, fromDay: today.key),
          );
    }
  });

  /// Delete for good: the category, its options and their values on every day.
  Future<void> deleteCategory(int id) => db.transaction(() async {
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      const CategoriesCompanion(defaultOptionId: Value(null)),
    );
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();
  });

  /// Days with at least one of the category's options (for the dialogs).
  Future<int> categoryDayCount(int id) async {
    final r = await db
        .customSelect(
          'SELECT COUNT(DISTINCT eo.entry_id) AS n FROM entry_options eo '
          'JOIN category_options o ON o.id = eo.option_id WHERE o.category_id = ?',
          variables: [Variable.withInt(id)],
          readsFrom: {db.entryOptions, db.categoryOptions},
        )
        .getSingle();
    return r.read<int>('n');
  }

  // --- options ---------------------------------------------------------------

  Future<int> addOption(
    int categoryId, {
    required String name,
    required String icon,
  }) async {
    final count = await (db.select(
      db.categoryOptions,
    )..where((o) => o.categoryId.equals(categoryId))).get();
    return db
        .into(db.categoryOptions)
        .insert(
          CategoryOptionsCompanion.insert(
            categoryId: categoryId,
            name: name,
            icon: icon,
            sort: Value(count.length),
          ),
        );
  }

  Future<void> updateOption(int id, {String? name, String? icon}) =>
      (db.update(db.categoryOptions)..where((o) => o.id.equals(id))).write(
        CategoryOptionsCompanion(
          name: name == null ? const Value.absent() : Value(name),
          icon: icon == null ? const Value.absent() : Value(icon),
        ),
      );

  Future<void> reorderOptions(List<int> ids) => db.batch((b) {
    for (var i = 0; i < ids.length; i++) {
      b.update(
        db.categoryOptions,
        CategoryOptionsCompanion(sort: Value(i)),
        where: (o) => o.id.equals(ids[i]),
      );
    }
  });

  Future<void> setOptionHidden(int id, bool hidden) =>
      (db.update(db.categoryOptions)..where((o) => o.id.equals(id))).write(
        CategoryOptionsCompanion(hidden: Value(hidden)),
      );

  /// Days that have this option.
  Future<int> optionDayCount(int id) async => (await (db.select(
    db.entryOptions,
  )..where((l) => l.optionId.equals(id))).get()).length;

  /// Delete for good: removed from every day (cascade); a default pointing at
  /// it is cleared (set null).
  Future<void> deleteOption(int id) =>
      (db.delete(db.categoryOptions)..where((o) => o.id.equals(id))).go();

  /// Days that would hold two options of a one-per-day target category after
  /// merging [from] into [into] (they are kept, §4.3 — the dialog says so).
  Future<int> mergeCollisions(int from, int into) async {
    final target = await (db.select(
      db.categoryOptions,
    )..where((o) => o.id.equals(into))).getSingle();
    final cat = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(target.categoryId))).getSingle();
    if (cat.mode != CategoryMode.one) return 0;
    final r = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM entry_options a WHERE a.option_id = ? AND EXISTS '
          '(SELECT 1 FROM entry_options b JOIN category_options o ON o.id = b.option_id '
          'WHERE b.entry_id = a.entry_id AND o.category_id = ? AND b.option_id NOT IN (?, ?))',
          variables: [
            Variable.withInt(from),
            Variable.withInt(cat.id),
            Variable.withInt(from),
            Variable.withInt(into),
          ],
          readsFrom: {db.entryOptions, db.categoryOptions},
        )
        .getSingle();
    return r.read<int>('n');
  }

  /// Merge [from] into [into]: its days move over, then it is deleted.
  /// Returns the number of days moved.
  Future<int> mergeOption(int from, int into) => db.transaction(() async {
    final links = await (db.select(
      db.entryOptions,
    )..where((l) => l.optionId.equals(from))).get();
    for (final l in links) {
      await db
          .into(db.entryOptions)
          .insert(
            EntryOptionsCompanion.insert(entryId: l.entryId, optionId: into),
            mode: InsertMode.insertOrIgnore,
          );
    }
    // A default pointing at [from] follows it to [into] when in the same
    // category; otherwise it is cleared by the delete's set-null.
    final src = await (db.select(
      db.categoryOptions,
    )..where((o) => o.id.equals(from))).getSingle();
    final dst = await (db.select(
      db.categoryOptions,
    )..where((o) => o.id.equals(into))).getSingle();
    if (src.categoryId == dst.categoryId) {
      await (db.update(db.categories)..where(
            (c) => c.id.equals(src.categoryId) & c.defaultOptionId.equals(from),
          ))
          .write(CategoriesCompanion(defaultOptionId: Value(into)));
    }
    await deleteOption(from);
    return links.length;
  });

  // --- fill empty days -------------------------------------------------------

  /// Logged, tracked days with nothing from [categoryId].
  Future<List<int>> _emptyEntryIds(int categoryId) async {
    final spans = await (db.select(
      db.categorySpans,
    )..where((s) => s.categoryId.equals(categoryId))).get();
    final options = {
      for (final o in await (db.select(
        db.categoryOptions,
      )..where((o) => o.categoryId.equals(categoryId))).get())
        o.id,
    };
    final entries = await db.select(db.entries).get();
    final links = await db.select(db.entryOptions).get();
    final has = <int>{
      for (final l in links)
        if (options.contains(l.optionId)) l.entryId,
    };
    bool tracked(String day) => spans.any(
      (s) =>
          day.compareTo(s.fromDay) >= 0 &&
          (s.toDay == null || day.compareTo(s.toDay!) <= 0),
    );
    return [
      for (final e in entries)
        if (!has.contains(e.id) && tracked(e.day)) e.id,
    ];
  }

  Future<int> emptyDayCount(int categoryId) async =>
      (await _emptyEntryIds(categoryId)).length;

  /// Sets [optionId] on every empty day (§2.3 *Fill empty days…*). Returns the
  /// number of days filled.
  Future<int> fillEmptyDays(int categoryId, int optionId) =>
      db.transaction(() async {
        final ids = await _emptyEntryIds(categoryId);
        await db.batch((b) {
          b.insertAll(db.entryOptions, [
            for (final id in ids)
              EntryOptionsCompanion.insert(entryId: id, optionId: optionId),
          ]);
        });
        return ids.length;
      });
}
