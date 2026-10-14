import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/reminder.dart';

void main() {
  test('today is skipped once logged; past times are skipped', () {
    final now = DateTime(2026, 10, 14, 19, 30);
    var t = reminderTimes(now: now, minutes: 20 * 60, logged: {}, horizon: 3);
    expect(t.first, DateTime(2026, 10, 14, 20));
    t = reminderTimes(
      now: now,
      minutes: 20 * 60,
      logged: {const Day(2026, 10, 14)},
      horizon: 3,
    );
    expect(t.first, DateTime(2026, 10, 15, 20));
    t = reminderTimes(
      now: DateTime(2026, 10, 14, 21),
      minutes: 20 * 60,
      logged: {},
      horizon: 3,
    );
    expect(t.first, DateTime(2026, 10, 15, 20));
    expect(t, hasLength(2));
  });
}
