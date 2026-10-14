import 'dart:convert';

import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../domain/mood.dart';
import '../../domain/stats.dart';

/// The report (design-concept §6): ONE self-contained HTML document — inline
/// CSS and SVG, no scripts, no external requests — so the same string is the
/// HTML file *and* the PDF's source (PLAN § Report). Every number comes from
/// the stats engine. Notes only when asked for.

enum ReportSection { summary, dayByDay, byPeriod, alongside, weekday, notes }

class ReportOptions {
  const ReportOptions({
    required this.range,
    this.sections = const {
      ReportSection.summary,
      ReportSection.dayByDay,
      ReportSection.byPeriod,
      ReportSection.alongside,
      ReportSection.weekday,
    },
    this.includeNotes = false,
  });

  final StatsRange range;
  final Set<ReportSection> sections;

  /// Off by default — notes are the most private part (§6).
  final bool includeNotes;
}

/// Everything user-visible, already localised (the builder stays pure).
class ReportText {
  const ReportText({
    required this.title,
    required this.rangeLabel,
    required this.generated,
    required this.moodLabels,
    required this.summary,
    required this.average,
    required this.daysLogged,
    required this.bestDay,
    required this.hardestDay,
    required this.dayByDay,
    required this.dayByDayHint,
    required this.byPeriod,
    required this.outsidePeriod,
    required this.alongside,
    required this.alongsideHint,
    required this.nothingLogged,
    required this.notTracked,
    required this.caveat,
    required this.weekday,
    required this.weekdayNames,
    required this.notes,
    required this.nothingInRange,
    required this.formatDay,
    required this.formatShortDay,
    required this.modeOne,
    required this.modeAny,
  });

  final String title;

  /// e.g. "8 Sep – 14 Oct 2026".
  final String rangeLabel;

  /// e.g. "Created 14 Oct 2026 with Launenfuchs".
  final String generated;

  /// Index = mood value − 1 (awful … rad).
  final List<String> moodLabels;
  final String summary, average, daysLogged, bestDay, hardestDay;
  final String dayByDay, dayByDayHint, byPeriod, outsidePeriod;
  final String alongside, alongsideHint, nothingLogged, notTracked, caveat;
  final String weekday, notes, nothingInRange, modeOne, modeAny;

  /// Monday first (index 0 = Monday).
  final List<String> weekdayNames;
  final String Function(Day) formatDay;
  final String Function(Day) formatShortDay;
}

// Mood scale, light (print) — DESIGN_SYSTEM §1.
const _moodColor = {
  5: '#1FA85D',
  4: '#84CFA6',
  3: '#8C857E',
  2: '#BCA4E5',
  1: '#8559D0',
};
const _moodColorDark = {
  5: '#37CE78',
  4: '#2E8650',
  3: '#9A938C',
  2: '#735E97',
  1: '#A98CEE',
};

/// Colours for the SVG charts: CSS variables in the HTML (theme-aware), literal
/// light values for the PDF (its SVG renderer has no CSS).
typedef ColorFor = String Function(String token);
String cssVar(String token) => 'var(--$token)';
String printColor(String token) => switch (token) {
  'ink' => '#231b16',
  'muted' => '#6f625a',
  'line' => '#e5dbd3',
  'card' => '#ffffff',
  'band' => '#f8ebd6',
  'accent' => '#EA7A24',
  _ when token.startsWith('m') => _moodColor[int.parse(token.substring(1))]!,
  _ => '#000000',
};

final _esc = const HtmlEscape();
String _e(String s) => _esc.convert(s);
String _f1(double? v) => v == null ? '–' : v.toStringAsFixed(1);

