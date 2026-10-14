import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/day.dart';
import '../domain/journal.dart';
import '../l10n/app_localizations.dart';
import 'mood_style.dart';
import 'stats/charts.dart' show amber;

/// The Journal's month grid (DESIGN_SYSTEM §2.1): each logged day a mood
/// face, today tinted orange, future days faded and inert, periods as a band
/// under their days. **Long-press a day and drag** to select a range →
/// [onSelectRange] (the new-period gesture, §2.5). Week starts on the
/// locale's first day.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.journal,
    required this.today,
    required this.onTapDay,
    this.onSelectRange,
  });

  final int year;
  final int month;
  final Journal journal;
  final Day today;
  final ValueChanged<Day> onTapDay;
  final void Function(Day from, Day to)? onSelectRange;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  Day? _anchor;
  Day? _end;

  static const _aspect = 0.82; // cell width / height

  int _lead(BuildContext context) {
    final first = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final weekday = Day(widget.year, widget.month, 1).noon.weekday % 7; // Sun 0
    return (weekday - first + 7) % 7;
  }

  Day? _dayAt(Offset p, double width, int lead) {
    final cw = width / 7, ch = cw / _aspect;
    final col = (p.dx / cw).floor(), row = (p.dy / ch).floor();
    if (col < 0 || col > 6 || row < 0) return null;
    final d = row * 7 + col - lead + 1;
    final last = DateTime(widget.year, widget.month + 1, 0).day;
    if (d < 1 || d > last) return null;
    final day = Day(widget.year, widget.month, d);
    return day.isAfter(widget.today) ? null : day;
  }

  bool _selected(Day d) {
    if (_anchor == null || _end == null) return false;
    final a = _anchor!.isBefore(_end!) ? _anchor! : _end!;
    final b = _anchor!.isBefore(_end!) ? _end! : _anchor!;
    return !d.isBefore(a) && !d.isAfter(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    final first = material.firstDayOfWeekIndex;
    final lead = _lead(context);
    final daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;
    final rows = ((lead + daysInMonth) / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Text(
                  material.narrowWeekdays[(first + i) % 7],
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
        LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final ch = w / 7 / _aspect;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                final day = _dayAt(d.localPosition, w, lead);
                if (day != null) widget.onTapDay(day);
              },
              onLongPressStart: widget.onSelectRange == null
                  ? null
                  : (d) {
                      final day = _dayAt(d.localPosition, w, lead);
                      if (day != null) setState(() => _anchor = _end = day);
                    },
              onLongPressMoveUpdate: (d) {
                if (_anchor == null) return;
                final day = _dayAt(d.localPosition, w, lead);
                if (day != null && day != _end) setState(() => _end = day);
              },
              onLongPressEnd: (_) {
                final a = _anchor, b = _end;
                setState(() => _anchor = _end = null);
                if (a == null || b == null) return;
                widget.onSelectRange?.call(
                  a.isBefore(b) ? a : b,
                  a.isBefore(b) ? b : a,
                );
              },
              child: SizedBox(
                height: ch * rows,
                child: Column(
                  children: [
                    for (var r = 0; r < rows; r++)
                      SizedBox(
                        height: ch,
                        child: Row(
                          children: [
                            for (var c = 0; c < 7; c++)
                              Expanded(
                                child: _cell(
                                  context,
                                  r * 7 + c - lead + 1,
                                  daysInMonth,
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, int d, int daysInMonth) {
    if (d < 1 || d > daysInMonth) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final day = Day(widget.year, widget.month, d);
    final e = widget.journal.entryOn(day);
    final isToday = day == widget.today;
    final isFuture = day.isAfter(widget.today);
    final selected = _selected(day);
    Period? band;
    for (final p in widget.journal.periods) {
      if (p.contains(day, today: widget.today)) {
        band = p;
        break;
      }
    }
    // Band ends round off at the period's ends and at the row edges.
    final fw = MaterialLocalizations.of(context).firstDayOfWeekIndex; // 0 = Sun
    final weekStart = fw == 0 ? DateTime.sunday : fw;
    final weekEnd = weekStart == DateTime.monday
        ? DateTime.sunday
        : weekStart - 1;
    final bandStarts =
        band != null && (band.start == day || day.noon.weekday == weekStart);
    final bandEnds =
        band != null &&
        ((band.end ?? widget.today) == day || day.noon.weekday == weekEnd);

    return Opacity(
      opacity: isFuture ? 0.35 : 1,
      child: Semantics(
        button: !isFuture,
        label: l10n.calendarDayLabel(
          DateFormat.MMMMd(locale).format(day.noon),
          e == null ? '–' : MoodStyle.label(e.mood, l10n),
        ),
        excludeSemantics: true,
        child: Container(
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.18)
                : isToday
                ? scheme.primary.withValues(alpha: 0.12)
                : null,
            borderRadius: BorderRadius.circular(selected ? 4 : 12),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      '$d',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isToday
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: isToday ? FontWeight.w800 : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              if (band != null)
                Positioned(
                  left: bandStarts ? 4 : 0,
                  right: bandEnds ? 4 : 0,
                  bottom: 2,
                  height: 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: band.away
                          ? amber.withValues(alpha: 0.6)
                          : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(bandStarts ? 2 : 0),
                        right: Radius.circular(bandEnds ? 2 : 0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
