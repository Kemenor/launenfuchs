import 'package:flutter/material.dart';

import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../domain/mood.dart';
import '../../domain/stats.dart';
import '../mood_style.dart';

/// Hand-drawn charts (PLAN: no chart package). Mood marks use the mood scale
/// and sit on a labelled 1–5 axis, so position carries the value as well as
/// colour; period bands are amber 12 % (DESIGN_SYSTEM §1).

const amber = Color(0xFFE0A33B);

void paintIcon(
  Canvas c,
  IconData icon,
  Offset center,
  double size,
  Color color,
) {
  final tp = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: color,
        fontVariations: const [FontVariation('wght', 500)],
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

void paintText(
  Canvas c,
  String text,
  Offset at,
  TextStyle style, {
  TextAlign align = TextAlign.center,
  double maxWidth = double.infinity,
}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth);
  final dx = switch (align) {
    TextAlign.center => tp.width / 2,
    TextAlign.right || TextAlign.end => tp.width,
    _ => 0.0,
  };
  tp.paint(c, at - Offset(dx, tp.height / 2));
}

// --- Day by day ----------------------------------------------------------------

/// Dots per day on the mood axis, the 7-day average line, period bands with
/// labels, note rings. [onTapDay] gets the tapped day.
class DayByDayChart extends StatelessWidget {
  const DayByDayChart({
    super.key,
    required this.series,
    required this.periods,
    required this.today,
    required this.onTapDay,
    required this.tickLabel,
    this.onTapPeriod,
  });

  final List<DayPoint> series;
  final List<Period> periods;
  final Day today;
  final ValueChanged<Day> onTapDay;
  final ValueChanged<Period>? onTapPeriod;

  /// Locale-formatted date tick (painters don't format dates themselves).
  final String Function(Day) tickLabel;

  static const _left = 6.0, _right = 6.0, _top = 22.0, _bottom = 20.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, 200);
        final step = (size.width - _left - _right) / series.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final p = d.localPosition;
            if (p.dy < _top - 4 && onTapPeriod != null) {
              for (final per in periods) {
                final i0 = series.indexWhere((s) => !s.day.isBefore(per.start));
                if (i0 < 0) continue;
                final endDay = per.end ?? today;
                final i1 = series.lastIndexWhere((s) => !s.day.isAfter(endDay));
                if (p.dx >= _left + i0 * step &&
                    p.dx <= _left + (i1 + 1) * step) {
                  onTapPeriod!(per);
                  return;
                }
              }
            }
            final i = ((p.dx - _left) / step).floor().clamp(
              0,
              series.length - 1,
            );
            onTapDay(series[i].day);
          },
          child: CustomPaint(
            size: size,
            painter: _DayPainter(
              series: series,
              periods: periods,
              today: today,
              brightness: theme.brightness,
              grid: theme.colorScheme.outlineVariant,
              ink: theme.colorScheme.onSurface,
              muted: theme.colorScheme.onSurfaceVariant,
              tickLabel: tickLabel,
            ),
          ),
        );
      },
    );
  }
}

class _DayPainter extends CustomPainter {
  _DayPainter({
    required this.series,
    required this.periods,
    required this.today,
    required this.brightness,
    required this.grid,
    required this.ink,
    required this.muted,
    required this.tickLabel,
  });

  final List<DayPoint> series;
  final List<Period> periods;
  final Day today;
  final Brightness brightness;
  final Color grid, ink, muted;
  final String Function(Day) tickLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const l = DayByDayChart._left, r = DayByDayChart._right;
    const t = DayByDayChart._top, b = DayByDayChart._bottom;
    final n = series.length;
    final step = (size.width - l - r) / n;
    double x(int i) => l + (i + 0.5) * step;
    double y(num mood) => t + (5 - mood) * (size.height - t - b) / 4;
    final label = TextStyle(
      fontSize: 9.5,
      fontWeight: FontWeight.w700,
      color: muted,
    );

