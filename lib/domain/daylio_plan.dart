import 'category.dart';
import 'daylio_backup.dart';
import 'day.dart';
import 'icon_guess.dart';

/// The Daylio import as a **mapping** (design-concept §7.2): every group and
/// tag is kept (renamed), merged into another, or dropped; one-per-day
/// categories get a default and may fill their empty days. All pure: the
/// stepper edits a [DaylioMapping], [planImport] turns it into what gets
/// written plus every count the UI shows.

enum MapAction { keep, merge, drop }

class GroupChoice {
  GroupChoice({
    required this.action,
    required this.name,
    required this.icon,
    required this.mode,
    this.display = CategoryDisplay.chips,
    this.mergeInto,
  });

  MapAction action;
  String name;
  String icon;
  CategoryMode mode;
  CategoryDisplay display;

  /// Target group id when [action] is merge.
  int? mergeInto;
}

class TagChoice {
  TagChoice({
    required this.action,
    required this.name,
    required this.icon,
    this.mergeInto,
  });

  MapAction action;
  String name;
  String icon;

  /// Target tag id when [action] is merge.
  int? mergeInto;
}

/// Per one-per-day category (keyed by source group id).
class GroupDefaults {
  GroupDefaults({this.defaultTagId, this.fillTagId, this.trackedFrom});

  /// Pre-selected on new entries.
  int? defaultTagId;

  /// Fill days with nothing logged (since [trackedFrom]) with this tag.
  int? fillTagId;

  /// Null = the first use (after merges).
  Day? trackedFrom;
}

class DaylioMapping {
  DaylioMapping({
    required this.groups,
    required this.tags,
    Map<int, GroupDefaults>? defaults,
  }) : defaults = defaults ?? {};

  final Map<int, GroupChoice> groups;
  final Map<int, TagChoice> tags;
  final Map<int, GroupDefaults> defaults;

  GroupDefaults defaultsFor(int groupId) =>
      defaults[groupId] ??= GroupDefaults();
}

/// Tags outside any Daylio group land in this synthetic group.
const ungroupedId = -1;

// --- analysis: facts about the backup itself ---------------------------------

/// One day after folding several Daylio entries into one (§7.4).
class MergedDay {
  MergedDay({
    required this.day,
    required this.mood,
    required this.tagIds,
    required this.note,
    required this.loggedAt,
    required this.sourceCount,
  });

  final Day day;

  /// 1…5, 5 = best: the mean of the day's entries, rounded half up.
  final int mood;
  final Set<int> tagIds;
  final String note;
  final DateTime loggedAt;
  final int sourceCount;
}

class TagStats {
  int uses = 0;
  Day? first;
  Day? last;
}

class GroupStats {
  int usedDays = 0;

  /// Days with two or more of the group's tags (→ suggests "any number").
  int multiDays = 0;
  Day? first;
}

class DaylioAnalysis {
  DaylioAnalysis._(this.backup);

  factory DaylioAnalysis.of(DaylioBackup backup) {
    final a = DaylioAnalysis._(backup);
    a._run();
    return a;
  }

  final DaylioBackup backup;
  final List<MergedDay> days = [];
  final Map<int, TagStats> tagStats = {};
  final Map<int, GroupStats> groupStats = {};

  /// Days that had several Daylio entries.
  int mergedDayCount = 0;
  int noteCount = 0;

  int groupOf(int tagId) {
    for (final t in backup.tags) {
      if (t.id == tagId) return t.groupId ?? ungroupedId;
    }
    return ungroupedId;
  }

  Day? get firstDay => days.isEmpty ? null : days.first.day;
  Day? get lastDay => days.isEmpty ? null : days.last.day;

  /// The groups in display order, the synthetic "ungrouped" one last if used.
  List<DaylioGroup> get groups => [
    ...backup.groups,
    if (backup.tags.any((t) => t.groupId == null))
      const DaylioGroup(id: ungroupedId, name: '', order: 1 << 30),
  ];

  List<DaylioTag> tagsIn(int groupId) => [
    for (final t in backup.tags)
      if ((t.groupId ?? ungroupedId) == groupId) t,
  ];

