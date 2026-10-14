import 'package:launenfuchs/domain/category.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/journal.dart';
import 'package:launenfuchs/domain/mood.dart';

/// Hand-built journals for domain tests (no database).
const work = Category(
  id: 1,
  name: 'Work',
  icon: 'work',
  mode: CategoryMode.one,
  defaultOptionId: 13,
  spans: [DaySpan(Day(2026, 9, 1))],
  options: [
    OptionItem(id: 11, categoryId: 1, name: 'Worked normally', icon: 'work'),
    OptionItem(id: 12, categoryId: 1, name: 'Worked less', icon: 'work'),
    OptionItem(id: 13, categoryId: 1, name: 'Day off', icon: 'beach_access'),
  ],
);

const health = Category(
  id: 2,
  name: 'Health',
  icon: 'favorite',
  mode: CategoryMode.any,
  sort: 1,
  spans: [DaySpan(Day(2026, 9, 1))],
  options: [
    OptionItem(id: 21, categoryId: 2, name: 'Walk', icon: 'directions_walk'),
    OptionItem(id: 22, categoryId: 2, name: 'Gym', icon: 'fitness_center'),
  ],
);

const coffee = Category(
  id: 3,
  name: 'Coffee',
  icon: 'coffee',
  mode: CategoryMode.one,
  display: CategoryDisplay.slider,
  sort: 2,
  spans: [DaySpan(Day(2026, 9, 18))],
  options: [
    OptionItem(id: 31, categoryId: 3, name: 'None', icon: 'block'),
    OptionItem(id: 32, categoryId: 3, name: 'One', icon: 'coffee'),
    OptionItem(id: 33, categoryId: 3, name: 'Two', icon: 'coffee'),
  ],
);

Entry entry(Day day, Mood mood, [Set<int> options = const {}, String? note]) =>
    Entry(
      id: day.hashCode,
      day: day,
      loggedAt: day.noon.add(const Duration(hours: 9)),
      mood: mood,
      note: note,
      optionIds: options,
    );

Journal journalOf(List<Entry> entries, {List<Period> periods = const []}) =>
    Journal(
      categories: const [work, health, coffee],
      entries: entries,
      periods: periods,
    );
