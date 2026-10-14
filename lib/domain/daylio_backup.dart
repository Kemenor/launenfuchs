/// A parsed Daylio backup (design-concept §7) — plain values, no I/O.
class DaylioGroup {
  const DaylioGroup({required this.id, required this.name, this.order = 0});
  final int id;
  final String name;
  final int order;
}

class DaylioTag {
  const DaylioTag({
    required this.id,
    required this.name,
    required this.groupId,
    this.order = 0,
    this.archived = false,
  });
  final int id;
  final String name;

  /// Null for tags outside any group (very old backups).
  final int? groupId;
  final int order;
  final bool archived;
}

class DaylioEntry {
  const DaylioEntry({
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.moodGroup,
    this.tagIds = const [],
    this.note = '',
  });

  /// [month] is 1-based here (the parser fixed Daylio's 0-based months).
  final int year, month, day, hour, minute;

  /// Daylio's mood group: 1 = rad … 5 = awful.
  final int moodGroup;
  final List<int> tagIds;
  final String note;

  /// Launenfuchs mood value: 5 = best.
  int get moodValue => 6 - moodGroup;
}

class DaylioBackup {
  const DaylioBackup({
    this.version,
    this.groups = const [],
    this.tags = const [],
    this.entries = const [],
    this.photoCount = 0,
    this.goalCount = 0,
  });

  final int? version;
  final List<DaylioGroup> groups;
  final List<DaylioTag> tags;
  final List<DaylioEntry> entries;
  final int photoCount;
  final int goalCount;
}

class DaylioFormatException implements Exception {
  const DaylioFormatException(this.reason);
  final String reason;
  @override
  String toString() => 'Not a Daylio backup ($reason)';
}
