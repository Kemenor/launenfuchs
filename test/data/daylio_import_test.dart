import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/data/import/daylio.dart';
import 'package:launenfuchs/data/import/import_writer.dart';
import 'package:launenfuchs/data/repositories/journal_repository.dart';
import 'package:launenfuchs/domain/category.dart';
import 'package:launenfuchs/domain/daylio_backup.dart';
import 'package:launenfuchs/domain/daylio_plan.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/mood.dart';

import '../support/daylio_fixture.dart';

void main() {
  final now = DateTime(2026, 10, 14, 21);
  late DaylioAnalysis a;

  setUp(
    () => a = DaylioAnalysis.of(
      parseDaylioBackup(daylioFile(sampleDaylioJson())),
    ),
  );

  group('parser', () {
    test('rejects files that are not Daylio backups', () {
      expect(
        () => parseDaylioBackup([1, 2, 3]),
        throwsA(isA<DaylioFormatException>()),
      );
    });

    test('0-based months, flipped moods, HTML notes', () {
      final b = parseDaylioBackup(daylioFile(sampleDaylioJson()));
      expect(b.groups.map((g) => g.name), ['Productivity', 'Health', 'Coffee']);
      final first = b.entries.first;
      expect((first.month, first.day), (9, 8));
      expect(first.moodValue, 4, reason: 'Daylio group 2 = good = 4');
      expect(first.note, 'Long day\nbut ok & fine');
    });

    test('htmlToText', () {
      expect(htmlToText('a<br>b<br/>c &lt;3 <b>bold</b>'), 'a\nb\nc <3 bold');
    });
  });

  group('analysis', () {
    test('several entries on one day fold into one', () {
      expect(a.days, hasLength(4));
      expect(a.mergedDayCount, 1);
      final d = a.days.last;
      expect(d.day, const Day(2026, 9, 11));
      expect(d.mood, 3, reason: 'mean of 4 and 1 = 2.5, half up');
      expect(d.tagIds, {61, 73, 18});
      expect(d.note, 'morning\n\nEvening\ntired');
      expect(d.loggedAt, DateTime(2026, 9, 11, 9));
    });

    test('suggestions: one per day unless doubled up; unused tags drop', () {
      final m = a.suggestedMapping();
      expect(m.groups[7]!.mode, CategoryMode.one);
      expect(
        m.groups[3]!.mode,
        CategoryMode.any,
        reason: 'walk + gym on Sep 8',
      );
      expect(m.groups[12]!.mode, CategoryMode.one);
      expect(m.tags[77]!.action, MapAction.drop, reason: 'Holiday never used');
      expect(m.tags[18]!.icon, 'directions_walk');
      expect(m.groups[12]!.icon, 'coffee');
      expect(a.groupStats[12]!.first, const Day(2026, 9, 10));
    });
  });

  group('plan', () {
    test('keep + rename, merge, drop, default and fill', () {
      final m = a.suggestedMapping();
      m.groups[7]!.name = 'Work';
      m.tags[77]!
        ..action = MapAction.keep
        ..name = 'Day off';
      m.tags[22]!
        ..action = MapAction.merge
        ..mergeInto = 69; // sport → gym
      m.tags[73]!.name = 'None';
      m.defaultsFor(7)
        ..defaultTagId = 77
        ..fillTagId = 77;
      m.groups[12]!.display = CategoryDisplay.slider;

      final p = planImport(a, m);
      expect(p.categories.map((c) => c.name), ['Work', 'Health', 'Coffee']);
      final work = p.categories[0];
      expect(work.options.map((o) => o.name), [
        'Worked Normally',
        'worked less',
        'Day off',
      ]);
      expect(work.defaultTagId, 77);
      expect(work.trackedFrom, const Day(2026, 9, 8));
      expect(work.emptyDays, 1, reason: 'Sep 10');
      expect(work.filledDays, 1);
      expect(
        p.entries.firstWhere((e) => e.day == const Day(2026, 9, 10)).tagIds,
        contains(77),
      );

      final health = p.categories[1];
      expect(health.options.map((o) => o.name), ['walk', 'gym']);
      expect(
        p.entries.firstWhere((e) => e.day == const Day(2026, 9, 9)).tagIds,
        {62, 69},
        reason: 'sport moved to gym',
      );

      final coffee = p.categories[2];
      expect(coffee.trackedFrom, const Day(2026, 9, 10), reason: 'first use');
      expect(coffee.display, CategoryDisplay.slider);
    });

    test('dropping a group drops its tags; merging groups moves them', () {
      final m = a.suggestedMapping();
      m.groups[12]!.action = MapAction.drop;
      var p = planImport(a, m);
      expect(p.categories.map((c) => c.name), ['Productivity', 'Health']);
      expect(p.entries.every((e) => !e.tagIds.contains(74)), isTrue);

      m.groups[12]!
        ..action = MapAction.merge
        ..mergeInto = 3;
      p = planImport(a, m);
      expect(p.categories[1].options.map((o) => o.name), [
        'walk',
        'sport',
        'gym',
        'Nothing',
        'one cup',
      ], reason: '"two cups" was never used, so it starts on Drop');
    });

    test('a merge that doubles up a one-per-day category is counted', () {
      final m = a.suggestedMapping();
      m.groups[12]!
        ..action = MapAction.merge
        ..mergeInto = 7; // coffee into Productivity (one per day)
      final p = planImport(a, m);
      expect(
        p.categories.first.collisionDays,
        1,
        reason: 'only Sep 11 has both a work tag and Nothing',
      );
    });

    test('merge cycles resolve to dropped, not a hang', () {
      final m = a.suggestedMapping();
      m.tags[18]!
        ..action = MapAction.merge
        ..mergeInto = 69;
      m.tags[69]!
        ..action = MapAction.merge
        ..mergeInto = 18;
      expect(resolveTag(m, 18), isNull);
    });
  });

  group('writer', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('replaces journal data, keeps periods, saves the mapping', () async {
      await db
          .into(db.periods)
          .insert(
            PeriodsCompanion.insert(name: 'Holiday', startDay: '2026-09-20'),
          );
      final m = a.suggestedMapping();
      m.tags[77]!.action = MapAction.keep;
      m.defaultsFor(7)
        ..defaultTagId = 77
        ..fillTagId = 77;
      await writeImport(
        db,
        planImport(a, m),
        now: now,
        lastDay: const Day(2026, 9, 11),
      );

      final j = await JournalRepository(db).loadJournal();
      expect(j.entries, hasLength(4));
      expect(j.periods, hasLength(1), reason: 'periods survive an import');
      final work = j.categories.first;
      expect(work.defaultOption?.name, 'Holiday');
      expect(work.tracks(const Day(2026, 9, 8)), isTrue);
      expect(j.entryOn(const Day(2026, 9, 11))!.mood, Mood.meh);
      expect(await JournalRepository(db).onboardingDone(), isTrue);

      final saved = await loadSavedMapping(db);
      expect(saved.groups[7]!.mode, CategoryMode.one);
      expect(saved.tags[77]!.action, MapAction.keep);
      // A repeat import starts from the saved choices.
      expect(a.suggestedMapping(saved: saved).tags[77]!.action, MapAction.keep);
    });
  });

  // The author's real backup lives only in the gitignored test/private/.
  final real = File('test/private/real.daylio');
  test('the real backup imports (local only)', () {
    final ra = DaylioAnalysis.of(parseDaylioBackup(real.readAsBytesSync()));
    expect(ra.days, hasLength(37));
    expect(ra.firstDay, const Day(2026, 9, 8));
    expect(ra.lastDay, const Day(2026, 10, 14));
    expect(ra.noteCount, 5);
    expect(ra.mergedDayCount, 0);
    final m = ra.suggestedMapping();
    final p = planImport(ra, m);
    final mean =
        p.entries.fold<int>(0, (s, e) => s + e.mood) / p.entries.length;
    expect(mean, closeTo(3.22, 0.01), reason: 'the 2026-10-14 report');
    // Hobbies had two tags on 6 days → any number; Productivity one per day.
    expect(
      m.groups.values.where((g) => g.mode == CategoryMode.any),
      hasLength(1),
    );
  }, skip: real.existsSync() ? false : 'no private backup');
}
