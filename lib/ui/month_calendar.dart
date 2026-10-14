import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/day.dart';
import '../domain/journal.dart';
import '../l10n/app_localizations.dart';
import 'mood_style.dart';

/// The Journal's month grid (DESIGN_SYSTEM §2.1): each logged day a mood face,
/// today tinted orange, future days faded and inert. Week starts on the
/// locale's first day.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.journal,
    required this.today,
    required this.onTapDay,
  });

  final int year;
  final int month;
  final Journal journal;
  final Day today;
  final ValueChanged<Day> onTapDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final first = material.firstDayOfWeekIndex; // 0 = Sunday
    final firstOfMonth = Day(year, month, 1);
    // DateTime.weekday: Mon = 1 … Sun = 7 → 0 = Sunday.
    final lead = (firstOfMonth.noon.weekday % 7 - first + 7) % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekdays = [
      for (var i = 0; i < 7; i++) material.narrowWeekdays[(first + i) % 7],
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Text(
                  w,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.82,
          children: [
            for (var i = 0; i < lead; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              _DayCell(
                day: Day(year, month, d),
                entry: journal.entryOn(Day(year, month, d)),
                isToday: Day(year, month, d) == today,
                isFuture: Day(year, month, d).isAfter(today),
                semantics: (mood) => l10n.calendarDayLabel(
                  DateFormat.MMMMd(locale).format(Day(year, month, d).noon),
                  mood,
                ),
                onTap: onTapDay,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.entry,
    required this.isToday,
    required this.isFuture,
    required this.semantics,
    required this.onTap,
  });

  final Day day;
  final Entry? entry;
  final bool isToday;
  final bool isFuture;
  final String Function(String mood) semantics;
  final ValueChanged<Day> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final e = entry;
    return Opacity(
      opacity: isFuture ? 0.35 : 1,
      child: Semantics(
        button: !isFuture,
        label: semantics(e == null ? '–' : MoodStyle.label(e.mood, l10n)),
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isFuture ? null : () => onTap(day),
          child: Ink(
            decoration: BoxDecoration(
              color: isToday ? scheme.primary.withValues(alpha: 0.12) : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                e == null
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.onSurfaceVariant.withValues(
                            alpha: 0.12,
                          ),
                        ),
                      )
                    : MoodFace(e.mood, size: 24),
                const SizedBox(height: 3),
                Text(
                  '${day.day}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.w800 : null,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
