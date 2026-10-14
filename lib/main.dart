import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'ui/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: LaunenfuchsApp()));
}

class LaunenfuchsApp extends ConsumerWidget {
  const LaunenfuchsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: LaunenfuchsTheme.light(font: settings.font),
      darkTheme: LaunenfuchsTheme.dark(font: settings.font),
      themeMode: settings.themeMode,
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeShell(),
    );
  }
}
