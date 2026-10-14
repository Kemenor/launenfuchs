import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';

/// Settings (DESIGN_SYSTEM §2.4), in the shared Fuchsbau anatomy: uppercase
/// section headers over cards. Phase 0: the day cut-off and appearance.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// The hours offered for "New day starts at" — midnight to early morning.
  static const cutoffHours = [0, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final material = MaterialLocalizations.of(context);
    final use24h = MediaQuery.alwaysUse24HourFormatOf(context);
    String hourLabel(int h) => material.formatTimeOfDay(
      TimeOfDay(hour: h, minute: 0),
      alwaysUse24HourFormat: use24h,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          FuchsbauSectionHeader(l10n.sectionJournal),
          FuchsbauSettingsCard(
            children: [
              FuchsbauChoicePicker<int>(
                icon: Symbols.bedtime_rounded,
                title: l10n.dayCutoffTitle,
                value: settings.dayCutoffHour,
                options: {for (final h in cutoffHours) h: hourLabel(h)},
                footnote: l10n.dayCutoffFootnote,
                onChanged: controller.setDayCutoffHour,
              ),
            ],
          ),
          FuchsbauSectionHeader(l10n.sectionAppearance),
          FuchsbauSettingsCard(
            children: [
              FuchsbauChoicePicker<ThemeMode>(
                icon: Symbols.brightness_6_rounded,
                title: l10n.themePickerTitle,
                value: settings.themeMode,
                options: {
                  ThemeMode.system: l10n.themeSystem,
                  ThemeMode.light: l10n.themeLight,
                  ThemeMode.dark: l10n.themeDark,
                },
                onChanged: controller.setThemeMode,
              ),
              FuchsbauChoicePicker<String>(
                icon: Symbols.translate_rounded,
                title: l10n.languageTitle,
                value: settings.localeCode,
                options: {
                  'system': l10n.languageSystem,
                  'en': l10n.languageEnglish,
                  'de': l10n.languageGerman,
                  'fr': l10n.languageFrench,
                  'it': l10n.languageItalian,
                },
                onChanged: controller.setLocaleCode,
              ),
              FuchsbauChoicePicker<FuchsbauFont>(
                icon: Symbols.text_fields_rounded,
                title: l10n.typefaceTitle,
                value: settings.font,
                options: {for (final f in FuchsbauFont.values) f: f.label},
                subtitles: {
                  FuchsbauFont.figtree: l10n.typefaceDefault,
                  FuchsbauFont.atkinsonHyperlegible: l10n.typefaceLowVision,
                  FuchsbauFont.openDyslexic: l10n.typefaceDyslexia,
                },
                onChanged: controller.setFont,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
