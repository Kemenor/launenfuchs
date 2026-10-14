import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import 'mood_style.dart';

/// A one-per-day category shown as a stepped slider (DESIGN_SYSTEM §2.2).
///
/// Unlike Material's slider it has a real **unset** state — faded track, no
/// thumb — because an untouched slider must mean *nothing logged*, never the
/// leftmost option. [pending] draws a pending default in neutral. More than
/// five stops: only the end labels show (the category header carries the
/// value).
class StepSlider extends StatelessWidget {
  const StepSlider({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    required this.onClear,
    this.pending = false,
  });

  final List<String> labels;
  final int? selected;
  final bool pending;
  final ValueChanged<int> onChanged;
  final VoidCallback onClear;

  static const _trackHeight = 36.0;
  static const _inset = 12.0; // first/last stop sit this far in

  int _indexAt(double dx, double width) {
    final usable = width - 2 * _inset;
    final t = ((dx - _inset) / usable).clamp(0.0, 1.0);
    return (t * (labels.length - 1)).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final active = pending
        ? MoodStyle.neutral(theme.brightness)
        : scheme.primary;
    final l10n = AppLocalizations.of(context);
    final n = labels.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              double x(int i) =>
                  n == 1 ? w / 2 : _inset + i * (w - 2 * _inset) / (n - 1);
              final showLabel = [
                for (var i = 0; i < n; i++) n <= 5 || i == 0 || i == n - 1,
              ];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    slider: true,
                    value: selected == null ? '–' : labels[selected!],
                    increasedValue:
                        labels[((selected ?? -1) + 1).clamp(0, n - 1)],
                    decreasedValue:
                        labels[((selected ?? 1) - 1).clamp(0, n - 1)],
                    onIncrease: () =>
                        onChanged(((selected ?? -1) + 1).clamp(0, n - 1)),
                    onDecrease: () =>
                        onChanged(((selected ?? 1) - 1).clamp(0, n - 1)),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) =>
                          onChanged(_indexAt(d.localPosition.dx, w)),
                      onHorizontalDragUpdate: (d) {
                        final i = _indexAt(d.localPosition.dx, w);
                        if (i != selected) onChanged(i);
                      },
                      child: SizedBox(
                        height: _trackHeight,
                        child: CustomPaint(
                          painter: _TrackPainter(
                            stops: [for (var i = 0; i < n; i++) x(i)],
                            selected: selected,
                            active: active,
                            inactive: scheme.outlineVariant,
                            surface: scheme.surfaceContainerLow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (var i = 0; i < n; i++)
                          if (showLabel[i])
                            Positioned(
                              left: i == 0
                                  ? 0
                                  : i == n - 1
                                  ? null
                                  : x(i) - 36,
                              right: i == n - 1 ? 0 : null,
                              width: 72,
                              child: GestureDetector(
                                onTap: () => onChanged(i),
                                child: Text(
                                  labels[i],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: i == 0
                                      ? TextAlign.left
                                      : i == n - 1
                                      ? TextAlign.right
                                      : TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: i == selected
                                        ? active
                                        : scheme.onSurfaceVariant,
                                    fontWeight: i == selected
                                        ? FontWeight.w700
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          width: 40,
          child: selected == null
              ? null
              : IconButton(
                  tooltip: l10n.sliderClear,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Symbols.close_rounded, size: 20),
                  onPressed: onClear,
                ),
        ),
      ],
    );
  }
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.stops,
    required this.selected,
    required this.active,
    required this.inactive,
    required this.surface,
  });

  final List<double> stops;
  final int? selected;
  final Color active;
  final Color inactive;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final unset = selected == null;
    final base = Paint()
      ..color = unset ? inactive.withValues(alpha: 0.6) : inactive
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(stops.first, cy), Offset(stops.last, cy), base);
    if (!unset) {
      canvas.drawLine(
        Offset(stops.first, cy),
        Offset(stops[selected!], cy),
        Paint()
          ..color = active
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
    for (var i = 0; i < stops.length; i++) {
      final past = !unset && i <= selected!;
      canvas.drawCircle(
        Offset(stops[i], cy),
        4,
        Paint()..color = past ? active : surface,
      );
      if (!past) {
        canvas.drawCircle(
          Offset(stops[i], cy),
          4,
          Paint()
            ..color = inactive
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    if (!unset) {
      final c = Offset(stops[selected!], cy);
      canvas.drawCircle(c, 14, Paint()..color = active.withValues(alpha: 0.2));
      canvas.drawCircle(c, 10, Paint()..color = active);
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.selected != selected ||
      old.active != active ||
      old.inactive != inactive ||
      old.stops.length != stops.length ||
      old.stops.first != stops.first ||
      old.stops.last != stops.last;
}
