import 'category.dart';
import 'day.dart';
import 'journal.dart';
import 'mood.dart';

/// The stats engine (design-concept §4–§5): pure functions of a [Journal]
/// and a [StatsRange]. No Flutter, no I/O — every number on the Stats tab and
/// in the report comes from here, so the golden tests pin them.

/// An inclusive range of calendar days.
class StatsRange {
  const StatsRange(this.from, this.to);

  final Day from;
  final Day to;

  bool contains(Day d) => !d.isBefore(from) && !d.isAfter(to);
  int get length => from.daysUntil(to) + 1;

  Iterable<Day> get days sync* {
    for (var d = from; !d.isAfter(to); d = d.addDays(1)) {
      yield d;
    }
  }

  /// The equally long range right before this one (for "vs. previous").
  StatsRange get previous =>
      StatsRange(from.addDays(-length), from.addDays(-1));

  @override
  bool operator ==(Object other) =>
      other is StatsRange && other.from == from && other.to == to;
  @override
  int get hashCode => Object.hash(from, to);
}

double? mean(Iterable<num> xs) {
  var n = 0;
  var s = 0.0;
  for (final x in xs) {
    n++;
    s += x;
  }
  return n == 0 ? null : s / n;
}

/// Entries inside [r], oldest first.
List<Entry> entriesIn(Journal j, StatsRange r) => [
  for (final e in j.entries.reversed)
    if (r.contains(e.day)) e,
];

/// The whole journal as a range (first entry … [today]).
StatsRange allTime(Journal j, Day today) =>
    StatsRange(j.entries.isEmpty ? today : j.entries.last.day, today);

// --- Summary -----------------------------------------------------------------

class Summary {
  const Summary({
    required this.average,
    required this.daysLogged,
    required this.daysInRange,
    required this.best,
    required this.worst,
  });

  final double? average;
  final int daysLogged;
  final int daysInRange;

  /// Entries with the highest / lowest mood in range (ties: all of them).
  final List<Entry> best;
  final List<Entry> worst;
}

Summary summary(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  if (es.isEmpty) {
    return Summary(
      average: null,
      daysLogged: 0,
      daysInRange: r.length,
      best: const [],
      worst: const [],
    );
  }
  final hi = es.map((e) => e.mood.value).reduce((a, b) => a > b ? a : b);
  final lo = es.map((e) => e.mood.value).reduce((a, b) => a < b ? a : b);
  return Summary(
    average: mean(es.map((e) => e.mood.value)),
    daysLogged: es.length,
    daysInRange: r.length,
    best: [
      for (final e in es)
        if (e.mood.value == hi) e,
    ],
    worst: [
      for (final e in es)
        if (e.mood.value == lo) e,
    ],
  );
}

// --- Day by day ----------------------------------------------------------------

class DayPoint {
  const DayPoint(this.day, this.entry, this.rolling);
  final Day day;
  final Entry? entry;

  /// Mean of the logged days among the trailing 7 calendar days (this one
  /// included); null when none of them is logged.
  final double? rolling;
}

List<DayPoint> daySeries(Journal j, StatsRange r) => [
  for (final d in r.days)
    DayPoint(
      d,
      j.entryOn(d),
      mean([
        for (var k = 0; k < 7; k++)
          if (j.entryOn(d.addDays(-k)) case final e?) e.mood.value,
      ]),
    ),
];

// --- Mood alongside what you logged (§4.4) -------------------------------------

enum RowKind { option, nothingLogged, notTracked }

class ComparisonRow {
  const ComparisonRow({
    required this.kind,
    required this.average,
    required this.count,
    this.option,
  });

  final RowKind kind;
  final OptionItem? option;
  final double average;
  final int count;
}

class CategoryComparison {
  const CategoryComparison(this.category, this.rows);
  final Category category;
  final List<ComparisonRow> rows;
}

