import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'domain/mood.dart';
import 'providers.dart';
import 'ui/app_lock.dart';
import 'ui/home_shell.dart';
import 'ui/mood_style.dart';

void main() {
  runApp(const ProviderScope(child: LaunenfuchsApp()));
}

class LaunenfuchsApp extends ConsumerWidget {
  const LaunenfuchsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    // Renamed moods apply everywhere — entry sheet, charts, reports.
    MoodStyle.overrides = {
      for (final MapEntry(key: v, value: label)
          in (ref.watch(journalProvider).value?.moodLabels ??
                  const <int, String>{})
              .entries)
        Mood.fromValue(v): label,
    };
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: LaunenfuchsTheme.light(font: settings.font),
      darkTheme: LaunenfuchsTheme.dark(font: settings.font),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppLockGate(child: child!),
      home: const HomeShell(),
    );
  }
}
