import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/mood.dart';
import '../l10n/app_localizations.dart';

/// The mood scale (DESIGN_SYSTEM §1): emerald → neutral → indigo, never red.
/// Always shown with its face icon — the light tints are below 3:1 on the
/// card, so colour never carries a mood alone.
class MoodStyle {
  const MoodStyle._();

  static const _light = {
    Mood.rad: Color(0xFF1FA85D),
    Mood.good: Color(0xFF84CFA6),
    Mood.meh: Color(0xFF8C857E),
    Mood.bad: Color(0xFFBCA4E5),
    Mood.awful: Color(0xFF8559D0),
  };
  static const _dark = {
    Mood.rad: Color(0xFF37CE78),
    Mood.good: Color(0xFF2E8650),
    Mood.meh: Color(0xFF9A938C),
    Mood.bad: Color(0xFF735E97),
    Mood.awful: Color(0xFFA98CEE),
  };

  static Color color(Mood mood, Brightness b) =>
      (b == Brightness.dark ? _dark : _light)[mood]!;

  /// Ink on a mood disc: white on light, near-black on dark.
  static Color onColor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF14100D) : Colors.white;

  /// The neutral used for a pending default (DESIGN_SYSTEM §2.2).
  static Color neutral(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF9A938C) : const Color(0xFF8C857E);

  static IconData icon(Mood mood) => switch (mood) {
    Mood.rad => Symbols.sentiment_very_satisfied_rounded,
    Mood.good => Symbols.sentiment_satisfied_rounded,
    Mood.meh => Symbols.sentiment_neutral_rounded,
    Mood.bad => Symbols.sentiment_dissatisfied_rounded,
    Mood.awful => Symbols.sentiment_very_dissatisfied_rounded,
  };

  /// User renames (design-concept §2.1), set by the app root from the
  /// `mood_labels` table; empty = the localised defaults.
  static Map<Mood, String> overrides = const {};

  static String label(Mood mood, AppLocalizations l10n) =>
      overrides[mood] ?? defaultLabel(mood, l10n);

  static String defaultLabel(Mood mood, AppLocalizations l10n) =>
      switch (mood) {
        Mood.rad => l10n.moodRad,
        Mood.good => l10n.moodGood,
        Mood.meh => l10n.moodMeh,
        Mood.bad => l10n.moodBad,
        Mood.awful => l10n.moodAwful,
      };
}

/// A mood as a coloured disc with its face — the only way a mood is drawn.
class MoodFace extends StatelessWidget {
  const MoodFace(this.mood, {super.key, this.size = 34});

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    return Semantics(
      label: MoodStyle.label(mood, AppLocalizations.of(context)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: MoodStyle.color(mood, b),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          MoodStyle.icon(mood),
          size: size * 0.72,
          weight: 500,
          color: MoodStyle.onColor(b),
        ),
      ),
    );
  }
}
