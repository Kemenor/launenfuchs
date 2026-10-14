import 'dart:convert';

import 'package:archive/archive.dart';

import '../../domain/daylio_backup.dart';

/// Reads a Daylio backup file (design-concept §7.1): a ZIP holding
/// `backup.daylio`, which is base64 of a JSON document. Parsing is defensive —
/// the format is undocumented — and throws [DaylioFormatException] with a
/// plain reason for anything that isn't one.
DaylioBackup parseDaylioBackup(List<int> fileBytes) {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(fileBytes);
  } catch (_) {
    throw const DaylioFormatException('not a zip');
  }
  final inner = archive.findFile('backup.daylio');
  if (inner == null) throw const DaylioFormatException('no backup.daylio');
  final Object? json;
  try {
    final text = utf8.decode(
      base64.decode(
        ascii.decode(inner.content as List<int>).replaceAll(RegExp(r'\s'), ''),
      ),
    );
    json = jsonDecode(text);
  } catch (_) {
    throw const DaylioFormatException('backup.daylio is not base64 JSON');
  }
  if (json is! Map<String, dynamic>) {
    throw const DaylioFormatException('unexpected JSON');
  }
  return daylioFromJson(json);
}

/// The JSON → model step, separate so tests can feed JSON directly.
DaylioBackup daylioFromJson(Map<String, dynamic> j) {
  List<Map<String, dynamic>> list(String key) => [
    for (final e in (j[key] as List? ?? const []))
      if (e is Map<String, dynamic>) e,
  ];
  int? intOf(Object? v) => v is num ? v.toInt() : null;

  // customMoods: id → mood group (1 = rad … 5 = awful).
  final moodGroupOf = <int, int>{};
  for (final m in list('customMoods')) {
    final id = intOf(m['id']);
    final group = intOf(m['mood_group_id']);
    if (id != null && group != null) moodGroupOf[id] = group;
  }

  final groups = [
    for (final g in list('tag_groups'))
      if (intOf(g['id']) != null)
        DaylioGroup(
          id: intOf(g['id'])!,
          name: (g['name'] as String? ?? '').trim(),
          order: intOf(g['order']) ?? 0,
        ),
  ]..sort((a, b) => a.order.compareTo(b.order));

  final tags = [
    for (final t in list('tags'))
      if (intOf(t['id']) != null)
        DaylioTag(
          id: intOf(t['id'])!,
          name: (t['name'] as String? ?? '').trim(),
          groupId: intOf(t['id_tag_group']),
          order: intOf(t['order']) ?? 0,
          archived: (intOf(t['state']) ?? 0) != 0,
        ),
  ]..sort((a, b) => a.order.compareTo(b.order));

  final entries = <DaylioEntry>[];
  for (final e in list('dayEntries')) {
    final year = intOf(e['year']);
    final month = intOf(e['month']);
    final day = intOf(e['day']);
    final moodId = intOf(e['mood']);
    if (year == null || month == null || day == null || moodId == null) {
      continue;
    }
    // Unknown custom mood → its id is the group for the five defaults.
    final group = (moodGroupOf[moodId] ?? moodId).clamp(1, 5);
    final title = (e['note_title'] as String? ?? '').trim();
    final note = htmlToText(e['note'] as String? ?? '');
    entries.add(
      DaylioEntry(
        // Daylio months are 0-based.
        year: year,
        month: month + 1,
        day: day,
        hour: intOf(e['hour']) ?? 12,
        minute: intOf(e['minute']) ?? 0,
        moodGroup: group,
        tagIds: [
          for (final t in (e['tags'] as List? ?? const []))
            if (t is num) t.toInt(),
        ],
        note: [title, note].where((s) => s.isNotEmpty).join('\n'),
      ),
    );
  }

  return DaylioBackup(
    version: intOf(j['version']),
    groups: groups,
    tags: tags,
    entries: entries,
    photoCount: list('assets').length,
    goalCount: list('goals').length,
  );
}

/// Daylio notes are a little HTML: `<br>` → newline, other tags dropped,
/// the common entities decoded.
String htmlToText(String html) {
  var s = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|div|li)>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '');
  const entities = {
    '&nbsp;': ' ',
    '&lt;': '<',
    '&gt;': '>',
    '&quot;': '"',
    '&#39;': "'",
    '&apos;': "'",
    '&amp;': '&', // last, so "&amp;lt;" stays "&lt;"
  };
  entities.forEach((k, v) => s = s.replaceAll(k, v));
  return s
      .split('\n')
      .map((l) => l.trimRight())
      .join('\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