String buildReportHtml(Journal j, Day today, ReportOptions o, ReportText t) {
  final r = o.range;
  final b = StringBuffer();
  final s = summary(j, r);
  b.write('''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${_e(t.title)} · ${_e(t.rangeLabel)}</title>
<style>
:root{--ink:#231b16;--muted:#7a6d64;--line:#ece3dc;--card:#fff;--page:#fdf6f1;--band:rgba(224,163,59,.15);--accent:#EA7A24;
${[for (final e in _moodColor.entries) '--m${e.key}:${e.value}'].join(';')}}
@media (prefers-color-scheme: dark){:root{--ink:#f3ede9;--muted:#a99e96;--line:#332821;--card:#211a15;--page:#16110d;
${[for (final e in _moodColorDark.entries) '--m${e.key}:${e.value}'].join(';')}}}
@media print{:root{--ink:#231b16;--muted:#6f625a;--line:#e5dbd3;--card:#fff;--page:#fff;
${[for (final e in _moodColor.entries) '--m${e.key}:${e.value}'].join(';')}}
section{break-inside:avoid}}
*{box-sizing:border-box}
body{margin:0;background:var(--page);color:var(--ink);font:14px/1.5 system-ui,-apple-system,"Segoe UI",Roboto,sans-serif}
main{max-width:820px;margin:0 auto;padding:28px 18px 48px}
h1{font-size:24px;margin:0 0 2px}
.sub{color:var(--muted);margin:0 0 20px}
section{background:var(--card);border:1px solid var(--line);border-radius:14px;padding:14px 16px;margin:0 0 14px}
h2{font-size:12px;letter-spacing:.07em;text-transform:uppercase;color:var(--muted);margin:0 0 8px}
.hint,.caveat{color:var(--muted);font-size:12.5px;margin:4px 0 8px}
.figs{display:flex;gap:24px;flex-wrap:wrap}
.fig b{display:block;font-size:24px}
.fig span{color:var(--muted);font-size:12px}
svg{display:block;width:100%;height:auto}
svg text{font-family:inherit;fill:var(--muted);font-size:10px}
table{width:100%;border-collapse:collapse;font-size:13px}
td,th{padding:4px 6px 4px 0;text-align:left;vertical-align:middle}
th{color:var(--muted);font-weight:600;border-bottom:1px solid var(--line)}
td.n{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
.stack{display:flex;height:16px;gap:2px;min-width:160px}
.stack i{display:block;border-radius:3px}
.dot{display:inline-block;width:10px;height:10px;border-radius:50%;vertical-align:-1px;margin-right:6px}
.cat{font-weight:700;padding-top:10px}
.muted{color:var(--muted);font-style:italic}
.note{padding:6px 0;border-top:1px solid var(--line)}
.note:first-child{border-top:none}
.legend{display:flex;gap:12px;flex-wrap:wrap;color:var(--muted);font-size:12px;margin-top:6px}
footer{color:var(--muted);font-size:12px;text-align:center;margin-top:20px}
</style></head><body><main>
<h1>${_e(t.title)}</h1>
<p class="sub">${_e(t.rangeLabel)}</p>
''');

  final es = entriesIn(j, r);
  if (es.isEmpty) {
    b.write('<section><p>${_e(t.nothingInRange)}</p></section>');
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.summary)) {
    b.write('<section><h2>${_e(t.summary)}</h2><div class="figs">');
    b.write(
      '<div class="fig"><b>${_f1(s.average)} / 5</b><span>${_e(t.average)}</span></div>',
    );
    b.write(
      '<div class="fig"><b>${s.daysLogged} / ${s.daysInRange}</b><span>${_e(t.daysLogged)}</span></div>',
    );
    if (s.best.isNotEmpty) {
      b.write(
        '<div class="fig"><b>${_e(t.formatShortDay(s.best.last.day))}</b><span>${_e(t.bestDay)} · ${_e(t.moodLabels[s.best.last.mood.value - 1])}</span></div>',
      );
    }
    if (s.worst.isNotEmpty) {
      b.write(
        '<div class="fig"><b>${_e(t.formatShortDay(s.worst.last.day))}</b><span>${_e(t.hardestDay)} · ${_e(t.moodLabels[s.worst.last.mood.value - 1])}</span></div>',
      );
    }
    b.write('</div></section>');
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.dayByDay)) {
    b.write(
      '<section><h2>${_e(t.dayByDay)}</h2><p class="hint">${_e(t.dayByDayHint)}</p>',
    );
    b.write(daySvg(j, r, today, t, cssVar));
    b.write('<div class="legend">');
    for (var v = 5; v >= 1; v--) {
      b.write(
        '<span><i class="dot" style="background:var(--m$v)"></i>${_e(t.moodLabels[v - 1])}</span>',
      );
    }
    b.write('</div></section>');
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.byPeriod)) {
    final slices = periodSummary(j, r, today);
    if (slices.isNotEmpty) {
      b.write('<section><h2>${_e(t.byPeriod)}</h2><table>');
      for (final sl in slices) {
        final p = sl.period;
        final when = p == null
            ? ''
            : '${t.formatShortDay(p.start)} – ${p.end == null ? '' : t.formatShortDay(p.end!)}';
        b.write(
          '<tr><td>${_e(p?.name ?? t.outsidePeriod)}<br><span class="muted">${_e(when)}</span></td><td><div class="stack">',
        );
        for (var v = 5; v >= 1; v--) {
          final n = sl.counts[v] ?? 0;
          if (n > 0) {
            b.write(
              '<i style="flex:$n;background:var(--m$v)" title="${_e(t.moodLabels[v - 1])}: $n"></i>',
            );
          }
        }
        b.write(
          '</div></td><td class="n"><b>${_f1(sl.average)}</b> · ${sl.entries.length}</td></tr>',
        );
      }
      b.write('</table></section>');
    }
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.alongside)) {
    final groups = optionComparison(j, r);
    if (groups.isNotEmpty) {
      b.write(
        '<section><h2>${_e(t.alongside)}</h2><p class="hint">${_e(t.alongsideHint)}</p><table>',
      );
      for (final g in groups) {
        b.write(
          '<tr><td class="cat" colspan="3">${_e(g.category.name)} <span class="muted">· ${_e(comparesWithEachOther(g.category) ? t.modeOne : t.modeAny)}</span></td></tr>',
        );
        for (final row in g.rows) {
          if (row.kind == RowKind.option && row.count < 2) continue;
          final name = switch (row.kind) {
            RowKind.option => row.option!.name,
            RowKind.nothingLogged => t.nothingLogged,
            RowKind.notTracked => t.notTracked,
          };
          final cls = row.kind == RowKind.option ? '' : ' class="muted"';
          b.write(
            '<tr><td$cls>${_e(name)}</td><td>${trackSvg(row.average, s.average ?? 3, cssVar, hollow: row.kind != RowKind.option)}</td><td class="n">${_f1(row.average)} · ${row.count}×</td></tr>',
          );
        }
      }
      b.write('</table><p class="caveat">${_e(t.caveat)}</p></section>');
    }
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.weekday)) {
    final w = weekdayMeans(j, r);
    b.write('<section><h2>${_e(t.weekday)}</h2><table><tr>');
    for (var i = 0; i < 7; i++) {
      b.write('<th style="text-align:center">${_e(t.weekdayNames[i])}</th>');
    }
    b.write('</tr><tr>');
    for (final x in w) {
      b.write(
        '<td style="text-align:center"><b>${_f1(x.average)}</b><br><span class="muted">${x.count}×</span></td>',
      );
    }
    b.write('</tr></table></section>');
  }

  if (o.includeNotes) {
    final notes = notesIn(j, r);
    if (notes.isNotEmpty) {
      b.write('<section><h2>${_e(t.notes)}</h2>');
      for (final e in notes) {
        b.write(
          '<div class="note"><span class="dot" style="background:var(--m${e.mood.value})"></span><b>${_e(t.formatDay(e.day))}</b> · ${_e(t.moodLabels[e.mood.value - 1])}<br>${_e(e.note!.trim()).replaceAll('\n', '<br>')}</div>',
        );
      }
      b.write('</section>');
    }
  }

  b.write('<footer>${_e(t.generated)}</footer></main></body></html>');
  return b.toString();
}

