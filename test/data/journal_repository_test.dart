import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/data/repositories/journal_repository.dart';
import 'package:launenfuchs/domain/category.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/entry_draft.dart';
import 'package:launenfuchs/domain/mood.dart';
import 'package:launenfuchs/domain/starter.dart';

const names = StarterNames(
  work: 'Work',
  workedNormally: 'Worked normally',
  workedLess: 'Worked less',
  dayOff: 'Day off',
  sick: 'Sick',
  health: 'Health',
  walk: 'Walk',
  exercise: 'Exercise',
  sport: 'Sport',
  social: 'Social',
  friends: 'Friends',
  family: 'Family',
  partner: 'Partner',
  timeAlone: 'Time alone',
  hobbies: 'Hobbies',
  reading: 'Reading',
  gaming: 'Gaming',
  music: 'Music',
  creative: 'Creative',
  sleep: 'Sleep',
  sleepPoor: 'Poor',
  sleepOk: 'OK',
  sleepGood: 'Good',
);

void main() {
  late AppDatabase db;
  late JournalRepository repo;
  const today = Day(2026, 10, 14);
  final now = DateTime(2026, 10, 14, 21);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = JournalRepository(db);
  });
  tearDown(() => db.close());

  test('the starter set seeds once, with spans and the Work default', () async {
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    var j = await repo.loadJournal();
    expect(j.categories.map((c) => c.name), [
      'Work',
      'Health',
      'Social',
      'Hobbies',
      'Sleep',
    ]);
    final work = j.categories.first;
    expect(work.mode, CategoryMode.one);
    expect(work.defaultOption?.name, 'Day off');
    expect(work.tracks(today), isTrue);
    expect(work.tracks(today.addDays(-1)), isFalse);
    expect(j.categories.last.display, CategoryDisplay.slider);

    // Deleting everything must not bring the starter set back.
    await db.delete(db.categories).go();
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    j = await repo.loadJournal();
    expect(j.categories, isEmpty);
  });

  test('saving a new entry stores the pending default', () async {
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    var j = await repo.loadJournal();
    final draft = EntryDraft.forDay(j, today)..mood = Mood.good;
    await repo.saveEntry(draft, now);

    j = await repo.loadJournal();
    final e = j.entryOn(today)!;
    expect(e.mood, Mood.good);
    expect(e.optionIds, {j.categories.first.defaultOptionId});
    expect(e.loggedAt, now);
  });

  test('saving the same day again replaces — one entry per day', () async {
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    var j = await repo.loadJournal();
    final walk = j.categories[1].options.first.id;

    await repo.saveEntry(EntryDraft.forDay(j, today)..mood = Mood.bad, now);
    j = await repo.loadJournal();
    final edit = EntryDraft.forDay(j, today)
      ..mood = Mood.rad
      ..note = ' better after all ';
    edit.clear(j.categories.first);
    edit.tap(j.categories[1], walk);
    await repo.saveEntry(edit, now.add(const Duration(minutes: 5)));

    j = await repo.loadJournal();
    expect(j.entries, hasLength(1));
    final e = j.entryOn(today)!;
    expect(e.mood, Mood.rad);
    expect(e.optionIds, {walk});
    expect(e.note, 'better after all');
    expect(e.loggedAt, now, reason: 'logged time is the first save');
  });

  test('deleteEntry removes the day and its options', () async {
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    final j = await repo.loadJournal();
    await repo.saveEntry(EntryDraft.forDay(j, today)..mood = Mood.meh, now);
    await repo.deleteEntry(today);
    expect((await repo.loadJournal()).entries, isEmpty);
    expect(await db.select(db.entryOptions).get(), isEmpty);
  });

  test('watchJournal re-emits after a write', () async {
    await repo.seedStarterSetIfNeeded(starterSet(names), today, now);
    final seen = <int>[];
    final sub = repo.watchJournal().listen((j) => seen.add(j.entries.length));
    await pumpEventQueue();
    final j = await repo.loadJournal();
    await repo.saveEntry(EntryDraft.forDay(j, today)..mood = Mood.good, now);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 1);
  });

  test('periods: save, edit to ongoing, delete', () async {
    await repo.savePeriod(
      name: 'Holiday',
      start: const Day(2026, 9, 22),
      end: const Day(2026, 9, 28),
      away: true,
    );
    var p = (await repo.loadJournal()).periods.single;
    expect(p.away, isTrue);
    expect(p.contains(const Day(2026, 9, 28), today: today), isTrue);
    expect(p.contains(const Day(2026, 9, 29), today: today), isFalse);

    await repo.savePeriod(
      id: p.id,
      name: 'New job',
      start: const Day(2026, 10, 6),
    );
    p = (await repo.loadJournal()).periods.single;
    expect(p.name, 'New job');
    expect(p.ongoing, isTrue);
    expect(p.contains(today, today: today), isTrue);

    await repo.deletePeriod(p.id);
    expect((await repo.loadJournal()).periods, isEmpty);
  });

  test('renamed mood labels ride along in the journal snapshot', () async {
    await db
        .into(db.moodLabels)
        .insert(
          MoodLabelsCompanion.insert(
            value: const Value(5),
            label: const Value('super'),
          ),
        );
    await db
        .into(db.moodLabels)
        .insert(
          MoodLabelsCompanion.insert(
            value: const Value(1),
            label: const Value('  '),
          ),
        );
    final j = await repo.loadJournal();
    expect(j.moodLabels, {5: 'super'}, reason: 'blank = the default');
  });
}
