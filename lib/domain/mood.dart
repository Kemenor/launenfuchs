/// The fixed five-step mood scale (design-concept §2.1). Stored as [value]
/// `1…5`, **5 = best** — Daylio stores it the other way round; the import
/// flips it.
enum Mood {
  awful(1),
  bad(2),
  meh(3),
  good(4),
  rad(5);

  const Mood(this.value);

  final int value;

  static Mood fromValue(int value) =>
      Mood.values.firstWhere((m) => m.value == value);
}
