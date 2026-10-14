import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../domain/journal.dart';
import '../../domain/stats.dart';
import '../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../option_icons.dart';
import 'charts.dart';
import 'stats_screen.dart' show TileCard, fmt1;

/// Option detail (design-concept §5.3): tapped from any option in Stats.
/// A drill-down, so its sections are fixed, not customizable.
class OptionDetailScreen extends ConsumerWidget {
  const OptionDetailScreen({
    super.key,
    required this.option,
    required this.range,
  });

  final OptionItem option;
  final StatsRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final locale = Localizations.localeOf(context).toString();
    final j = ref.watch(journalProvider).value ?? Journal.empty;
    final today = logicalToday(ref);
    final d = optionDetail(j, range, option, today);

    Widget kv(String k, Widget v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          v,
        ],
      ),
    );
    Text bold(String s) => Text(
      s,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
    String withN(double? v, int n) => '${fmt1(v)} · ${l10n.optionDaysCount(n)}';

    final diff = d.count - d.previousCount;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(optionIcon(option.icon), color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(child: Text(option.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 6,
          bottom: 24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          TileCard(
            title: l10n.optionHowOften,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FrequencyStrip(
                  days: range.days.toList(),
                  journal: j,
                  marked: d.days,
                ),
                const SizedBox(height: 6),
                kv(
                  l10n.optionLogged,
                  bold(l10n.optionLoggedValue(d.count, range.length)),
                ),
                kv(
                  l10n.optionVsPrevious(range.length),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bold('${d.previousCount}'),
                      if (diff != 0) ...[
                        const SizedBox(width: 4),
                        Icon(
                          diff > 0
                              ? Symbols.arrow_upward_rounded
                              : Symbols.arrow_downward_rounded,
                          size: 16,
                        ),
                        bold('${diff.abs()}'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (d.count == 0)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.optionNotLogged,
                textAlign: TextAlign.center,
                style: TextStyle(color: muted),
              ),
            )
          else ...[
            TileCard(
              title: l10n.optionMood,
              child: Column(
                children: [
                  kv(l10n.optionOnDays, bold(withN(d.average, d.count))),
                  kv(
                    l10n.optionNextDay,
                    bold(withN(d.nextDayAverage, d.nextDayCount)),
                  ),
                  kv(l10n.optionYourAverage, bold(fmt1(d.overallAverage))),
                  const SizedBox(height: 4),
                  Text(
                    l10n.statsCaveat,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            TileCard(
              title: l10n.optionWhenInWeek,
              child: Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Column(
                        children: [
                          bold('${d.weekdayCounts[i]}'),
                          Text(
                            DateFormat.E(
                              locale,
                            ).format(DateTime(2026, 10, 5 + i)),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (d.together.isNotEmpty)
              TileCard(
                title: l10n.optionTogether,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (o, share) in d.together.take(8))
                      Chip(
                        avatar: Icon(optionIcon(o.icon), size: 18),
                        label: Text('${o.name}  ${(share * 100).round()} %'),
                      ),
                  ],
                ),
              ),
            TileCard(
              title: l10n.optionByPeriod,
              child: Column(
                children: [
                  for (final (p, n) in d.byPeriod) kv(p.name, bold('$n')),
                  kv(
                    l10n.optionLongestRuns,
                    bold(l10n.optionRunsValue(d.longestWith, d.longestWithout)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