  void _run() {
    final byDay = <Day, List<DaylioEntry>>{};
    for (final e in backup.entries) {
      (byDay[Day(e.year, e.month, e.day)] ??= []).add(e);
    }
    final keys = byDay.keys.toList()..sort();
    final knownTags = {for (final t in backup.tags) t.id};
    for (final day in keys) {
      final list = byDay[day]!
        ..sort((a, b) => (a.hour * 60 + a.minute) - (b.hour * 60 + b.minute));
      if (list.length > 1) mergedDayCount++;
      final sum = list.fold<int>(0, (s, e) => s + e.moodValue);
      final mood = (sum / list.length + 0.5).floor().clamp(1, 5);
      final tags = {
        for (final e in list)
          for (final t in e.tagIds)
            if (knownTags.contains(t)) t,
      };
      final note = [
        for (final e in list)
          if (e.note.isNotEmpty) e.note,
      ].join('\n\n');
      if (note.isNotEmpty) noteCount++;
      final first = list.first;
      days.add(
        MergedDay(
          day: day,
          mood: mood,
          tagIds: tags,
          note: note,
          loggedAt: DateTime(
            first.year,
            first.month,
            first.day,
            first.hour,
            first.minute,
          ),
          sourceCount: list.length,
        ),
      );
      final perGroup = <int, int>{};
      for (final t in tags) {
        final s = tagStats[t] ??= TagStats();
        s.uses++;
        s.first ??= day;
        s.last = day;
        final g = groupOf(t);
        perGroup[g] = (perGroup[g] ?? 0) + 1;
      }
      perGroup.forEach((g, n) {
        final s = groupStats[g] ??= GroupStats();
        s.usedDays++;
        if (n > 1) s.multiDays++;
        s.first ??= day;
      });
    }
  }

  /// The starting mapping: [saved] choices first (a repeat import), the
  /// suggestions for everything new — mode from the data, never-used tags
  /// dropped, icons guessed from the names.
  DaylioMapping suggestedMapping({SavedMapping? saved}) {
    final groups = <int, GroupChoice>{};
    for (final g in this.groups) {
      final stats = groupStats[g.id];
      final prior = saved?.groups[g.id];
      final tags = tagsIn(g.id);
      groups[g.id] =
          prior ??
          GroupChoice(
            action: MapAction.keep,
            name: g.name,
            icon: guessIcon(g.name, fallback: _firstTagIcon(tags)),
            mode: (stats?.multiDays ?? 0) > 0
                ? CategoryMode.any
                : CategoryMode.one,
          );
    }
    final tags = <int, TagChoice>{};
    for (final t in backup.tags) {
      tags[t.id] =
          saved?.tags[t.id] ??
          TagChoice(
            action: (tagStats[t.id]?.uses ?? 0) == 0
                ? MapAction.drop
                : MapAction.keep,
            name: t.name,
            icon: guessIcon(t.name),
          );
    }
    return DaylioMapping(groups: groups, tags: tags);
  }

  String _firstTagIcon(List<DaylioTag> tags) =>
      tags.isEmpty ? fallbackIconSlug : guessIcon(tags.first.name);
}

/// Choices remembered from an earlier import (the `import_maps` table).
class SavedMapping {
  const SavedMapping({this.groups = const {}, this.tags = const {}});
  final Map<int, GroupChoice> groups;
  final Map<int, TagChoice> tags;
}

// --- the plan ---------------------------------------------------------------

class PlannedOption {
  PlannedOption({
    required this.sourceTagId,
    required this.name,
    required this.icon,
  });
  final int sourceTagId;
  final String name;
  final String icon;
}

class PlannedCategory {
  PlannedCategory({
    required this.sourceGroupId,
    required this.name,
    required this.icon,
    required this.mode,
    required this.display,
    required this.options,
    this.defaultTagId,
    this.trackedFrom,
  });

  final int sourceGroupId;
  final String name;
  final String icon;
  final CategoryMode mode;
  final CategoryDisplay display;
  final List<PlannedOption> options;
  final int? defaultTagId;

  /// The tracking span's start; null = no day ever used it (then the span
  /// opens on the import's last day).
  final Day? trackedFrom;

  /// Days logged since [trackedFrom] with nothing from this category, before
  /// any fill.
  int emptyDays = 0;

  /// Days filled with the fill tag.
  int filledDays = 0;

  /// One-per-day only: days that end up with two options (kept, §4.3).
  int collisionDays = 0;
}

class PlannedEntry {
  PlannedEntry({
    required this.day,
    required this.mood,
    required this.note,
    required this.loggedAt,
    required this.tagIds,
  });
  final Day day;
  final int mood;
  final String? note;
  final DateTime loggedAt;

  /// Resolved (kept) source tag ids — each maps to a [PlannedOption].
  final Set<int> tagIds;
}

class ImportPlan {
  ImportPlan({
    required this.categories,
    required this.entries,
    required this.mapping,
  });

  final List<PlannedCategory> categories;
  final List<PlannedEntry> entries;
  final DaylioMapping mapping;

