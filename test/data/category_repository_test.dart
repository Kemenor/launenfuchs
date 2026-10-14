import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/data/repositories/category_repository.dart';
import 'package:launenfuchs/data/repositories/journal_repository.dart';
import 'package:launenfuchs/domain/category.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/entry_draft.dart';
import 'package:launenfuchs/domain/mood.dart';
import 'package:launenfuchs/domain/stats.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository cats;
  late JournalRepository journal;
  final now = DateTime(2026, 10, 14, 21);
  const d1 = Day(2026, 10, 1);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    cats = CategoryRepository(db);
    journal = JournalRepository(db);
  });
  tearDown(() => db.close());

  Future<void> log(Day day, Mood mood, Set<int> options) async {
    final j = await journal.loadJournal();
    final d = EntryDraft.forDay(j, day)..mood = mood;
    for (final c in j.categories) {
      d.clear(c);
    }
    for (final o in options) {
      final c = j.categoryOfOption(o)!;
      c.mode == CategoryMode.one ? d.setOne(c, o) : d.tap(c, o);
    }
    await journal.saveEntry(d, now);
  }

  test(
    'hide closes the span, bring back opens a new one: the gap is not tracked',
    () async {
      final coffee = await cats.createCategory(
        name: 'Coffee',
        icon: 'coffee',
        mode: CategoryMode.one,
        today: d1,
        now: now,
      );
      final one = await cats.addOption(coffee, name: 'One', icon: 'coffee');
      await log(d1, Mood.good, {one});

      await cats.hideCategory(coffee, d1.addDays(2));
      await log(d1.addDays(5), Mood.meh, {});
      await cats.bringBackCategory(coffee, d1.addDays(9));
      await log(d1.addDays(10), Mood.bad, {});

      final j = await journal.loadJournal();
      final c = j.categories.single;
      expect(c.hidden, isFalse);
      expect(c.tracks(d1.addDays(2)), isTrue);
      expect(c.tracks(d1.addDays(5)), isFalse, reason: 'hidden: not tracked');
      expect(c.tracks(d1.addDays(10)), isTrue);

      final rows = optionComparison(
        j,
        StatsRange(d1, d1.addDays(10)),
      ).single.rows;
      expect(rows.firstWhere((r) => r.kind == RowKind.notTracked).count, 1);
      expect(rows.firstWhere((r) => r.kind == RowKind.nothingLogged).count, 1);
    },
  );

  test('bring back on the same day reopens the span', () async {
    final c = await cats.createCategory(
      name: 'X',
      icon: 'label',
      mode: CategoryMode.any,
      today: d1,
      now: now,
    );
    await cats.hideCategory(c, d1.addDays(3));
    await cats.bringBackCategory(c, d1.addDays(3));
    final cat = (await journal.loadJournal()).categories.single;
    expect(cat.spans, hasLength(1));
    expect(cat.spans.single.to, isNull);
  });

  test('delete for good removes the category and its day values', () async {
    final c = await cats.createCategory(
      name: 'Coffee',
      icon: 'coffee',
      mode: CategoryMode.one,
      today: d1,
      now: now,
    );
    final one = await cats.addOption(c, name: 'One', icon: 'coffee');
    await cats.setDefault(c, one);
    await log(d1, Mood.good, {one});
    expect(await cats.categoryDayCount(c), 1);
    await cats.deleteCategory(c);
    final j = await journal.loadJournal();
    expect(j.categories, isEmpty);
    expect(j.entryOn(d1)!.optionIds, isEmpty);
  });

  test('merge moves days, follows the default, reports collisions', () async {
    final work = await cats.createCategory(
      name: 'Work',
      icon: 'work',
      mode: CategoryMode.one,
      today: d1,
      now: now,
    );
    final normal = await cats.addOption(work, name: 'Normal', icon: 'work');
    final holiday = await cats.addOption(
      work,
      name: 'Holiday',
      icon: 'beach_access',
    );
    final dayOff = await cats.addOption(
      work,
      name: 'Day off',
      icon: 'beach_access',
    );
    await cats.setDefault(work, holiday);
    await log(d1, Mood.good, {holiday});
    await log(d1.addDays(1), Mood.meh, {normal});

    expect(await cats.mergeCollisions(holiday, dayOff), 0);
    expect(await cats.mergeOption(holiday, dayOff), 1);
    final j = await journal.loadJournal();
    expect(j.entryOn(d1)!.optionIds, {dayOff});
    expect(j.categories.single.defaultOptionId, dayOff);
    expect(j.categories.single.options.map((o) => o.name), [
      'Normal',
      'Day off',
    ]);
  });

  test('merge collision count for a one-per-day target', () async {
    final work = await cats.createCategory(
      name: 'Work',
      icon: 'work',
      mode: CategoryMode.one,
      today: d1,
      now: now,
    );
    final health = await cats.createCategory(
      name: 'Health',
      icon: 'favorite',
      mode: CategoryMode.any,
      today: d1,
      now: now,
    );
    final normal = await cats.addOption(work, name: 'Normal', icon: 'work');
    final dayOff = await cats.addOption(
      work,
      name: 'Day off',
      icon: 'beach_access',
    );
    final walk = await cats.addOption(
      health,
      name: 'Walk',
      icon: 'directions_walk',
    );
    await log(d1, Mood.good, {normal, walk});
    expect(
      await cats.mergeCollisions(walk, dayOff),
      1,
      reason: 'd1 would have Normal + Day off',
    );
  });

  test('fill empty days writes real rows, only on tracked days', () async {
    final work = await cats.createCategory(
      name: 'Work',
      icon: 'work',
      mode: CategoryMode.one,
      today: d1,
      now: now,
    );
    final normal = await cats.addOption(work, name: 'Normal', icon: 'work');
    final dayOff = await cats.addOption(
      work,
      name: 'Day off',
      icon: 'beach_access',
    );
    await log(d1.addDays(-2), Mood.meh, {}); // before tracking began
    await log(d1, Mood.good, {normal});
    await log(d1.addDays(1), Mood.good, {});
    await log(d1.addDays(2), Mood.bad, {});
    expect(await cats.emptyDayCount(work), 2);
    expect(await cats.fillEmptyDays(work, dayOff), 2);
    final j = await journal.loadJournal();
    expect(j.entryOn(d1.addDays(2))!.optionIds, {dayOff});
    expect(
      j.entryOn(d1.addDays(-2))!.optionIds,
      isEmpty,
      reason: 'not tracked yet',
    );
    // Changing the default later never touches these days.
    await cats.setDefault(work, normal);
    expect((await journal.loadJournal()).entryOn(d1.addDays(2))!.optionIds, {
      dayOff,
    });
  });

  test('deleting an option clears a default pointing at it', () async {
    final work = await cats.createCategory(
      name: 'Work',
      icon: 'work',
      mode: CategoryMode.one,
      today: d1,
      now: now,
    );
    final dayOff = await cats.addOption(
      work,
      name: 'Day off',
      icon: 'beach_access',
    );
    await cats.setDefault(work, dayOff);
    await cats.deleteOption(dayOff);
    expect(
      (await journal.loadJournal()).categories.single.defaultOptionId,
      isNull,
    );
  });

  test('tracked since moves the first span', () async {
    final c = await cats.createCategory(
      name: 'X',
      icon: 'label',
      mode: CategoryMode.any,
      today: d1,
      now: now,
    );
    await cats.setTrackedSince(c, const Day(2026, 9, 1));
    expect(
      (await journal.loadJournal()).categories.single.tracks(
        const Day(2026, 9, 1),
      ),
      isTrue,
    );
  });
}
