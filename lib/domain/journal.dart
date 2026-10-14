import 'category.dart';
import 'day.dart';
import 'mood.dart';

/// The in-memory journal — everything the UI and the stats engine read, as
/// plain immutable values (no drift, no Flutter). Built by the repository
/// from the database; tests build it by hand.

/// A tracked date range of a category (design-concept §2.3). [to] null = open.
class DaySpan {
  const DaySpan(this.from, [this.to]);

  final Day from;
  final Day? to;

  bool contains(Day day) =>
      !day.isBefore(from) && (to == null || !day.isAfter(to!));
}

/// A value a category can take (§2.4).
class OptionItem {
  const OptionItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.icon,
    this.sort = 0,
    this.hidden = false,
  });

  final int id;
  final int categoryId;
  final String name;

  /// An icon slug from the curated catalogue (ui/option_icons.dart).
  final String icon;
  final int sort;
  final bool hidden;
}

/// Something you track (§2.3), with its options in display order.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.mode,
    this.display = CategoryDisplay.chips,
    this.defaultOptionId,
    this.sort = 0,
    this.hidden = false,
    this.spans = const [],
    this.options = const [],
  });

  final int id;
  final String name;
  final String icon;
  final CategoryMode mode;
  final CategoryDisplay display;
  final int? defaultOptionId;
  final int sort;
  final bool hidden;
  final List<DaySpan> spans;
  final List<OptionItem> options;

  /// Options shown on the entry sheet.
  List<OptionItem> get visibleOptions => [
    for (final o in options)
      if (!o.hidden) o,
  ];

  /// Whether [day] falls in a tracking span (§4.3: outside = *not tracked*).
  bool tracks(Day day) => spans.any((s) => s.contains(day));

  /// The slider only exists for one-per-day categories.
  bool get showsSlider =>
      mode == CategoryMode.one && display == CategoryDisplay.slider;

  OptionItem? get defaultOption {
    final id = defaultOptionId;
    if (id == null) return null;
    for (final o in options) {
      if (o.id == id && !o.hidden) return o;
    }
    return null;
  }
}

/// One rated day (§2.2).
class Entry {
  const Entry({
    required this.id,
    required this.day,
    required this.loggedAt,
    required this.mood,
    this.note,
    this.optionIds = const {},
  });

  final int id;
  final Day day;
  final DateTime loggedAt;
  final Mood mood;
  final String? note;
  final Set<int> optionIds;

  bool get hasNote => note != null && note!.trim().isNotEmpty;
}

/// A named date range (§2.5). [end] null = ongoing.
class Period {
  const Period({
    required this.id,
    required this.name,
    required this.start,
    this.end,
    this.away = false,
    this.icon,
  });

  final int id;
  final String name;
  final Day start;
  final Day? end;
  final bool away;
  final String? icon;

  bool get ongoing => end == null;

  /// Whether [day] is inside the period; an ongoing period runs to [today].
  bool contains(Day day, {required Day today}) {
    final last = end ?? today;
    return !day.isBefore(start) && !day.isAfter(last);
  }
}

/// A snapshot of the whole journal.
class Journal {
  Journal({
    required List<Category> categories,
    required List<Entry> entries,
    this.periods = const [],
    this.moodLabels = const {},
  }) : categories = List.unmodifiable(
         [...categories]..sort((a, b) => a.sort.compareTo(b.sort)),
       ),
       // Newest first — the order the Journal list shows.
       entries = List.unmodifiable(
         [...entries]..sort((a, b) => b.day.compareTo(a.day)),
       ) {
    for (final e in this.entries) {
      _byDay[e.day] = e;
    }
    for (final c in this.categories) {
      for (final o in c.options) {
        _options[o.id] = o;
        _categoryOf[o.id] = c;
      }
    }
  }

  static final empty = Journal(categories: const [], entries: const []);

  final List<Category> categories;
  final List<Entry> entries;
  final List<Period> periods;

  /// Renamed mood labels (§2.1): value → label; missing = localised default.
  final Map<int, String> moodLabels;

  final Map<Day, Entry> _byDay = {};
  final Map<int, OptionItem> _options = {};
  final Map<int, Category> _categoryOf = {};

  Entry? entryOn(Day day) => _byDay[day];
  OptionItem? option(int id) => _options[id];
  Category? categoryOfOption(int optionId) => _categoryOf[optionId];

  /// Categories the entry sheet shows.
  List<Category> get visibleCategories => [
    for (final c in categories)
      if (!c.hidden) c,
  ];

  bool get isEmpty => entries.isEmpty;
}
