import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/report/report_builder.dart';
import '../data/report/report_pdf.dart';
import '../data/report/report_service.dart';
import '../domain/day.dart';
import '../domain/journal.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'mood_style.dart';
import 'stats/tile_catalog.dart';

/// The report (design-concept §6): pick a range and sections, notes off by
/// default, save as HTML or PDF — the same sections, numbers and charts.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  static Future<void> open(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const ReportScreen()));

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

enum _Range { days30, months3, all, custom }

class _ReportScreenState extends ConsumerState<ReportScreen> {
  _Range _range = _Range.days30;
  int? _periodId;
  StatsRange? _custom;
  final Set<ReportSection> _sections = {
    ReportSection.summary,
    ReportSection.dayByDay,
    ReportSection.byPeriod,
    ReportSection.alongside,
    ReportSection.weekday,
  };
  bool _notes = false;
  bool _busy = false;

  StatsRange _resolve(Journal j, Day today) {
    if (_periodId != null) {
      for (final p in j.periods) {
        if (p.id == _periodId) {
          final end = p.end ?? today;
          return StatsRange(p.start, end.isAfter(today) ? today : end);
        }
      }
    }
    return switch (_range) {
      _Range.days30 => StatsRange(today.addDays(-29), today),
      _Range.months3 => StatsRange(today.addDays(-90), today),
      _Range.all => allTime(j, today),
      _Range.custom => _custom ?? StatsRange(today.addDays(-29), today),
    };
  }

  ReportText _text(AppLocalizations l10n, String locale, StatsRange r) {
    String day(Day d) => DateFormat.yMMMEd(locale).format(d.noon);
    String short(Day d) => DateFormat.MMMd(locale).format(d.noon);
    return ReportText(
      title: l10n.reportTitle,
      rangeLabel:
          '${DateFormat.yMMMd(locale).format(r.from.noon)} – ${DateFormat.yMMMd(locale).format(r.to.noon)}',
      generated: l10n.reportGenerated(
        DateFormat.yMMMd(locale).format(DateTime.now()),
      ),
      moodLabels: moodLabelList((m) => MoodStyle.label(m, l10n)),
      summary: l10n.tileSummary,
      average: l10n.statsAverage,
      daysLogged: l10n.statsDaysLogged,
      bestDay: l10n.statsBestDay,
      hardestDay: l10n.statsWorstDay,
      dayByDay: l10n.tileDayByDay,
      dayByDayHint: l10n.statsDayByDayHint.split(' · ').take(2).join(' · '),
      byPeriod: l10n.tileByPeriod,
      outsidePeriod: l10n.statsPeriodOutside,
      alongside: l10n.tileAlongside,
      alongsideHint: l10n.statsAlongsideHint('·').split(' · dashed').first,
      nothingLogged: l10n.rowNothingLogged,
      notTracked: l10n.rowNotTracked,
      caveat: l10n.statsCaveat,
      weekday: l10n.tileWeekday,
      weekdayNames: [
        for (var i = 0; i < 7; i++)
          DateFormat.E(locale).format(DateTime(2026, 10, 5 + i)),
      ],
      notes: l10n.tileNotes,
      nothingInRange: l10n.statsNothingInRange,
      formatDay: day,
      formatShortDay: short,
      modeOne: l10n.importModeOne,
      modeAny: l10n.importModeAny,
    );
  }

  Future<void> _save({required bool pdf}) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final messenger = ScaffoldMessenger.of(context);
    final j = ref.read(journalProvider).value ?? Journal.empty;
    final today = logicalToday(ref);
    final r = _resolve(j, today);
    final options = ReportOptions(
      range: r,
      sections: _sections,
      includeNotes: _notes,
    );
    final text = _text(l10n, locale, r);
    final name = 'launenfuchs-report-${r.from.key}_${r.to.key}';
    setState(() => _busy = true);
    try {
      final service = ReportService();
      final int? bytes;
      if (pdf) {
        // Atkinson Hyperlegible (fuchsbau): legible in print, covers äöü/é/à.
        Future<pw.Font> font(String file) async => pw.Font.ttf(
          await rootBundle.load('packages/fuchsbau/assets/fonts/$file'),
        );
        final doc = await buildReportPdf(
          j,
          today,
          options,
          text,
          regular: await font('AtkinsonHyperlegible-Regular.ttf'),
          bold: await font('AtkinsonHyperlegible-Bold.ttf'),
        );
        bytes = await service.savePdf(doc, name);
      } else {
        bytes = await service.saveHtml(
          buildReportHtml(j, today, options, text),
          name,
        );
      }
      if (bytes != null) {
        final size = bytes >= 1024 * 1024
            ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
            : '${(bytes / 1024).ceil()} KB';
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportSaved(size))));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.reportFailed('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final j = ref.watch(journalProvider).value ?? Journal.empty;
    final today = logicalToday(ref);
    final r = _resolve(j, today);
    final logged = entriesIn(j, r).length;
    final names = {
      ReportSection.summary: StatsTile.summary.title(l10n),
      ReportSection.dayByDay: StatsTile.dayByDay.title(l10n),
      ReportSection.byPeriod: StatsTile.byPeriod.title(l10n),
      ReportSection.alongside: StatsTile.alongside.title(l10n),
      ReportSection.weekday: StatsTile.weekday.title(l10n),
    };
    Widget chip(String label, _Range v) => ChoiceChip(
      label: Text(label),
      selected: _periodId == null && _range == v,
      onSelected: (_) => setState(() {
        _periodId = null;
        _range = v;
      }),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportRow)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Text(l10n.reportRange, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip(l10n.rangeDays30, _Range.days30),
              chip(l10n.reportRange3Months, _Range.months3),
              chip(l10n.rangeAll, _Range.all),
              ChoiceChip(
                label: Text(l10n.reportRangeCustom),
                selected: _periodId == null && _range == _Range.custom,
                onSelected: (_) async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: allTime(j, today).from.noon,
                    lastDate: today.noon,
                  );
                  if (picked != null) {
                    setState(() {
                      _periodId = null;
                      _range = _Range.custom;
                      _custom = StatsRange(
                        Day.of(picked.start),
                        Day.of(picked.end),
                      );
                    });
                  }
                },
              ),
              for (final p in j.periods.reversed)
                ChoiceChip(
                  avatar: const Icon(Symbols.date_range_rounded, size: 16),
                  label: Text(p.name),
                  selected: _periodId == p.id,
                  onSelected: (_) => setState(() => _periodId = p.id),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${DateFormat.yMMMd(locale).format(r.from.noon)} – ${DateFormat.yMMMd(locale).format(r.to.noon)} · ${l10n.optionDaysCount(logged)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          Text(l10n.reportSections, style: theme.textTheme.titleSmall),
          for (final MapEntry(key: sec, value: name) in names.entries)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(name),
              value: _sections.contains(sec),
              onChanged: (v) => setState(
                () => v == true ? _sections.add(sec) : _sections.remove(sec),
              ),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Symbols.sticky_note_2_rounded),
            title: Text(l10n.reportIncludeNotes),
            subtitle: Text(l10n.reportIncludeNotesHint),
            value: _notes,
            onChanged: (v) => setState(() => _notes = v),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.reportHtmlHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Symbols.html_rounded),
            label: Text(l10n.reportSaveHtml),
            onPressed: _busy || logged == 0 ? null : () => _save(pdf: false),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            icon: const Icon(Symbols.picture_as_pdf_rounded),
            label: Text(l10n.reportSavePdf),
            onPressed: _busy || logged == 0 ? null : () => _save(pdf: true),
          ),
        ],
      ),
    );
  }
}
