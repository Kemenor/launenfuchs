import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/journal.dart';
import 'package:launenfuchs/domain/mood.dart';
import 'package:launenfuchs/domain/stats.dart';

import '../support/fixtures.dart';

void main() {
  const d0 = Day(2026, 9, 15);
  Day d(int i) => d0.addDays(i);
  // Coffee is tracked from Sep 18 (= d(3)).
  final j = journalOf([
    entry(d(0), Mood.good, {11, 21}),
    entry(d(1), Mood.meh, {11}),
    // d(2) not logged
    entry(d(3), Mood.bad, {12, 22, 32}),
    entry(d(4), Mood.awful, {13, 33}, 'rough'),
    entry(d(5), Mood.rad, {13, 21, 31}),
    entry(d(6), Mood.good, {13, 21, 31}),
  ]);
  final r = StatsRange(d(0), d(6));

  test('range basics', () {
    expect(r.length, 7);
    expect(r.previous, StatsRange(d(-7), d(-1)));
    expect(entriesIn(j, r).map((e) => e.day).first, d(0));
  });

  test('summary', () {
    final s = summary(j, r);
    expect(s.daysLogged, 6);
    expect(s.daysInRange, 7);
    expect(s.average, closeTo((4 + 3 + 2 + 1 + 5 + 4) / 6, 1e-9));
    expect(s.best.single.day, d(5));
    expect(s.worst.single.day, d(4));
  });

  test('day series: trailing 7 calendar days, gaps skipped', () {
    final s = daySeries(j, r);
    expect(s[2].entry, isNull);
    expect(s[2].rolling, closeTo(3.5, 1e-9), reason: 'mean of d0 and d1');
    expect(s[6].rolling, closeTo(19 / 6, 1e-9));
  });

  test('comparison keeps nothing-logged and not-tracked apart (§4.3)', () {
    final groups = optionComparison(j, r);
    final work = groups.firstWhere((g) => g.category.name == 'Work');
    expect(work.rows.map((x) => x.option?.name), [
      'Worked normally',
      'Worked less',
      'Day off',
    ]);
    final coffee = groups.firstWhere((g) => g.category.name == 'Coffee');
    final nt = coffee.rows.firstWhere((x) => x.kind == RowKind.notTracked);
    expect(nt.count, 2, reason: 'd0, d1 are before Coffee was tracked');
    expect(coffee.rows.where((x) => x.kind == RowKind.nothingLogged), isEmpty);
    final health = groups.firstWhere((g) => g.category.name == 'Health');
    final nothing = health.rows.firstWhere(
      (x) => x.kind == RowKind.nothingLogged,
    );
    expect(nothing.count, 2, reason: 'd1 and d4');
  });

  test('weekday means', () {
    final w = weekdayMeans(j, r);
    expect(w.length, 7);
    expect(w.fold<int>(0, (n, x) => n + x.count), 6);
  });

  test('ups and downs: consecutive logged days only', () {
    final u = upsAndDowns(j, r);
    // pairs: d0→d1 (1), d3→d4 (1), d4→d5 (4), d5→d6 (1)
    expect(u.pairs, 4);
    expect(u.averageChange, closeTo(7 / 4, 1e-9));
    expect(u.biggestDrops, isEmpty, reason: 'no drop of two or more steps');
  });

  test('stretches break on gaps; ties go to the most recent', () {
    expect(goodStretch(j, r)!.from, d(5));
    expect(goodStretch(j, r)!.length, 2);
    expect(hardStretch(j, r)!.from, d(3));
    expect(hardStretch(j, r)!.length, 2);
  });

  test('often together, option counts, notes', () {
    expect(oftenTogether(j, r, Mood.good).first.option.id, 21);
    expect(optionCounts(j, r).first.option.id, anyOf(13, 21));
    expect(notesIn(j, r).single.note, 'rough');
    expect(moodCounts(j, r)[Mood.good], 2);
  });

  test('option detail', () {
    final walk = j.option(21)!;
    final det = optionDetail(j, r, walk, d(6));
    expect(det.count, 3);
    expect(det.days, {d(0), d(5), d(6)});
    expect(det.nextDayCount, 2, reason: 'd0→d1, d5→d6; d6 has no next day');
    expect(det.together.first.$1.id, 13);
    expect(det.together.first.$2, closeTo(2 / 3, 1e-9));
    expect(det.longestWith, 2);
  });

  test('periods: slices plus outside', () {
    final jp = Journal(
      categories: j.categories,
      entries: j.entries,
      periods: [Period(id: 1, name: 'Trip', start: d(3), end: d(4))],
    );
    final s = periodSummary(jp, r, d(6));
    expect(s.first.period!.name, 'Trip');
    expect(s.first.entries.length, 2);
    expect(s.last.period, isNull);
    expect(s.last.entries.length, 4);
  });
}
