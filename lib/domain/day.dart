/// Calendar days — the unit everything in launenfuchs is keyed by.
///
/// An entry belongs to a **calendar date**, not an instant: it is stored as an
/// ISO `yyyy-mm-dd` key (design-concept §2.2, PLAN § Keys). A [Day] is that
/// date with no time and no zone, so DST and travel never shift a day.
class Day implements Comparable<Day> {
  const Day(this.year, this.month, this.day);

  /// The calendar date of [dateTime] in its own (local) fields.
  Day.of(DateTime dateTime)
    : year = dateTime.year,
      month = dateTime.month,
      day = dateTime.day;

  /// Parses an ISO `yyyy-mm-dd` key.
  factory Day.parse(String key) {
    final parts = key.split('-');
    if (parts.length != 3) throw FormatException('Not a day key', key);
    return Day(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  final int year;
  final int month;
  final int day;

  /// The ISO `yyyy-mm-dd` key stored in the database.
  String get key =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// Noon on this date, local time — a safe instant for date arithmetic and
  /// formatting (noon never falls into a DST gap).
  DateTime get noon => DateTime(year, month, day, 12);

  Day addDays(int days) => Day.of(DateTime(year, month, day + days, 12));

  /// Whole days from this day to [other] (negative if [other] is earlier).
  int daysUntil(Day other) => DateTime.utc(
    other.year,
    other.month,
    other.day,
  ).difference(DateTime.utc(year, month, day)).inDays;

  @override
  int compareTo(Day other) => key.compareTo(other.key);

  bool isBefore(Day other) => compareTo(other) < 0;
  bool isAfter(Day other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) =>
      other is Day &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => key;
}

/// The default hour a new day starts (design-concept §2.2): an entry made at
/// 00:40 is still about the evening before.
const defaultDayCutoffHour = 4;

/// The day a **new** entry made at [now] belongs to: before [cutoffHour] it is
/// still the previous day.
Day logicalDay(DateTime now, {int cutoffHour = defaultDayCutoffHour}) {
  assert(cutoffHour >= 0 && cutoffHour < 24);
  final today = Day.of(now);
  return now.hour < cutoffHour ? today.addDays(-1) : today;
}
