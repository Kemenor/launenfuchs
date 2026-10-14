/// The injected clock. The domain reads "now" through this — which day a new
/// entry belongs to depends on it (the late-night cut-off) — so tests stay
/// deterministic. Production uses [SystemClock]; tests use [FixedClock].
abstract interface class Clock {
  DateTime now();
}

/// Real wall-clock time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A controllable clock for tests.
class FixedClock implements Clock {
  FixedClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void set(DateTime value) => _now = value;
  void advance(Duration by) => _now = _now.add(by);
}
