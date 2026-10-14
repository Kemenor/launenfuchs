import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../domain/stats.dart';
import 'report_builder.dart';

/// The report as a PDF (design-concept §6): the same sections, numbers and
/// SVG charts as the HTML (shared [daySvg] / [trackSvg], literal print
/// colours), laid out with the pdf widgets. Fonts are passed in — the app
/// uses Atkinson Hyperlegible from fuchsbau.
///
/// (The plan was "PDF rendered from the HTML"; printing's convertHtml relies
/// on hidden print APIs and hangs on current Android, so the PDF is drawn
/// from the same building blocks instead.)
Future<Uint8List> buildReportPdf(
  Journal j,
  Day today,
  ReportOptions o,
  ReportText t, {
  pw.Font? regular,
  pw.Font? bold,
}) async {
  final r = o.range;
  final ink = PdfColor.fromHex('#231b16');
  final muted = PdfColor.fromHex('#6f625a');
  final line = PdfColor.fromHex('#e5dbd3');
  PdfColor mood(int v) => PdfColor.fromHex(printColor('m$v'));
  String f1(double? v) => v == null ? '–' : v.toStringAsFixed(1);

  final doc = pw.Document(
    title: '${t.title} · ${t.rangeLabel}',
    creator: 'Launenfuchs',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  // Sections are flattened (a header, then rows) so MultiPage can break
  // between rows — a boxed section taller than a page cannot be laid out.
  List<pw.Widget> section(String title, List<pw.Widget> children) => [
    pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: line)),
      ),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 8.5,
          color: muted,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    ),
    ...children,
  ];
  pw.Widget small(String s, {bool italic = false}) => pw.Text(
    s,
    style: pw.TextStyle(
      fontSize: 9,
      color: muted,
      fontStyle: italic ? pw.FontStyle.italic : null,
    ),
  );
  pw.Widget dot(int v) => pw.Container(
    width: 7,
    height: 7,
    margin: const pw.EdgeInsets.only(right: 4),
    decoration: pw.BoxDecoration(color: mood(v), shape: pw.BoxShape.circle),
  );

  final es = entriesIn(j, r);
  final s = summary(j, r);
  final content = <pw.Widget>[
    pw.Text(
      t.title,
      style: pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
        color: ink,
      ),
    ),
    pw.SizedBox(height: 2),
    pw.Text(t.rangeLabel, style: pw.TextStyle(fontSize: 11, color: muted)),
    pw.SizedBox(height: 14),
  ];

  if (es.isEmpty) content.add(pw.Text(t.nothingInRange));

  if (es.isNotEmpty && o.sections.contains(ReportSection.summary)) {
    pw.Widget fig(String v, String label) => pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            v,
            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
          ),
          small(label),
        ],
      ),
    );
    content.addAll(
      section(t.summary, [
        pw.Row(
          children: [
            fig('${f1(s.average)} / 5', t.average),
            fig('${s.daysLogged} / ${s.daysInRange}', t.daysLogged),
            if (s.best.isNotEmpty)
              fig(
                t.formatShortDay(s.best.last.day),
                '${t.bestDay} · ${t.moodLabels[s.best.last.mood.value - 1]}',
              ),
            if (s.worst.isNotEmpty)
              fig(
                t.formatShortDay(s.worst.last.day),
                '${t.hardestDay} · ${t.moodLabels[s.worst.last.mood.value - 1]}',
              ),
          ],
        ),
      ]),
    );
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.dayByDay)) {
    content.addAll(
      section(t.dayByDay, [
        small(t.dayByDayHint),
        pw.SizedBox(height: 6),
        pw.SvgImage(svg: daySvg(j, r, today, t, printColor)),
        pw.SizedBox(height: 6),
        pw.Wrap(
          spacing: 10,
          children: [
            for (var v = 5; v >= 1; v--)
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [dot(v), small(t.moodLabels[v - 1])],
              ),
          ],
        ),
      ]),
    );
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.byPeriod)) {
    final slices = periodSummary(j, r, today);
    if (slices.isNotEmpty) {
      content.addAll(
        section(t.byPeriod, [
          for (final sl in slices)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 120,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          sl.period?.name ?? t.outsidePeriod,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        if (sl.period != null)
                          small(
                            '${t.formatShortDay(sl.period!.start)} – ${sl.period!.end == null ? '' : t.formatShortDay(sl.period!.end!)}',
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Row(
                      children: [
                        for (var v = 5; v >= 1; v--)
                          if ((sl.counts[v] ?? 0) > 0)
                            pw.Expanded(
                              flex: sl.counts[v]!,
                              child: pw.Container(
                                height: 12,
                                margin: const pw.EdgeInsets.symmetric(
                                  horizontal: 0.6,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: mood(v),
                                  borderRadius: pw.BorderRadius.circular(2),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  pw.SizedBox(
                    width: 54,
                    child: pw.Text(
                      '${f1(sl.average)} · ${sl.entries.length}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ]),
      );
    }
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.alongside)) {
    final groups = optionComparison(j, r);
    final overall = s.average ?? 3;
    if (groups.isNotEmpty) {
      final rows = <pw.Widget>[small(t.alongsideHint), pw.SizedBox(height: 4)];
      for (final g in groups) {
        rows.add(
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
            child: pw.Text(
              '${g.category.name} · ${comparesWithEachOther(g.category) ? t.modeOne : t.modeAny}',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        );
        for (final row in g.rows) {
          if (row.kind == RowKind.option && row.count < 2) continue;
          final name = switch (row.kind) {
            RowKind.option => row.option!.name,
            RowKind.nothingLogged => t.nothingLogged,
            RowKind.notTracked => t.notTracked,
          };
          rows.add(
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 130,
                  child: pw.Text(
                    name,
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      color: row.kind == RowKind.option ? ink : muted,
                    ),
                  ),
                ),
                pw.SizedBox(
                  width: 220,
                  height: 16,
                  child: pw.SvgImage(
                    svg: trackSvg(
                      row.average,
                      overall,
                      printColor,
                      hollow: row.kind != RowKind.option,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    '${f1(row.average)} · ${row.count}×',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 9.5, color: muted),
                  ),
                ),
              ],
            ),
          );
        }
      }
      rows.add(pw.SizedBox(height: 6));
      rows.add(small(t.caveat));
      content.addAll(section(t.alongside, rows));
    }
  }

  if (es.isNotEmpty && o.sections.contains(ReportSection.weekday)) {
    final w = weekdayMeans(j, r);
    content.addAll(
      section(t.weekday, [
        pw.Row(
          children: [
            for (var i = 0; i < 7; i++)
              pw.Expanded(
                child: pw.Column(
                  children: [
                    small(t.weekdayNames[i]),
                    pw.Text(
                      f1(w[i].average),
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    small('${w[i].count}×'),
                  ],
                ),
              ),
          ],
        ),
      ]),
    );
  }

  if (o.includeNotes) {
    final notes = notesIn(j, r);
    if (notes.isNotEmpty) {
      content.addAll(
        section(t.notes, [
          for (final e in notes)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 3),
                    child: dot(e.mood.value),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${t.formatDay(e.day)} · ${t.moodLabels[e.mood.value - 1]}',
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          e.note!.trim(),
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ]),
      );
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (_) => content,
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          small(t.generated),
          small('${ctx.pageNumber} / ${ctx.pagesCount}'),
        ],
      ),
    ),
  );
  return doc.save();
}
