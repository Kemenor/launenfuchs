import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/day.dart';
import '../../domain/journal.dart';
import '../../domain/mood.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../entry_sheet.dart';
import '../mood_style.dart';
import '../option_icons.dart';
import '../period_sheet.dart';
import 'charts.dart';
import 'edit_tiles_screen.dart';
import 'option_detail_screen.dart';
import 'stats_range.dart';
import 'tile_catalog.dart';

/// The Stats tab (design-concept §5, DESIGN_SYSTEM §2.3): a range row over
/// the user's tiles, in their order. `tune` → Edit tiles.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final journal = ref.watch(journalProvider).value ?? Journal.empty;
    final today = logicalToday(ref);
    final choice = ref.watch(statsRangeProvider);
    final range = choice.resolve(journal, today);
    final tiles = [
      for (final (t, on) in effectiveTiles(
        ref.watch(settingsProvider).statsTiles,
      ))
        if (on) t,
    ];
    final ctx = TileContext(journal: journal, range: range, today: today);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navStats),
        actions: [
          IconButton(
            tooltip: l10n.editTiles,
            icon: const Icon(Symbols.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const EditTilesScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          RangeBar(journal: journal, today: today, range: range),
          if (journal.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(l10n.statsEmptyBody, textAlign: TextAlign.center),
            )
          else
            for (final t in tiles) StatsTileCard(tile: t, ctx: ctx),
        ],
      ),
    );
  }
}

class TileContext {
  const TileContext({
    required this.journal,
    required this.range,
    required this.today,
  });
  final Journal journal;
  final StatsRange range;
  final Day today;
}

/// The range chips: 30 days · Month ‹ › · Year ‹ › · All · Period ▾.
class RangeBar extends ConsumerWidget {
  const RangeBar({
    super.key,
    required this.journal,
    required this.today,
    required this.range,
  });