/// The day-by-day chart as SVG (shared by the HTML and the PDF).
String daySvg(Journal j, StatsRange r, Day today, ReportText t, ColorFor c) {
  const w = 760.0, h = 210.0, l = 6.0, rr = 6.0, top = 24.0, bot = 22.0;
  final series = daySeries(j, r);
  final n = series.length;
  final step = (w - l - rr) / n;
  double x(int i) => l + (i + .5) * step;
  double y(num m) => top + (5 - m) * (h - top - bot) / 4;
  final sb = StringBuffer('<svg viewBox="0 0 $w $h" role="img">');
  for (final p in periodsIn(j, r, today)) {
    final i0 = series.indexWhere((s) => !s.day.isBefore(p.start));
    final end = p.end ?? today;
    final i1 = series.lastIndexWhere((s) => !s.day.isAfter(end));
    if (i0 < 0 || i1 < i0) continue;
    final x0 = l + i0 * step, x1 = l + (i1 + 1) * step;
    if (p.away) {
      sb.write(
        '<rect x="${x0.toStringAsFixed(1)}" y="${top - 10}" width="${(x1 - x0).toStringAsFixed(1)}" height="${h - top - bot + 12}" fill="${c('band')}"/>',
      );
    } else {
      sb.write(
        '<line x1="${x0.toStringAsFixed(1)}" x2="${x1.toStringAsFixed(1)}" y1="${top - 10}" y2="${top - 10}" stroke="${c('muted')}" stroke-width="2" opacity=".5"/>',
      );
    }
    sb.write(
      '<text x="${((x0 + x1) / 2).toStringAsFixed(1)}" y="10" text-anchor="middle" font-weight="700">${_e(p.name)}</text>',
    );
  }
  for (var m = 1; m <= 5; m++) {
    sb.write(
      '<line x1="$l" x2="${w - rr}" y1="${y(m)}" y2="${y(m)}" stroke="${c('line')}"/>',
    );
  }
  final path = StringBuffer();
  var pen = false;
  for (var i = 0; i < n; i++) {
    final v = series[i].rolling;
    if (v == null) {
      pen = false;
      continue;
    }
    path.write(
      '${pen ? 'L' : 'M'}${x(i).toStringAsFixed(1)},${y(v).toStringAsFixed(1)} ',
    );
    pen = true;
  }
  sb.write(
    '<path d="$path" fill="none" stroke="${c('ink')}" stroke-width="1.8" opacity=".7"/>',
  );
  final rad = (step * .42).clamp(2.0, 6.0);
  for (var i = 0; i < n; i++) {
    final e = series[i].entry;
    if (e == null) continue;
    if (e.hasNote) {
      sb.write(
        '<circle cx="${x(i).toStringAsFixed(1)}" cy="${y(e.mood.value)}" r="${(rad + 3).toStringAsFixed(1)}" fill="none" stroke="${c('accent')}" stroke-width="1.5"/>',
      );
    }
    sb.write(
      '<circle cx="${x(i).toStringAsFixed(1)}" cy="${y(e.mood.value)}" r="${rad.toStringAsFixed(1)}" fill="${c('m${e.mood.value}')}"><title>${_e(t.formatDay(e.day))}: ${_e(t.moodLabels[e.mood.value - 1])}</title></circle>',
    );
  }
  for (final i in {0, n ~/ 2, n - 1}) {
    sb.write(
      '<text x="${x(i).clamp(30, w - 30).toStringAsFixed(1)}" y="${h - 6}" text-anchor="middle">${_e(t.formatShortDay(series[i].day))}</text>',
    );
  }
  for (var m = 1; m <= 5; m++) {
    sb.write(
      '<text x="${l + 2}" y="${y(m) - 3}">${_e(t.moodLabels[m - 1])}</text>',
    );
  }
  sb.write('</svg>');
  return sb.toString();
}