  int get optionCount => categories.fold(0, (n, c) => n + c.options.length);
}

/// Where tag [tagId] ends up after merges: a kept tag id, or null (dropped).
/// Merge chains are followed; a cycle or a dropped target drops it.
int? resolveTag(DaylioMapping m, int tagId) {
  final seen = <int>{};
  int? id = tagId;
  while (id != null && seen.add(id)) {
    final c = m.tags[id];
    if (c == null) return null;
    switch (c.action) {
      case MapAction.keep:
        return id;
      case MapAction.drop:
        return null;
      case MapAction.merge:
        id = c.mergeInto;
    }
  }
  return null;
}

/// Where group [groupId] ends up: a kept group id, or null (dropped).
int? resolveGroup(DaylioMapping m, int groupId) {
  final seen = <int>{};
  int? id = groupId;
  while (id != null && seen.add(id)) {
    final c = m.groups[id];
    if (c == null) return null;
    switch (c.action) {
      case MapAction.keep:
        return id;
      case MapAction.drop:
        return null;
      case MapAction.merge:
        id = c.mergeInto;
    }
  }
  return null;
}

/// Turns [analysis] + [mapping] into the categories and entries to write.
ImportPlan planImport(DaylioAnalysis analysis, DaylioMapping mapping) {
  // 1. Which kept tag lands in which kept category. A kept tag belongs to its
  //    own group's resolved group; dropping a group drops its kept tags.
  final categoryOfTag = <int, int>{};
  for (final t in analysis.backup.tags) {
    if (resolveTag(mapping, t.id) != t.id) continue;
    final g = resolveGroup(mapping, t.groupId ?? ungroupedId);
    if (g != null) categoryOfTag[t.id] = g;
  }
  int? finalTag(int sourceTag) {
    final r = resolveTag(mapping, sourceTag);
    return r != null && categoryOfTag.containsKey(r) ? r : null;
  }

  // 2. Entries with resolved tags.
  final entries = <PlannedEntry>[
    for (final d in analysis.days)
      PlannedEntry(
        day: d.day,
        mood: d.mood,
        note: d.note.isEmpty ? null : d.note,
        loggedAt: d.loggedAt,
        tagIds: {
          for (final t in d.tagIds)
            if (finalTag(t) != null) finalTag(t)!,
        },
      ),
  ];

  // 3. Categories in Daylio's order, options in Daylio's order.
  final categories = <PlannedCategory>[];
  for (final g in analysis.groups) {
    final choice = mapping.groups[g.id];
    if (choice == null || resolveGroup(mapping, g.id) != g.id) continue;
    final options = [
      for (final src in analysis.groups)
        for (final t in analysis.tagsIn(src.id))
          if (categoryOfTag[t.id] == g.id)
            PlannedOption(
              sourceTagId: t.id,
              name: mapping.tags[t.id]!.name,
              icon: mapping.tags[t.id]!.icon,
            ),
    ];
    final optionIds = {for (final o in options) o.sourceTagId};
    Day? firstUse;
    for (final e in entries) {
      if (e.tagIds.any(optionIds.contains)) {
        firstUse = e.day;
        break;
      }
    }
    final defaults = mapping.defaults[g.id];
    final one = choice.mode == CategoryMode.one;
    final c = PlannedCategory(
      sourceGroupId: g.id,
      name: choice.name,
      icon: choice.icon,
      mode: choice.mode,
      display: one ? choice.display : CategoryDisplay.chips,
      options: options,
      defaultTagId: one && optionIds.contains(defaults?.defaultTagId)
          ? defaults!.defaultTagId
          : null,
      trackedFrom: defaults?.trackedFrom ?? firstUse,
    );

    // 4. Empty days, fills and collisions.
    final from = c.trackedFrom;
    final fill = one && optionIds.contains(defaults?.fillTagId)
        ? defaults!.fillTagId
        : null;
    for (final e in entries) {
      if (from == null || e.day.isBefore(from)) continue;
      final inCat = e.tagIds.where(optionIds.contains).length;
      if (inCat == 0) {
        c.emptyDays++;
        if (fill != null) {
          e.tagIds.add(fill);
          c.filledDays++;
        }
      } else if (one && inCat > 1) {
        c.collisionDays++;
      }
    }
    categories.add(c);
  }

  return ImportPlan(categories: categories, entries: entries, mapping: mapping);
}

/// How many days lose tag [tagId] if it is dropped (its use count).
int daysAffectedByDrop(DaylioAnalysis a, int tagId) =>
    a.tagStats[tagId]?.uses ?? 0;
