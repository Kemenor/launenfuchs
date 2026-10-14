import 'day.dart';

/// When the daily reminder fires (design-concept §2.8): at [minutes] after
/// midnight on each of the next [horizon] days, **skipping days already
/// logged** and times already past. The schedule is re-filled on every app
/// start and every change, so a week ahead is plenty; if the app isn't
/// opened for longer the reminders simply run out — never nag.
List<DateTime> reminderTimes({
  required DateTime now,
  required int minutes,
  required Set<Day> logged,
  int horizon = 14,
}) {
  final out = <DateTime>[];
  final start = Day.of(now);
  for (var i = 0; i < horizon; i++) {
    final d = start.addDays(i);
    if (logged.contains(d)) continue;
    final at = DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
    if (!at.isAfter(now)) continue;
    out.add(at);
  }
  return out;
}