/// One group per category with data in range: each option's average on the
/// days it was logged (`n` = days), then the *nothing logged* and *not
/// tracked* rows (§4.3). Rows with no days are left out; the `minN` filter
/// is the view's job.
List<CategoryComparison> optionComparison(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  final out = <CategoryComparison>[];
  for (final c in j.categories) {
    final rows = <ComparisonRow>[];
    for (final o in c.options) {
      final ms = [
        for (final e in es)
          if (e.optionIds.contains(o.id)) e.mood.value,
      ];
      if (ms.isNotEmpty) {
        rows.add(
          ComparisonRow(
            kind: RowKind.option,
            option: o,
            average: mean(ms)!,
            count: ms.length,
          ),
        );
      }
    }
    if (rows.isEmpty) continue;
    final ids = {for (final o in c.options) o.id};
    final nothing = <int>[];
    final untracked = <int>[];
    for (final e in es) {
      if (!c.tracks(e.day)) {
        untracked.add(e.mood.value);
      } else if (!e.optionIds.any(ids.contains)) {
        nothing.add(e.mood.value);
      }
    }
    if (nothing.isNotEmpty) {
      rows.add(
        ComparisonRow(
          kind: RowKind.nothingLogged,
          average: mean(nothing)!,
          count: nothing.length,
        ),
      );
    }
    if (untracked.isNotEmpty) {
      rows.add(
        ComparisonRow(
          kind: RowKind.notTracked,
          average: mean(untracked)!,
          count: untracked.length,
        ),
      );
    }
    out.add(CategoryComparison(c, rows));
  }
  return out;
}

// --- Weekday -------------------------------------------------------------------

class WeekdayMean {
  const WeekdayMean(this.weekday, this.average, this.count);

  /// DateTime.weekday: Monday = 1 … Sunday = 7.
  final int weekday;
  final double? average;
  final int count;
}

List<WeekdayMean> weekdayMeans(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  return [
    for (var w = 1; w <= 7; w++)
      () {
        final ms = [
          for (final e in es)
            if (e.day.noon.weekday == w) e.mood.value,
        ];
        return WeekdayMean(w, mean(ms), ms.length);
      }(),
  ];
}

/// Under this spread between the best and worst weekday the tile just says
/// "no weekday pattern" (§5.2).
const weekdayPatternThreshold = 0.5;

// --- Periods ---------------------------------------------------------------------

class PeriodSlice {
  const PeriodSlice({
    required this.period,
    required this.entries,
    required this.counts,
  });

  /// Null = "outside any period".
  final Period? period;
  final List<Entry> entries;

  /// Days per mood value (1…5).
  final Map<int, int> counts;

  double? get average => mean(entries.map((e) => e.mood.value));
}

/// One slice per period overlapping [r] (in start order), then the days in
/// range outside every period — if there are any and any periods at all.
List<PeriodSlice> periodSummary(Journal j, StatsRange r, Day today) {
  final es = entriesIn(j, r);
  PeriodSlice slice(Period? p, List<Entry> list) => PeriodSlice(
    period: p,
    entries: list,
    counts: {
      for (var v = 1; v <= 5; v++)
        v: list.where((e) => e.mood.value == v).length,
    },
  );
  final out = <PeriodSlice>[];
  for (final p in j.periods) {
    final list = [
      for (final e in es)
        if (p.contains(e.day, today: today)) e,
    ];
    if (list.isNotEmpty) out.add(slice(p, list));
  }
  if (j.periods.isNotEmpty) {
    final outside = [
      for (final e in es)
        if (!j.periods.any((p) => p.contains(e.day, today: today))) e,
    ];
    if (outside.isNotEmpty) out.add(slice(null, outside));
  }
  return out;
}

/// Periods visible in [r] (for chart bands).
List<Period> periodsIn(Journal j, StatsRange r, Day today) => [
  for (final p in j.periods)
    if (!p.start.isAfter(r.to) && !(p.end ?? today).isBefore(r.from)) p,
];

// --- Notes ---------------------------------------------------------------------------