    // Period bands + labels.
    for (final p in periods) {
      final i0 = series.indexWhere((s) => !s.day.isBefore(p.start));
      final end = p.end ?? today;
      final i1 = series.lastIndexWhere((s) => !s.day.isAfter(end));
      if (i0 < 0 || i1 < i0) continue;
      final x0 = l + i0 * step, x1 = l + (i1 + 1) * step;
      if (p.away) {
        canvas.drawRect(
          Rect.fromLTRB(x0, t - 10, x1, size.height - b + 2),
          Paint()..color = amber.withValues(alpha: 0.13),
        );
      } else {
        canvas.drawLine(
          Offset(x0 + 1, t - 10),
          Offset(x1 - 1, t - 10),
          Paint()
            ..color = muted.withValues(alpha: 0.5)
            ..strokeWidth = 2,
        );
      }
      paintText(
        canvas,
        p.name,
        Offset((x0 + x1) / 2, 7),
        label,
        maxWidth: x1 - x0,
      );
    }

    // Grid.
    for (var m = 1; m <= 5; m++) {
      canvas.drawLine(
        Offset(l, y(m)),
        Offset(size.width - r, y(m)),
        Paint()..color = grid,
      );
    }

    // 7-day average.
    final path = Path();
    var started = false;
    for (var i = 0; i < n; i++) {
      final v = series[i].rolling;
      if (v == null) {
        started = false;
        continue;
      }
      if (!started) {
        path.moveTo(x(i), y(v));
        started = true;
      } else {
        path.lineTo(x(i), y(v));
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = ink.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots; faces when there's room.
    final radius = (step * 0.42).clamp(2.5, 8.0);
    final faces = radius >= 6;
    for (var i = 0; i < n; i++) {
      final e = series[i].entry;
      if (e == null) continue;
      final c = Offset(x(i), y(e.mood.value));
      if (e.hasNote) {
        canvas.drawCircle(
          c,
          radius + 3,
          Paint()
            ..color = const Color(0xFFEA7A24)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
      canvas.drawCircle(
        c,
        radius,
        Paint()..color = MoodStyle.color(e.mood, brightness),
      );
      if (faces) {
        paintIcon(
          canvas,
          MoodStyle.icon(e.mood),
          c,
          radius * 1.6,
          MoodStyle.onColor(brightness),
        );
      }
    }

    // Date ticks: first, middle, last.
    for (final i in {0, n ~/ 2, n - 1}) {
      paintText(
        canvas,
        tickLabel(series[i].day),
        Offset(x(i).clamp(l + 16, size.width - r - 16), size.height - 7),
        TextStyle(fontSize: 9.5, color: muted),
      );
    }
  }

  @override
  bool shouldRepaint(_DayPainter old) =>
      old.series != series ||
      old.periods != periods ||
      old.brightness != brightness;
}

// --- Comparison row ------------------------------------------------------------

/// One row of "mood alongside what you logged": a 1–5 track with the overall
/// average dashed and a lollipop from it to [value]; [hollow] for the
/// nothing-logged / not-tracked rows.
class ComparisonTrack extends StatelessWidget {
  const ComparisonTrack({
    super.key,
    required this.value,
    required this.overall,
    this.hollow = false,
  });

  final double value;
  final double overall;
  final bool hollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: const Size(double.infinity, 24),
      painter: _TrackPainter(
        value: value,
        overall: overall,
        hollow: hollow,
        brightness: theme.brightness,
        grid: theme.colorScheme.outlineVariant,
        muted: theme.colorScheme.onSurfaceVariant,
        surface: theme.colorScheme.surface,
      ),
    );
  }
}

double trackX(double width, num mood) => 6 + (mood - 1) / 4 * (width - 12);

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.value,
    required this.overall,
    required this.hollow,
    required this.brightness,
    required this.grid,
    required this.muted,
    required this.surface,
  });

  final double value, overall;
  final bool hollow;
  final Brightness brightness;
  final Color grid, muted, surface;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    for (var m = 1; m <= 5; m++) {
      final x = trackX(size.width, m);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()..color = grid,
      );
    }
    final ox = trackX(size.width, overall);
    for (var y = 0.0; y < size.height; y += 5) {
      canvas.drawLine(
        Offset(ox, y),
        Offset(ox, y + 2.5),
        Paint()
          ..color = muted
          ..strokeWidth = 1.2,
      );
    }
    final vx = trackX(size.width, value);
    if (hollow) {
      canvas.drawCircle(Offset(vx, cy), 5, Paint()..color = surface);
      canvas.drawCircle(
        Offset(vx, cy),
        5,
        Paint()
          ..color = muted
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      return;
    }
    final above = value >= overall;
    final lineColor = MoodStyle.color(above ? Mood.good : Mood.bad, brightness);
    final dotColor = MoodStyle.color(above ? Mood.rad : Mood.awful, brightness);
    canvas.drawLine(
      Offset(ox, cy),
      Offset(vx, cy),
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(vx, cy), 6.5, Paint()..color = surface);
    canvas.drawCircle(Offset(vx, cy), 5.5, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.value != value ||
      old.overall != overall ||
      old.brightness != brightness;
}

// --- Frequency strip (option detail) ------------------------------------------------

class FrequencyStrip extends StatelessWidget {
  const FrequencyStrip({
    super.key,
    required this.days,
    required this.journal,
    required this.marked,
  });

  final List<Day> days;
  final Journal journal;
  final Set<Day> marked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: const Size(double.infinity, 28),
      painter: _StripPainter(
        days: days,
        journal: journal,
        marked: marked,
        brightness: theme.brightness,
        empty: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
      ),
    );
  }
}