/// One comparison track as SVG (shared by the HTML and the PDF).
String trackSvg(
  double value,
  double overall,
  ColorFor c, {
  required bool hollow,
}) {
  const w = 220.0, h = 18.0;
  double x(num m) => 6 + (m - 1) / 4 * (w - 12);
  final sb = StringBuffer('<svg viewBox="0 0 $w $h" style="min-width:140px">');
  for (var m = 1; m <= 5; m++) {
    sb.write(
      '<line x1="${x(m)}" x2="${x(m)}" y1="0" y2="$h" stroke="${c('line')}"/>',
    );
  }
  sb.write(
    '<line x1="${x(overall).toStringAsFixed(1)}" x2="${x(overall).toStringAsFixed(1)}" y1="0" y2="$h" stroke="${c('muted')}" stroke-dasharray="2.5 2.5"/>',
  );
  final vx = x(value).toStringAsFixed(1);
  if (hollow) {
    sb.write(
      '<circle cx="$vx" cy="${h / 2}" r="4.5" fill="${c('card')}" stroke="${c('muted')}" stroke-width="1.6"/>',
    );
  } else {
    final above = value >= overall;
    sb.write(
      '<line x1="${x(overall).toStringAsFixed(1)}" x2="$vx" y1="${h / 2}" y2="${h / 2}" stroke="${c(above ? 'm4' : 'm2')}" stroke-width="3" stroke-linecap="round"/>',
    );
    sb.write(
      '<circle cx="$vx" cy="${h / 2}" r="5" fill="${c(above ? 'm5' : 'm1')}"/>',
    );
  }
  sb.write('</svg>');
  return sb.toString();
}

/// Mood labels in value order, for callers that build [ReportText].
List<String> moodLabelList(String Function(Mood) label) => [
  for (final m in Mood.values) label(m),
];
