import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/domain/category.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final now = DateTime(2026, 10, 14, 21);

  Future<int> category(String name, CategoryMode mode) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          name: name,
          icon: 'work',
          mode: mode,
          createdAt: now,
        ),
      );

  Future<int> option(int categoryId, String name) => db
      .into(db.categoryOptions)
      .insert(
        CategoryOptionsCompanion.insert(
          categoryId: categoryId,
          name: name,
          icon: 'work',
        ),
      );

  Future<int> entry(String day, int mood) => db
      .into(db.entries)
      .insert(
        EntriesCompanion.insert(
          day: day,
          loggedAt: now,
          mood: mood,
          createdAt: now,
          updatedAt: now,
        ),
      );

  test('schema v1 creates every table with defaults', () async {
    final c = await category('Work', CategoryMode.one);
    final row = await (db.select(
      db.categories,
    )..where((t) => t.id.equals(c))).getSingle();
    expect(row.display, CategoryDisplay.chips);
    expect(row.hidden, isFalse);
    expect(row.defaultOptionId, isNull);

    await db.into(db.appSettings).insert(const AppSettingsCompanion());
    final settings = await db.select(db.appSettings).getSingle();
    expect(settings.dayCutoffHour, 4);
    expect(settings.appLock, isFalse);
    expect(settings.localeCode, 'system');
  });

  test('one entry per calendar day', () async {
    await entry('2026-10-14', 4);
    expect(() => entry('2026-10-14', 2), throwsA(isA<SqliteException>()));
  });

  test('mood must be 1…5', () async {
    expect(() => entry('2026-10-14', 0), throwsA(isA<SqliteException>()));
    expect(() => entry('2026-10-15', 6), throwsA(isA<SqliteException>()));
  });

  test(
    'deleting an option removes it from every day (delete for good)',
    () async {
      final c = await category('Health', CategoryMode.any);
      final walk = await option(c, 'Walk');
      final e = await entry('2026-10-14', 4);
      await db
          .into(db.entryOptions)
          .insert(EntryOptionsCompanion.insert(entryId: e, optionId: walk));

      await (db.delete(
        db.categoryOptions,
      )..where((t) => t.id.equals(walk))).go();

      expect(await db.select(db.entryOptions).get(), isEmpty);
      expect(await db.select(db.entries).get(), hasLength(1));
    },
  );

  test('removing the default option clears it, never the category', () async {
    final c = await category('Work', CategoryMode.one);
    final dayOff = await option(c, 'Day off');
    await (db.update(db.categories)..where((t) => t.id.equals(c))).write(
      CategoriesCompanion(defaultOptionId: Value(dayOff)),
    );

    await (db.delete(
      db.categoryOptions,
    )..where((t) => t.id.equals(dayOff))).go();

    final row = await (db.select(
      db.categories,
    )..where((t) => t.id.equals(c))).getSingle();
    expect(row.defaultOptionId, isNull);
  });

  test(
    'deleting a category cascades to options, spans and day values',
    () async {
      final c = await category('Coffee', CategoryMode.one);
      final one = await option(c, 'One');
      await db
          .into(db.categorySpans)
          .insert(
            CategorySpansCompanion.insert(categoryId: c, fromDay: '2026-09-18'),
          );
      final e = await entry('2026-10-14', 3);
      await db
          .into(db.entryOptions)
          .insert(EntryOptionsCompanion.insert(entryId: e, optionId: one));

      await (db.delete(db.categories)..where((t) => t.id.equals(c))).go();

      expect(await db.select(db.categoryOptions).get(), isEmpty);
      expect(await db.select(db.categorySpans).get(), isEmpty);
      expect(await db.select(db.entryOptions).get(), isEmpty);
      expect(await db.select(db.entries).get(), hasLength(1));
    },
  );
}
