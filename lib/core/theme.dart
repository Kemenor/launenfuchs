import 'package:flutter/material.dart';
import 'package:fuchsbau/fuchsbau.dart';

/// Launenfuchs theme — delegates to the shared **Fuchsbau** design system (the
/// tangerine triad, Figtree, quiet elevation). App-specific component themes
/// (the mood scale, DESIGN_SYSTEM §1) get layered here as they arrive.
/// The app entry MUST build its themes through here so every caller carries
/// the user's typeface — dropping [font] silently discards the accessibility
/// font picker.
class LaunenfuchsTheme {
  const LaunenfuchsTheme._();

  static ThemeData light({FuchsbauFont font = FuchsbauFont.figtree}) =>
      _themed(fuchsbauTheme(Brightness.light, font: font));
  static ThemeData dark({FuchsbauFont font = FuchsbauFont.figtree}) =>
      _themed(fuchsbauTheme(Brightness.dark, font: font));

  /// The FAB is the primary action and must read as a button: Material's
  /// default `primaryContainer` fill nearly vanishes against this palette's
  /// page colour. Family default is tangerine (fuchsbau DESIGN.md §4), applied
  /// app-level like checkfuchs does.
  static ThemeData _themed(ThemeData base) => base.copyWith(
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
      backgroundColor: base.colorScheme.primary,
      foregroundColor: base.colorScheme.onPrimary,
    ),
  );
}
