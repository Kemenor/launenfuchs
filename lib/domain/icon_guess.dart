/// Guesses an icon slug for an imported name (Daylio's own icon ids don't
/// map to anything we ship). Keywords in en/de/fr/it, first match wins;
/// the user can change any icon later.
const fallbackIconSlug = 'label';

const _keywords = <(String, String)>[
  ('sick', 'sick'), ('krank', 'sick'), ('malad', 'sick'), ('malat', 'sick'),
  ('holiday', 'beach_access'), ('vacation', 'beach_access'),
  ('urlaub', 'beach_access'), ('ferien', 'beach_access'),
  ('day off', 'beach_access'), ('frei', 'beach_access'),
  ('vacance', 'beach_access'), ('congé', 'beach_access'),
  ('too much', 'work_alert'), ('overtime', 'work_alert'),
  ('less', 'work_history'), ('weniger', 'work_history'),
  ('barely', 'construction'), ("didn't work", 'work_off'),
  ('work', 'work'), ('arbeit', 'work'), ('travail', 'work'),
  ('lavor', 'work'), ('productiv', 'work'), ('job', 'work'),
  ('walk', 'directions_walk'), ('spazier', 'directions_walk'),
  ('marche', 'directions_walk'), ('passeggi', 'directions_walk'),
  ('run', 'directions_run'), ('jog', 'directions_run'),
  ('lauf', 'directions_run'), ('bike', 'directions_bike'),
  ('velo', 'directions_bike'), ('cycl', 'directions_bike'),
  ('swim', 'pool'), ('schwimm', 'pool'), ('yoga', 'self_improvement'),
  ('meditat', 'self_improvement'), ('gym', 'fitness_center'),
  ('fitness', 'fitness_center'), ('exercise', 'fitness_center'),
  ('workout', 'fitness_center'), ('training', 'fitness_center'),
  ('sport', 'sports_soccer'), ('hike', 'hiking'), ('wander', 'hiking'),
  ('read', 'menu_book'), ('lese', 'menu_book'), ('lesen', 'menu_book'),
  ('lectur', 'menu_book'), ('gam', 'sports_esports'),
  ('spiel', 'sports_esports'), ('music', 'music_note'),
  ('musik', 'music_note'), ('musique', 'music_note'),
  ('movie', 'movie'), ('film', 'movie'), ('tv', 'tv'), ('series', 'tv'),
  ('writ', 'edit'), ('schreib', 'edit'), ('develop', 'code'),
  ('code', 'code'), ('program', 'code'), ('paint', 'palette'),
  ('draw', 'draw'), ('creative', 'palette'), ('kreativ', 'palette'),
  // family before friends: "family" contains the French "ami".
  ('family', 'family_restroom'), ('famil', 'family_restroom'),
  ('friend', 'groups'), ('freund', 'groups'), ('ami', 'groups'),
  ('social', 'groups'), ('partner', 'favorite'),
  ('date', 'favorite'), ('love', 'favorite'), ('alone', 'person'),
  ('allein', 'person'), ('party', 'celebration'),
  ('sleep', 'bedtime'), ('schlaf', 'bedtime'), ('sommeil', 'bedtime'),
  ('nap', 'hotel'), ('coffee', 'coffee'), ('kaffee', 'coffee'),
  ('café', 'coffee'), ('tea', 'local_cafe'), ('tee', 'local_cafe'),
  ('alcohol', 'wine_bar'), ('alkohol', 'wine_bar'), ('wine', 'wine_bar'),
  ('wein', 'wine_bar'), ('beer', 'local_bar'), ('bier', 'local_bar'),
  ('buzz', 'nightlife'), ('drunk', 'nightlife'), ('taste', 'wine_bar'),
  ('nothing', 'block'), ('none', 'block'), ('kein', 'block'),
  ('fast food', 'fastfood'), ('delivery', 'delivery_dining'),
  ('takeaway', 'delivery_dining'), ('liefer', 'delivery_dining'),
  ('restaurant', 'restaurant'), ('homemade', 'home'),
  ('cook', 'home'), ('koch', 'home'), ('food', 'restaurant'),
  ('essen', 'restaurant'), ('shop', 'shopping_basket'),
  ('einkauf', 'shopping_basket'), ('clean', 'cleaning_services'),
  ('putz', 'cleaning_services'), ('travel', 'flight'),
  ('reise', 'flight'), ('hobb', 'palette'), ('health', 'favorite'),
  ('gesund', 'favorite'), ('weather', 'partly_cloudy_day'),
  ('wetter', 'partly_cloudy_day'), ('school', 'school'),
  ('study', 'school'), ('lern', 'school'), ('pet', 'pets'),
  ('dog', 'pets'), ('hund', 'pets'), ('cat', 'pets'), ('katze', 'pets'),
];

String guessIcon(String name, {String fallback = fallbackIconSlug}) {
  final n = name.toLowerCase();
  for (final (k, slug) in _keywords) {
    if (n.contains(k)) return slug;
  }
  return fallback;
}