List<Entry> notesIn(Journal j, StatsRange r) => [
  for (final e in j.entries)
    if (r.contains(e.day) && e.hasNote) e,
];

// --- Counts ------------------------------------------------------------------------

Map<Mood, int> moodCounts(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  return {for (final m in Mood.values) m: es.where((e) => e.mood == m).length};
}

class OptionCount {
  const OptionCount(this.option, this.count);
  final OptionItem option;
  final int count;
}

/// Options by how often they were logged in range, most first.
List<OptionCount> optionCounts(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  final out = <OptionCount>[];
  for (final c in j.categories) {
    for (final o in c.options) {
      final n = es.where((e) => e.optionIds.contains(o.id)).length;
      if (n > 0) out.add(OptionCount(o, n));
    }
  }
  out.sort((a, b) => b.count.compareTo(a.count));
  return out;
}

/// Days per category with at least one of its options.
Map<Category, int> categoryCounts(Journal j, StatsRange r) {
  final es = entriesIn(j, r);
  return {
    for (final c in j.categories)
      c: es
          .where((e) => c.options.any((o) => e.optionIds.contains(o.id)))
          .length,
  };
}

/// The options most often logged on days of [mood], most first.
List<OptionCount> oftenTogether(Journal j, StatsRange r, Mood mood) {
  final es = [
    for (final e in entriesIn(j, r))
      if (e.mood == mood) e,
  ];
  final counts = <int, int>{};
  for (final e in es) {
    for (final id in e.optionIds) {
      counts[id] = (counts[id] ?? 0) + 1;
    }
  }
  final out = [
    for (final MapEntry(key: id, value: n) in counts.entries)
      if (j.option(id) case final o?) OptionCount(o, n),
  ]..sort((a, b) => b.count.compareTo(a.count));
  return out;
}

// --- Ups and downs ------------------------------------------------------------------

class UpsAndDowns {
  const UpsAndDowns({
    required this.averageChange,
    required this.pairs,
    required this.biggestDrops,
  });

  /// Mean absolute step between consecutive calendar days that are both
  /// logged; null with fewer than one such pair.
  final double? averageChange;
  final int pairs;

  /// Days whose mood fell the most from the day before (largest drop first;
  /// only the drop size shared by the top entries — never padded with
  /// smaller ones).
  final List<(Entry from, Entry to)> biggestDrops;
}

UpsAndDowns upsAndDowns(Journal j, StatsRange r) {
  final steps = <int>[];
  final drops = <(Entry, Entry, int)>[];
  for (final e in entriesIn(j, r)) {
    final prev = j.entryOn(e.day.addDays(-1));
    if (prev == null || !r.contains(prev.day)) continue;
    final d = e.mood.value - prev.mood.value;
    steps.add(d.abs());
    if (d < 0) drops.add((prev, e, d));
  }
  drops.sort((a, b) => a.$3.compareTo(b.$3));
  final worst = drops.isEmpty ? 0 : drops.first.$3;
  return UpsAndDowns(
    averageChange: mean(steps),
    pairs: steps.length,
    biggestDrops: [
      for (final (a, b, d) in drops)
        if (d == worst && d <= -2) (a, b),
    ],
  );
}

// --- Good and hard stretches -----------------------------------------------------------

class Stretch {
  const Stretch(this.from, this.to);
  final Day from;
  final Day to;
  int get length => from.daysUntil(to) + 1;
}

/// The longest run of consecutive calendar days, all logged, whose mood
/// satisfies [test]; null if none. Ties: the most recent.
Stretch? longestStretch(Journal j, StatsRange r, bool Function(Mood) test) {
  Stretch? best;
  Day? start;
  Day? last;
  for (final d in r.days) {
    final e = j.entryOn(d);
    if (e != null && test(e.mood)) {
      start ??= d;
      last = d;
      final s = Stretch(start, last);
      if (best == null || s.length >= best.length) best = s;
    } else {
      start = null;
    }
  }
  return best;
}