class _StripPainter extends CustomPainter {
  _StripPainter({
    required this.days,
    required this.journal,
    required this.marked,
    required this.brightness,
    required this.empty,
  });

  final List<Day> days;
  final Journal journal;
  final Set<Day> marked;
  final Brightness brightness;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width / days.length;
    final gap = w > 4 ? 1.5 : 0.0;
    for (var i = 0; i < days.length; i++) {
      final e = journal.entryOn(days[i]);
      final on = marked.contains(days[i]) && e != null;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * w + gap / 2, 0, w - gap, size.height),
          const Radius.circular(3),
        ),
        Paint()..color = on ? MoodStyle.color(e.mood, brightness) : empty,
      );
    }
  }

  @override
  bool shouldRepaint(_StripPainter old) =>
      old.days != days || old.marked != marked;
}

// --- Year in pixels ---------------------------------------------------------------

class YearPixels extends StatelessWidget {
  const YearPixels({
    super.key,
    required this.year,
    required this.journal,
    required this.onTapDay,
    required this.monthInitials,
  });

  final int year;
  final Journal journal;
  final ValueChanged<Day> onTapDay;

  /// Twelve locale month initials (DateFormat.MMMMM).
  final List<String> monthInitials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        const labelW = 18.0;
        final cell = (box.maxWidth - labelW) / 31;
        return GestureDetector(
          onTapUp: (d) {
            final m = (d.localPosition.dy / cell).floor() + 1;
            final day = ((d.localPosition.dx - labelW) / cell).floor() + 1;
            if (m < 1 || m > 12 || day < 1) return;
            if (day > DateTime(year, m + 1, 0).day) return;
            final target = Day(year, m, day);
            if (journal.entryOn(target) != null) onTapDay(target);
          },
          child: CustomPaint(
            size: Size(box.maxWidth, cell * 12),
            painter: _PixelPainter(
              year: year,
              journal: journal,
              cell: cell,
              labelW: labelW,
              brightness: theme.brightness,
              empty: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
              muted: theme.colorScheme.onSurfaceVariant,
              initials: monthInitials,
            ),
          ),
        );
      },
    );
  }
}

class _PixelPainter extends CustomPainter {
  _PixelPainter({
    required this.year,
    required this.journal,
    required this.cell,
    required this.labelW,
    required this.brightness,
    required this.empty,
    required this.muted,
    required this.initials,
  });

  final int year;
  final Journal journal;
  final double cell, labelW;
  final Brightness brightness;
  final Color empty, muted;
  final List<String> initials;

  @override
  void paint(Canvas canvas, Size size) {
    for (var m = 1; m <= 12; m++) {
      final y = (m - 1) * cell;
      paintText(
        canvas,
        initials[m - 1],
        Offset(labelW / 2, y + cell / 2),
        TextStyle(fontSize: 9, color: muted, fontWeight: FontWeight.w700),
      );
      final days = DateTime(year, m + 1, 0).day;
      for (var d = 1; d <= days; d++) {
        final e = journal.entryOn(Day(year, m, d));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              labelW + (d - 1) * cell + 0.75,
              y + 0.75,
              cell - 1.5,
              cell - 1.5,
            ),
            Radius.circular(cell * 0.2),
          ),
          Paint()
            ..color = e == null ? empty : MoodStyle.color(e.mood, brightness),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPainter old) =>
      old.journal != journal || old.year != year;
}
