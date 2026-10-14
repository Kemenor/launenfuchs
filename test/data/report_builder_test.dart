import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/report/report_pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:launenfuchs/data/report/report_builder.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/journal.dart';
import 'package:launenfuchs/domain/mood.dart';
import 'package:launenfuchs/domain/stats.dart';

import '../support/fixtures.dart';

ReportText text() => ReportText(
  title: 'Mood report',
  rangeLabel: 'Sep 15 – Sep 21',
  generated: 'Created with Launenfuchs',
  moodLabels: const ['awful', 'bad', 'meh', 'good', 'rad'],
  summary: 'Summary',
  average: 'average',
  daysLogged: 'days logged',
  bestDay: 'best day',
  hardestDay: 'hardest day',
  dayByDay: 'Mood, day by day',
  dayByDayHint: 'hint',
  byPeriod: 'By period',
  outsidePeriod: 'Outside any period',
  alongside: 'Mood alongside what you logged',
  alongsideHint: 'hint',
  nothingLogged: 'nothing logged',
  notTracked: 'not tracked',
  caveat: 'not cause and effect',
  weekday: 'Weekday',
  weekdayNames: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  notes: 'Notes',
  nothingInRange: 'Nothing logged',
  formatDay: (d) => d.key,
  formatShortDay: (d) => d.key,
  modeOne: 'one per day',
  modeAny: 'any number',
);

void main() {
  const d0 = Day(2026, 9, 15);
  final j = Journal(
    categories: journalOf([]).categories,
    entries: [
      entry(d0, Mood.good, {11, 21}),
      entry(d0.addDays(1), Mood.meh, {11, 21}, 'a <private> note & more'),
      entry(d0.addDays(2), Mood.bad, {12}),
    ],
    periods: [
      Period(id: 1, name: 'Trip', start: d0, end: d0.addDays(1), away: true),
    ],
  );
  final r = StatsRange(d0, d0.addDays(6));

  test('a self-contained document with the engine numbers', () {
    final html = buildReportHtml(
      j,
      d0.addDays(6),
      ReportOptions(range: r),
      text(),
    );
    expect(html, startsWith('<!doctype html>'));
    expect(html, isNot(contains('<script')));
    expect(html, isNot(contains('http')), reason: 'no external requests');
    expect(html, contains('3.0 / 5'), reason: 'average of 4, 3, 2');
    expect(html, contains('3 / 7'));
    expect(html, contains('Trip'));
    expect(html, contains('not cause and effect'));
    expect(html, contains('<svg'));
  });

  test('notes stay out unless asked for — and are escaped when in', () {
    var html = buildReportHtml(
      j,
      d0.addDays(6),
      ReportOptions(range: r),
      text(),
    );
    expect(html, isNot(contains('private')));
    html = buildReportHtml(
      j,
      d0.addDays(6),
      ReportOptions(range: r, includeNotes: true),
      text(),
    );
    expect(html, contains('a &lt;private&gt; note &amp; more'));
  });

  test('an empty range says so', () {
    final html = buildReportHtml(
      j,
      d0.addDays(30),
      ReportOptions(range: StatsRange(d0.addDays(20), d0.addDays(30))),
      text(),
    );
    expect(html, contains('Nothing logged'));
  });

  test('the PDF builds with the bundled fonts and the same sections', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Future<pw.Font> font(String f) async =>
        pw.Font.ttf(await rootBundle.load('packages/fuchsbau/assets/fonts/$f'));
    final pdf = await buildReportPdf(
      j,
      d0.addDays(6),
      ReportOptions(range: r, includeNotes: true),
      text(),
      regular: await font('AtkinsonHyperlegible-Regular.ttf'),
      bold: await font('AtkinsonHyperlegible-Bold.ttf'),
    );
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(pdf.length, greaterThan(5000));
    // Kept for eyeballing (gitignored folder).
    if (Directory('test/private').existsSync()) {
      File('test/private/report_sample.pdf').writeAsBytesSync(pdf);
    }
  });
}
