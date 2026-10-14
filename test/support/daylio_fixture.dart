import 'dart:convert';

import 'package:archive/archive.dart';

/// Builds a synthetic `.daylio` file (zip → backup.daylio → base64 JSON),
/// shaped like a real version-15 backup. Months are 0-based, mood ids are
/// custom-mood ids (group 1 = rad … 5 = awful), notes are HTML.
List<int> daylioFile(Map<String, dynamic> json) {
  final inner = ascii.encode(base64.encode(utf8.encode(jsonEncode(json))));
  final archive = Archive()
    ..addFile(ArchiveFile('backup.daylio', inner.length, inner));
  return ZipEncoder().encode(archive);
}

Map<String, dynamic> e(
  int month0,
  int day,
  int moodGroup,
  List<int> tags, {
  int hour = 20,
  String note = '',
  String title = '',
}) => {
  'year': 2026,
  'month': month0,
  'day': day,
  'hour': hour,
  'minute': 0,
  'mood': moodGroup, // custom mood ids 1..5 map to groups 1..5 below
  'tags': tags,
  'note': note,
  'note_title': title,
};

/// Groups: 7 Work, 3 Health, 12 Coffee. Tags: 61 Worked, 62 Less, 77 Holiday
/// (never used), 18 Walk, 22 Sport, 69 Gym, 73 None, 74 One, 75 Two.
Map<String, dynamic> sampleDaylioJson() => {
  'version': 15,
  'customMoods': [
    for (var i = 1; i <= 5; i++)
      {'id': i, 'mood_group_id': i, 'custom_name': ''},
  ],
  'tag_groups': [
    {'id': 7, 'name': 'Productivity', 'order': 1},
    {'id': 3, 'name': 'Health', 'order': 2},
    {'id': 12, 'name': 'Coffee', 'order': 3},
  ],
  'tags': [
    {
      'id': 61,
      'name': 'Worked Normally',
      'id_tag_group': 7,
      'order': 1,
      'state': 0,
    },
    {
      'id': 62,
      'name': 'worked less',
      'id_tag_group': 7,
      'order': 2,
      'state': 0,
    },
    {'id': 77, 'name': 'Holiday', 'id_tag_group': 7, 'order': 3, 'state': 0},
    {'id': 18, 'name': 'walk', 'id_tag_group': 3, 'order': 1, 'state': 0},
    {'id': 22, 'name': 'sport', 'id_tag_group': 3, 'order': 2, 'state': 0},
    {'id': 69, 'name': 'gym', 'id_tag_group': 3, 'order': 3, 'state': 0},
    {'id': 73, 'name': 'Nothing', 'id_tag_group': 12, 'order': 1, 'state': 0},
    {'id': 74, 'name': 'one cup', 'id_tag_group': 12, 'order': 2, 'state': 0},
    {'id': 75, 'name': 'two cups', 'id_tag_group': 12, 'order': 3, 'state': 0},
  ],
  'dayEntries': [
    // Sep 8 (month0 = 8): worked, walk + gym (Health has a two-tag day).
    e(8, 8, 2, [61, 18, 69], note: 'Long day<br>but ok &amp; fine'),
    e(8, 9, 3, [62, 22]),
    // Sep 10: nothing from Productivity (an empty day), coffee starts.
    e(8, 10, 1, [18, 74]),
    // Sep 11: two Daylio entries → one day: moods good(2→4) + awful(5→1)
    // mean 2.5 → rounds half up to 3; tags united; notes joined in time order.
    e(8, 11, 2, [61, 73], hour: 9, note: 'morning'),
    e(8, 11, 5, [18], hour: 22, title: 'Evening', note: 'tired'),
  ],
  'assets': [],
  'goals': [],
};
