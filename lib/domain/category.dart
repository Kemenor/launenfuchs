/// How a category is picked on a day (design-concept §2.3).
enum CategoryMode {
  /// Choosing an option replaces the previous one (Work, Sleep, Coffee).
  one,

  /// Independent toggles (Health: walk, gym).
  any,
}

/// How a *one per day* category is shown on the entry sheet. Pure
/// presentation — the stored option is the same either way.
enum CategoryDisplay { chips, slider }
