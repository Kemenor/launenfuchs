import 'category.dart';

/// The neutral starter set for a fresh install (design-concept §2.7). Names
/// come in localised (they become the user's own data once seeded); icons are
/// catalogue slugs.
class StarterOption {
  const StarterOption(this.name, this.icon, {this.isDefault = false});
  final String name;
  final String icon;
  final bool isDefault;
}

class StarterCategory {
  const StarterCategory(
    this.name,
    this.icon,
    this.mode,
    this.options, {
    this.display = CategoryDisplay.chips,
  });
  final String name;
  final String icon;
  final CategoryMode mode;
  final CategoryDisplay display;
  final List<StarterOption> options;
}

/// The localised strings the starter set needs.
class StarterNames {
  const StarterNames({
    required this.work,
    required this.workedNormally,
    required this.workedLess,
    required this.dayOff,
    required this.sick,
    required this.health,
    required this.walk,
    required this.exercise,
    required this.sport,
    required this.social,
    required this.friends,
    required this.family,
    required this.partner,
    required this.timeAlone,
    required this.hobbies,
    required this.reading,
    required this.gaming,
    required this.music,
    required this.creative,
    required this.sleep,
    required this.sleepPoor,
    required this.sleepOk,
    required this.sleepGood,
  });

  final String work, workedNormally, workedLess, dayOff, sick;
  final String health, walk, exercise, sport;
  final String social, friends, family, partner, timeAlone;
  final String hobbies, reading, gaming, music, creative;
  final String sleep, sleepPoor, sleepOk, sleepGood;
}

List<StarterCategory> starterSet(StarterNames n) => [
  StarterCategory(n.work, 'work', CategoryMode.one, [
    StarterOption(n.workedNormally, 'work'),
    StarterOption(n.workedLess, 'work_history'),
    StarterOption(n.dayOff, 'beach_access', isDefault: true),
    StarterOption(n.sick, 'sick'),
  ]),
  StarterCategory(n.health, 'favorite', CategoryMode.any, [
    StarterOption(n.walk, 'directions_walk'),
    StarterOption(n.exercise, 'fitness_center'),
    StarterOption(n.sport, 'sports_soccer'),
  ]),
  StarterCategory(n.social, 'groups', CategoryMode.any, [
    StarterOption(n.friends, 'groups'),
    StarterOption(n.family, 'family_restroom'),
    StarterOption(n.partner, 'favorite'),
    StarterOption(n.timeAlone, 'person'),
  ]),
  StarterCategory(n.hobbies, 'palette', CategoryMode.any, [
    StarterOption(n.reading, 'menu_book'),
    StarterOption(n.gaming, 'sports_esports'),
    StarterOption(n.music, 'music_note'),
    StarterOption(n.creative, 'palette'),
  ]),
  StarterCategory(n.sleep, 'bedtime', CategoryMode.one, [
    StarterOption(n.sleepPoor, 'bedtime_off'),
    StarterOption(n.sleepOk, 'bedtime'),
    StarterOption(n.sleepGood, 'hotel'),
  ], display: CategoryDisplay.slider),
];
