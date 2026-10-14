import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/data/import/daylio.dart';
import 'package:launenfuchs/data/import/import_writer.dart';
import 'package:launenfuchs/data/repositories/journal_repository.dart';
import 'package:launenfuchs/domain/category.dart';
import 'package:launenfuchs/domain/daylio_plan.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/journal.dart';
import 'package:launenfuchs/domain/stats.dart';

/// Golden test against the author's real Daylio backup (local only — it
/// lives in the gitignored test/private/). The numbers are the 2026-10-14
/// report's (PLAN § Engine).
void main() {
  final file = File('test/private/real.daylio');
  const today = Day(2026, 10, 14);

  test('reproduces the 2026-10-14 report', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final a = DaylioAnalysis.of(parseDaylioBackup(file.readAsBytesSync()));
    final m = a.suggestedMapping();
    for (final g in m.groups.values) {
      if (g.name == 'Health') g.mode = CategoryMode.any;
    }
    await writeImport(
      db,
      planImport(a, m),
      now: DateTime(2026, 10, 14, 22),
      lastDay: today,
    );
    final raw = await JournalRepository(db).loadJournal();
    Period p(int id, String n, Day s, Day? e, {bool away = false}) =>
        Period(id: id, name: n, start: s, end: e, away: away);
    final j = Journal(
      categories: raw.categories,
      entries: raw.entries,
      periods: [
        p(1, 'Before holidays', const Day(2026, 9, 8), const Day(2026, 9, 19)),
        p(
          2,
          'Porto',
          const Day(2026, 9, 20),
          const Day(2026, 9, 25),
          away: true,
        ),
        p(
          3,
          'Home',
          const Day(2026, 9, 26),
          const Day(2026, 9, 28),
          away: true,
        ),
        p(
          4,
          'Parents',
          const Day(2026, 9, 29),
          const Day(2026, 10, 6),
          away: true,
        ),
        p(5, 'Back at work', const Day(2026, 10, 7), null),
      ],
    );
    final all = allTime(j, today);
    expect(summary(j, all).average, closeTo(3.22, 0.005));
    expect(
      summary(j, const StatsRange(Day(2026, 9, 1), Day(2026, 9, 30))).average,
      closeTo(3.74, 0.005),
    );
    expect(
      summary(j, const StatsRange(Day(2026, 10, 1), today)).average,
      closeTo(2.36, 0.005),
    );

    final periods = periodSummary(j, all, today);
    expect(
      [for (final s in periods) s.average!.toStringAsFixed(2)],
      ['3.67', '4.00', '3.33', '3.13', '2.00'],
    );

    final comp = optionComparison(j, all);
    final health = comp.firstWhere((c) => c.category.name == 'Health');
    String avg(String n) => health.rows
        .firstWhere((r) => r.option?.name == n)
        .average
        .toStringAsFixed(2);
    expect(avg('walk'), '3.70');
    expect(avg('gym'), '2.17');

    expect(upsAndDowns(j, all).averageChange, closeTo(0.81, 0.005));
    expect(goodStretch(j, all)!.from, const Day(2026, 9, 18));
    expect(goodStretch(j, all)!.length, 7);
    expect(hardStretch(j, all)!.from, const Day(2026, 10, 9));
    expect(hardStretch(j, all)!.length, 3);

    final gym = j.categories
        .expand((c) => c.options)
        .firstWhere((o) => o.name == 'gym');
    final det = optionDetail(j, all, gym, today);
    expect(det.count, 6);
    expect(det.nextDayAverage, closeTo(2.5, 1e-9));
  }, skip: file.existsSync() ? false : 'no private backup');
}