Stretch? goodStretch(Journal j, StatsRange r) =>
    longestStretch(j, r, (m) => m.value >= Mood.good.value);
Stretch? hardStretch(Journal j, StatsRange r) =>
    longestStretch(j, r, (m) => m.value <= Mood.bad.value);

/// The options logged most often during [s].
List<OptionCount> optionsDuring(Journal j, Stretch s, {int top = 3}) {
  return optionCounts(j, StatsRange(s.from, s.to)).take(top).toList();
}

// --- Option detail (§5.3) -------------------------------------------------------------

class OptionDetail {
  const OptionDetail({
    required this.option,
    required this.days,
    required this.count,
    required this.previousCount,
    required this.average,
    required this.nextDayAverage,
    required this.nextDayCount,
    required this.overallAverage,
    required this.weekdayCounts,
    required this.together,
    required this.byPeriod,
    required this.longestWith,
    required this.longestWithout,
  });

  final OptionItem option;

  /// Days of the range with it (for the frequency strip).
  final Set<Day> days;
  final int count;
  final int previousCount;
  final double? average;
  final double? nextDayAverage;
  final int nextDayCount;
  final double? overallAverage;

  /// Monday = index 0.
  final List<int> weekdayCounts;

  /// Other options on its days, with the share of its days (0…1).
  final List<(OptionItem, double)> together;
  final List<(Period, int)> byPeriod;
  final int longestWith;
  final int longestWithout;
}

OptionDetail optionDetail(
  Journal j,
  StatsRange r,
  OptionItem option,
  Day today,
) {
  final es = entriesIn(j, r);
  final withIt = [
    for (final e in es)
      if (e.optionIds.contains(option.id)) e,
  ];
  final prev = entriesIn(
    j,
    r.previous,
  ).where((e) => e.optionIds.contains(option.id)).length;
  final next = [
    for (final e in withIt)
      if (j.entryOn(e.day.addDays(1)) case final n?) n.mood.value,
  ];
  final co = <int, int>{};
  for (final e in withIt) {
    for (final id in e.optionIds) {
      if (id != option.id) co[id] = (co[id] ?? 0) + 1;
    }
  }
  final together = [
    for (final MapEntry(key: id, value: n) in co.entries)
      if (j.option(id) case final o?) (o, n / withIt.length),
  ]..sort((a, b) => b.$2.compareTo(a.$2));

  // Runs over logged days the option's category tracked.
  final category = j.categoryOfOption(option.id);
  var bestWith = 0, bestWithout = 0, curWith = 0, curWithout = 0;
  for (final d in r.days) {
    final e = j.entryOn(d);
    if (e == null || (category != null && !category.tracks(d))) {
      curWith = 0;
      curWithout = 0;
      continue;
    }
    if (e.optionIds.contains(option.id)) {
      curWith++;
      curWithout = 0;
    } else {
      curWithout++;
      curWith = 0;
    }
    if (curWith > bestWith) bestWith = curWith;
    if (curWithout > bestWithout) bestWithout = curWithout;
  }

  return OptionDetail(
    option: option,
    days: {for (final e in withIt) e.day},
    count: withIt.length,
    previousCount: prev,
    average: mean(withIt.map((e) => e.mood.value)),
    nextDayAverage: mean(next),
    nextDayCount: next.length,
    overallAverage: mean(es.map((e) => e.mood.value)),
    weekdayCounts: [
      for (var w = 1; w <= 7; w++)
        withIt.where((e) => e.day.noon.weekday == w).length,
    ],
    together: together,
    byPeriod: [
      for (final p in periodsIn(j, r, today))
        (p, withIt.where((e) => p.contains(e.day, today: today)).length),
    ],
    longestWith: bestWith,
    longestWithout: bestWithout,
  );
}

/// Whether [c] is shown as one-per-day in comparisons (§4.4).
bool comparesWithEachOther(Category c) => c.mode == CategoryMode.one;
