import '../../l10n/app_localizations.dart';

/// The Stats tiles (design-concept §5.2). Ids are persisted — never rename.
enum StatsTile {
  summary('summary', true),
  dayByDay('dayByDay', true),
  byPeriod('byPeriod', true),
  alongside('alongside', true),
  grid('grid', true),
  weekday('weekday', true),
  notes('notes', true),
  moodCount('moodCount', false),
  optionCounts('optionCounts', false),
  oftenTogether('oftenTogether', false),
  upsAndDowns('upsAndDowns', false),
  stretches('stretches', false),
  yearInPixels('yearInPixels', false);

  const StatsTile(this.id, this.onByDefault);
  final String id;
  final bool onByDefault;

  static StatsTile? byId(String id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }

  String title(AppLocalizations l) => switch (this) {
    summary => l.tileSummary,
    dayByDay => l.tileDayByDay,
    byPeriod => l.tileByPeriod,
    alongside => l.tileAlongside,
    grid => l.tileGrid,
    weekday => l.tileWeekday,
    notes => l.tileNotes,
    moodCount => l.tileMoodCount,
    optionCounts => l.tileOptionCounts,
    oftenTogether => l.tileOftenTogether,
    upsAndDowns => l.tileUpsAndDowns,
    stretches => l.tileStretches,
    yearInPixels => l.tileYearInPixels,
  };
}

/// The effective layout: the stored order (unknown ids dropped), then any
/// tile the stored list doesn't know yet, with its default switch.
List<(StatsTile, bool)> effectiveTiles(List<(String, bool)>? stored) {
  final out = <(StatsTile, bool)>[];
  final seen = <StatsTile>{};
  for (final (id, on) in stored ?? const <(String, bool)>[]) {
    final t = StatsTile.byId(id);
    if (t != null && seen.add(t)) out.add((t, on));
  }
  for (final t in StatsTile.values) {
    if (seen.add(t)) out.add((t, t.onByDefault));
  }
  return out;
}
