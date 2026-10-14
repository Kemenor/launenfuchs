import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/domain/day.dart';

void main() {
  group('Day', () {
    test('key is zero-padded ISO and round-trips', () {
      const d = Day(2026, 3, 7);
      expect(d.key, '2026-03-07');
      expect(Day.parse(d.key), d);
    });

    test('addDays crosses month and year ends', () {
      expect(const Day(2026, 9, 30).addDays(1), const Day(2026, 10, 1));
      expect(const Day(2026, 12, 31).addDays(1), const Day(2027, 1, 1));
      expect(const Day(2026, 3, 1).addDays(-1), const Day(2026, 2, 28));
    });

    test('addDays is not shifted by a DST change', () {
      // Europe switches on the last Sunday of March / October; a day is a
      // date, so stepping over either must land on the next date.
      expect(const Day(2026, 3, 28).addDays(2), const Day(2026, 3, 30));
      expect(const Day(2026, 10, 24).addDays(2), const Day(2026, 10, 26));
    });

    test('daysUntil and ordering', () {
      expect(const Day(2026, 9, 8).daysUntil(const Day(2026, 10, 14)), 36);
      expect(const Day(2026, 9, 8).isBefore(const Day(2026, 10, 1)), isTrue);
      expect(const Day(2026, 10, 1).isAfter(const Day(2026, 9, 30)), isTrue);
    });

    test('parse rejects malformed keys', () {
      expect(() => Day.parse('2026-10'), throwsFormatException);
    });
  });

  group('logicalDay (the late-night cut-off)', () {
    test('before the cut-off it is still yesterday', () {
      expect(
        logicalDay(DateTime(2026, 10, 14, 0, 40)),
        const Day(2026, 10, 13),
      );
      expect(
        logicalDay(DateTime(2026, 10, 14, 3, 59)),
        const Day(2026, 10, 13),
      );
    });

    test('from the cut-off on it is today', () {
      expect(logicalDay(DateTime(2026, 10, 14, 4)), const Day(2026, 10, 14));
      expect(
        logicalDay(DateTime(2026, 10, 14, 21, 11)),
        const Day(2026, 10, 14),
      );
    });

    test('the cut-off hour is a setting', () {
      final late = DateTime(2026, 10, 14, 1, 30);
      expect(logicalDay(late, cutoffHour: 0), const Day(2026, 10, 14));
      expect(logicalDay(late, cutoffHour: 2), const Day(2026, 10, 13));
    });

    test('the first of a month rolls back into the previous month', () {
      expect(logicalDay(DateTime(2026, 10, 1, 2)), const Day(2026, 9, 30));
    });
  });
}