  final Journal journal;
  final Day today;
  final StatsRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final choice = ref.watch(statsRangeProvider);
    final ctrl = ref.read(statsRangeProvider.notifier);
    Widget chip(String label, RangeKind kind) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: choice.kind == kind,
        onSelected: (_) => ctrl.set(RangeChoice(kind)),
      ),
    );
    final stepper = switch (choice.kind) {
      RangeKind.month => DateFormat.yMMMM(locale).format(range.from.noon),
      RangeKind.year => '${range.from.year}',
      RangeKind.period =>
        journal.periods
            .where((p) => p.id == choice.periodId)
            .map((p) => p.name)
            .firstOrNull,
      _ => null,
    };
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
          child: Row(
            children: [
              chip(l10n.rangeDays30, RangeKind.days30),
              chip(l10n.rangeMonth, RangeKind.month),
              chip(l10n.rangeYear, RangeKind.year),
              chip(l10n.rangeAll, RangeKind.all),
              PopupMenuButton<int?>(
                tooltip: l10n.rangePeriod,
                onSelected: (id) async {
                  if (id == null) {
                    await showPeriodSheet(context);
                  } else {
                    ctrl.set(RangeChoice(RangeKind.period, periodId: id));
                  }
                },
                itemBuilder: (_) => [
                  for (final p in journal.periods.reversed)
                    PopupMenuItem(value: p.id, child: Text(p.name)),
                  PopupMenuItem<int?>(
                    value: null,
                    child: Row(
                      children: [
                        const Icon(Symbols.add_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.addPeriod),
                      ],
                    ),
                  ),
                ],
                child: IgnorePointer(
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.rangePeriod),
                        const Icon(Symbols.expand_more_rounded, size: 18),
                      ],
                    ),
                    selected: choice.kind == RangeKind.period,
                    onSelected: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        if (stepper != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (choice.kind != RangeKind.period)
                IconButton(
                  icon: const Icon(Symbols.chevron_left_rounded),
                  onPressed: () => ctrl.set(
                    RangeChoice(choice.kind, offset: choice.offset + 1),
                  ),
                ),
              Text(stepper, style: Theme.of(context).textTheme.titleSmall),
              if (choice.kind != RangeKind.period)
                IconButton(
                  icon: const Icon(Symbols.chevron_right_rounded),
                  onPressed: choice.offset == 0
                      ? null
                      : () => ctrl.set(
                          RangeChoice(choice.kind, offset: choice.offset - 1),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

/// A tile: lg(20) card, small uppercase title, optional header action.
class TileCard extends StatelessWidget {
  const TileCard({
    super.key,
    required this.title,
    required this.child,
    this.action,
  });

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

String fmt1(double? v) => v == null ? '–' : v.toStringAsFixed(1);

class StatsTileCard extends ConsumerWidget {
  const StatsTileCard({super.key, required this.tile, required this.ctx});

  final StatsTile tile;
  final TileContext ctx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final j = ctx.journal, r = ctx.range;
    final locale = Localizations.localeOf(context).toString();
    String date(Day d) => DateFormat.MMMEd(locale).format(d.noon);
    final empty = entriesIn(j, r).isEmpty;
    Widget nothing() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(l10n.statsNothingInRange, style: TextStyle(color: muted)),
    );

    void openOption(OptionItem o) => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OptionDetailScreen(option: o, range: r),
      ),
    );

    switch (tile) {
      case StatsTile.summary:
        final s = summary(j, r);
        return TileCard(
          title: tile.title(l10n),
          child: Row(
            children: [
              _Figure(
                value: fmt1(s.average),
                unit: '/ 5',
                label: l10n.statsAverage,
              ),
              _Figure(
                value: '${s.daysLogged}',
                unit: '/ ${s.daysInRange}',
                label: l10n.statsDaysLogged,
              ),
              if (s.best.isNotEmpty)
                _Figure(
                  face: s.best.last.mood,
                  value: DateFormat.MMMd(locale).format(s.best.last.day.noon),
                  label: l10n.statsBestDay,
                ),
              if (s.worst.isNotEmpty)
                _Figure(
                  face: s.worst.last.mood,
                  value: DateFormat.MMMd(locale).format(s.worst.last.day.noon),
                  label: l10n.statsWorstDay,
                ),
            ],
          ),
        );

      case StatsTile.dayByDay:
        return TileCard(
          title: tile.title(l10n),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.statsDayByDayHint,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              DayByDayChart(
                series: daySeries(j, r),
                periods: periodsIn(j, r, ctx.today),
                today: ctx.today,
                tickLabel: (d) =>
                    (r.length > 62
                            ? DateFormat.MMM(locale)
                            : DateFormat.MMMd(locale))
                        .format(d.noon),
                onTapDay: (d) => showEntrySheet(context, day: d),
                onTapPeriod: (p) => showPeriodSheet(context, period: p),
              ),
            ],
          ),
        );

      case StatsTile.byPeriod:
        final slices = periodSummary(j, r, ctx.today);
        return TileCard(
          title: tile.title(l10n),
          action: TextButton.icon(
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            icon: const Icon(Symbols.add_rounded, size: 18),
            label: Text(l10n.addPeriod),
            onPressed: () => showPeriodSheet(context),
          ),
          child: j.periods.isEmpty
              ? Text(
                  l10n.statsPeriodsEmpty,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                )
              : slices.isEmpty
              ? nothing()
              : Column(
                  children: [
                    for (final s in slices)
                      InkWell(
                        onTap: s.period == null
                            ? null
                            : () => showPeriodSheet(context, period: s.period),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 104,
                                child: Text(
                                  s.period?.name ?? l10n.statsPeriodOutside,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge,
                                ),
                              ),
                              Expanded(child: _MoodStack(counts: s.counts)),
                              SizedBox(
                                width: 34,
                                child: Text(
                                  fmt1(s.average),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );

      case StatsTile.alongside:
        final groups = optionComparison(j, r);
        final overall = summary(j, r).average;
        if (overall == null || groups.isEmpty) {
          return TileCard(title: tile.title(l10n), child: nothing());
        }
        return TileCard(
          title: tile.title(l10n),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.statsAlongsideHint(fmt1(overall)),
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              _ScaleHeader(),
              for (final g in groups) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: g.category.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        TextSpan(
                          text:
                              '  ·  ${comparesWithEachOther(g.category) ? l10n.importModeOne : l10n.importModeAny}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final row in g.rows)
                  if (row.count >= 2 || row.kind != RowKind.option)
                    _ComparisonRowView(
                      row: row,
                      overall: overall,
                      onTap: row.option == null
                          ? null
                          : () => openOption(row.option!),
                    ),
              ],
              const SizedBox(height: 10),
              Text(
                l10n.statsCaveat,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        );

      case StatsTile.grid:
        return TileCard(
          title: tile.title(l10n),
          child: empty
              ? nothing()
              : _LoggedGrid(ctx: ctx, onTapOption: openOption),
        );

      case StatsTile.weekday:
        final w = weekdayMeans(j, r);
        final known = [
          for (final x in w)
            if (x.average != null) x,
        ];
        if (known.isEmpty) {
          return TileCard(title: tile.title(l10n), child: nothing());
        }
        known.sort((a, b) => b.average!.compareTo(a.average!));
        final spread = known.first.average! - known.last.average!;
        final names = DateFormat.EEEE(locale);
        String day(int weekday) =>
            names.format(DateTime(2026, 10, 5 + weekday - 1));
        final first = MaterialLocalizations.of(
          context,
        ).firstDayOfWeekIndex; // 0 = Sun
        final order = [for (var i = 0; i < 7; i++) ((first + i + 6) % 7) + 1];
        return TileCard(
          title: tile.title(l10n),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 92,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final wd in order)
                      Expanded(
                        child: _WeekdayBar(
                          mean: w[wd - 1],
                          label: DateFormat.E(
                            locale,
                          ).format(DateTime(2026, 10, 5 + wd - 1)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                spread < weekdayPatternThreshold
                    ? l10n.statsWeekdayNoPattern(
                        fmt1(known.last.average),
                        fmt1(known.first.average),
                      )
                    : l10n.statsWeekdayPattern(
                        day(known.first.weekday),
                        fmt1(known.first.average),
                        day(known.last.weekday),
                        fmt1(known.last.average),
                      ),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );

      case StatsTile.notes:
        final notes = notesIn(j, r);
        return TileCard(
          title: tile.title(l10n),
          child: notes.isEmpty
              ? nothing()
              : Column(
                  children: [
                    for (final e in notes.take(30))
                      InkWell(
                        onTap: () => showEntrySheet(context, day: e.day),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MoodFace(e.mood, size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      date(e.day),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(color: muted),
                                    ),
                                    Text(
                                      e.note!.trim(),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        );

      case StatsTile.moodCount:
        final counts = moodCounts(j, r);
        return TileCard(
          title: tile.title(l10n),
          child: empty
              ? nothing()
              : Column(
                  children: [
                    _MoodStack(
                      counts: {
                        for (final m in Mood.values) m.value: counts[m]!,
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (final m in Mood.values.reversed)
                          Column(
                            children: [
                              MoodFace(m, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                '${counts[m]}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
        );

      case StatsTile.optionCounts:
        final counts = optionCounts(j, r);
        final perCat = categoryCounts(j, r);
        return TileCard(
          title: tile.title(l10n),
          child: counts.isEmpty
              ? nothing()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in counts.take(24))
                          ActionChip(
                            avatar: Icon(optionIcon(c.option.icon), size: 18),
                            label: Text('${c.option.name}  ${c.count}'),
                            onPressed: () => openOption(c.option),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.statsOptionCountsCategories,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        for (final MapEntry(key: c, value: n) in perCat.entries)
                          if (n > 0) '${c.name} $n',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
        );

      case StatsTile.oftenTogether:
        return TileCard(
          title: tile.title(l10n),
          child: empty
              ? nothing()
              : _OftenTogether(ctx: ctx, onTapOption: openOption),
        );

      case StatsTile.upsAndDowns:
        final u = upsAndDowns(j, r);
        return TileCard(
          title: tile.title(l10n),
          child: u.averageChange == null || u.pairs < 3
              ? Text(l10n.statsUpsTooFew, style: TextStyle(color: muted))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.statsUpsText(fmt1(u.averageChange))),
                    for (final (a, b) in u.biggestDrops.reversed.take(3))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          l10n.statsUpsDrop(
                            date(b.day),
                            MoodStyle.label(a.mood, l10n),
                            MoodStyle.label(b.mood, l10n),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
        );

      case StatsTile.stretches:
        Widget row(Stretch? s, Mood face, String Function(int) label) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MoodFace(face, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: s == null
                        ? Text(
                            l10n.statsNoStretch,
                            style: TextStyle(color: muted),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label(s.length),
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                [
                                  s.length == 1
                                      ? date(s.from)
                                      : '${date(s.from)} – ${date(s.to)}',
                                  for (final c in optionsDuring(j, s))
                                    c.option.name,
                                ].join(' · '),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
        return TileCard(
          title: tile.title(l10n),
          child: Column(
            children: [
              row(goodStretch(j, r), Mood.good, l10n.statsGoodStretch),
              row(hardStretch(j, r), Mood.bad, l10n.statsHardStretch),
            ],
          ),
        );

      case StatsTile.yearInPixels:
        final initials = DateFormat('MMMMM', locale);
        return TileCard(
          title: '${tile.title(l10n)} · ${r.to.year}',
          child: YearPixels(
            year: r.to.year,
            journal: j,
            monthInitials: [
              for (var m = 1; m <= 12; m++) initials.format(DateTime(2026, m)),
            ],
            onTapDay: (d) => showEntrySheet(context, day: d),
          ),
        );
    }
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.value,
    required this.label,
    this.unit,
    this.face,
  });

  final String value;
  final String label;
  final String? unit;
  final Mood? face;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (face != null) ...[
                MoodFace(face!, size: 20),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style:
                            (face == null
                                    ? theme.textTheme.headlineSmall
                                    : theme.textTheme.titleSmall)
                                ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (unit != null)
                        TextSpan(
                          text: ' $unit',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// A 100 % stacked bar of days per mood (best → worst), counts inside.
class _MoodStack extends StatelessWidget {
  const _MoodStack({required this.counts});
  final Map<int, int> counts;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return SizedBox(
      height: 24,
      child: Row(
        children: [
          for (var v = 5; v >= 1; v--)
            if ((counts[v] ?? 0) > 0)
              Expanded(
                flex: counts[v]!,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: MoodStyle.color(Mood.fromValue(v), b),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${counts[v]}',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: MoodStyle.onColor(b),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// The 1–5 labels above the comparison tracks.
class _ScaleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        const Spacer(flex: 5),
        Expanded(
          flex: 6,
          child: LayoutBuilder(
            builder: (_, box) => SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final m in Mood.values)
                    Positioned(
                      left: trackX(box.maxWidth, m.value) - 22,
                      width: 44,
                      child: Text(
                        MoodStyle.label(m, l10n),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 9.5, color: muted),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 62),
      ],
    );
  }
}

class _ComparisonRowView extends StatelessWidget {
  const _ComparisonRowView({
    required this.row,
    required this.overall,
    this.onTap,
  });

  final ComparisonRow row;
  final double overall;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final name = switch (row.kind) {
      RowKind.option => row.option!.name,
      RowKind.nothingLogged => l10n.rowNothingLogged,
      RowKind.notTracked => l10n.rowNotTracked,
    };
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: row.kind == RowKind.option
                      ? null
                      : FontStyle.italic,
                  color: row.kind == RowKind.option ? null : muted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 6,
              child: ComparisonTrack(
                value: row.average,
                overall: overall,
                hollow: row.kind != RowKind.option,
              ),
            ),
            SizedBox(
              width: 62,
              child: Text(
                l10n.perDayCount(fmt1(row.average), row.count),
                textAlign: TextAlign.right,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekdayBar extends StatelessWidget {
  const _WeekdayBar({required this.mean, required this.label});
  final WeekdayMean mean;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = mean.average;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (avg != null)
            Container(
              height: 8 + (avg - 1) / 4 * 56,
              decoration: BoxDecoration(
                color: MoodStyle.color(
                  Mood.fromValue(avg.round().clamp(1, 5)),
                  theme.brightness,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                  bottom: Radius.circular(3),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Options × days, mood strip on top, period bands behind; scrolls sideways.
class _LoggedGrid extends StatelessWidget {
  const _LoggedGrid({required this.ctx, required this.onTapOption});
  final TileContext ctx;
  final ValueChanged<OptionItem> onTapOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final j = ctx.journal;
    final days = ctx.range.days.toList();
    final used = {for (final c in optionCounts(j, ctx.range)) c.option.id};
    final rows = [
      for (final c in j.categories)
        for (final o in c.options)
          if (used.contains(o.id)) o,
    ];
    const cell = 16.0, labelW = 104.0;
    final bands = periodsIn(j, ctx.range, ctx.today);
    final away = <int>{
      for (var i = 0; i < days.length; i++)
        if (bands.any((p) => p.away && p.contains(days[i], today: ctx.today)))
          i,
    };
    final on = theme.colorScheme.primary;
    final off = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelW,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: cell + 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    AppLocalizations.of(context).optionMood,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
              for (final o in rows)
                SizedBox(
                  height: cell,
                  child: InkWell(
                    onTap: () => onTapOption(o),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        o.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < days.length; i++)
                      Container(
                        width: cell,
                        height: cell,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(1.5),
                        child: j.entryOn(days[i]) == null
                            ? DecoratedBox(
                                decoration: BoxDecoration(
                                  color: off,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              )
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  color: MoodStyle.color(
                                    j.entryOn(days[i])!.mood,
                                    theme.brightness,
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                      ),
                  ],
                ),
                for (final o in rows)
                  Row(
                    children: [
                      for (var i = 0; i < days.length; i++)
                        Container(
                          width: cell,
                          height: cell,
                          color: away.contains(i)
                              ? amber.withValues(alpha: 0.13)
                              : null,
                          padding: const EdgeInsets.all(1.5),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color:
                                  (j
                                          .entryOn(days[i])
                                          ?.optionIds
                                          .contains(o.id) ??
                                      false)
                                  ? on
                                  : off,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OftenTogether extends StatefulWidget {
  const _OftenTogether({required this.ctx, required this.onTapOption});
  final TileContext ctx;
  final ValueChanged<OptionItem> onTapOption;

  @override
  State<_OftenTogether> createState() => _OftenTogetherState();
}

class _OftenTogetherState extends State<_OftenTogether> {
  Mood _mood = Mood.good;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final list = oftenTogether(widget.ctx.journal, widget.ctx.range, _mood);
    final days = moodCounts(widget.ctx.journal, widget.ctx.range)[_mood]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.statsOftenOn, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        MoodPicker(value: _mood, onChanged: (m) => setState(() => _mood = m)),
        const SizedBox(height: 8),
        if (list.isEmpty)
          Text(
            l10n.statsNothingInRange,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in list.take(8))
                ActionChip(
                  avatar: Icon(optionIcon(c.option.icon), size: 18),
                  label: Text('${c.option.name}  ${c.count}/$days'),
                  onPressed: () => widget.onTapOption(c.option),
                ),
            ],
          ),
      ],
    );
  }
}
