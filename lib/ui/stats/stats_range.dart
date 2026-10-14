import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../domain/stats.dart';

/// The Stats tab's range choice (design-concept §5): last 30 days · a month
/// (stepped with ‹ ›) · a year · all · one period.
enum RangeKind { days30, month, year, all, period }

class RangeChoice {
  const RangeChoice(this.kind, {this.offset = 0, this.periodId});

  final RangeKind kind;

  /// Months / years back from the current one (0 = current).
  final int offset;
  final int? periodId;

  /// The concrete range for [journal] as of [today].
  StatsRange resolve(Journal journal, Day today) {
    switch (kind) {
      case RangeKind.days30:
        return StatsRange(today.addDays(-29), today);
      case RangeKind.month:
        final first = DateTime(today.year, today.month - offset, 1);
        final last = DateTime(first.year, first.month + 1, 0);
        final to = Day.of(last).isAfter(today) ? today : Day.of(last);
        return StatsRange(Day.of(first), to);
      case RangeKind.year:
        final y = today.year - offset;
        final to = y == today.year ? today : Day(y, 12, 31);
        return StatsRange(Day(y, 1, 1), to);
      case RangeKind.all:
        return allTime(journal, today);
      case RangeKind.period:
        for (final p in journal.periods) {
          if (p.id == periodId) {
            final end = p.end ?? today;
            return StatsRange(p.start, end.isAfter(today) ? today : end);
          }
        }
        return allTime(journal, today);
    }
  }
}

class RangeController extends Notifier<RangeChoice> {
  @override
  RangeChoice build() => const RangeChoice(RangeKind.days30);

  void set(RangeChoice c) => state = c;
}

final statsRangeProvider = NotifierProvider<RangeController, RangeChoice>(
  RangeController.new,
);
