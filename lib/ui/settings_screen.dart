import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../data/backup/backup_service.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'import_screen.dart';

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
          FuchsbauSectionHeader(l10n.sectionData),
          FuchsbauSettingsCard(
            children: [
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.upload_file_rounded),
                title: Text(l10n.importTitle),
                subtitle: Text(l10n.importDaylioSubtitle),
                trailing: const Icon(Symbols.chevron_right_rounded),
                onTap: () => ImportScreen.open(context),
              ),
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.save_rounded),
                title: Text(l10n.backupSave),
                subtitle: Text(l10n.backupSaveSubtitle),
                onTap: () => _saveBackup(context, ref),
              ),
              ListTile(
                contentPadding: fuchsbauCardRowPadding,
                leading: const Icon(Symbols.settings_backup_restore_rounded),
                title: Text(l10n.backupRestore),
                onTap: () => _restoreBackup(context, ref),
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

/// Export: the ZIP through the system save dialog; confirmed with its size
/// (stale file-manager indexes show fresh files as 0 bytes — the snackbar is
/// the trustworthy receipt).
Future<void> _saveBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  try {
    final bytes = await ref.read(backupServiceProvider).saveBackup();
    if (bytes != null) {
      final size = bytes >= 1024 * 1024
          ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
          : '${(bytes / 1024).ceil()} KB';
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupSaved(size))));
    }
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.backupExportFailed('$e'))),
    );
  }
}

/// Import: pick, confirm the replace-everything consequence, restore live.
Future<void> _restoreBackup(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context);
  final String? path;
  try {
    path = await pickDocument();
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.backupRestoreFailed('$e'))),
    );
    return;
  }
  if (path == null || !context.mounted) return;
  final scheme = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l10n.backupReplaceTitle),
      content: Text(l10n.backupReplaceBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.pop(c, true),
          child: Text(l10n.backupRestoreAction),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(backupServiceProvider).restoreFromPath(path);
    // Theme, font, language and cut-off live in the restored database.
    ref.invalidate(settingsProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
  } on BackupVersionException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupNewer)));
  } on NotOurBackupException {
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupNotOurs)));
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.backupRestoreFailed('$e'))),
    );
  }
}
