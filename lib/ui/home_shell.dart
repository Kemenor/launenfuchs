import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../l10n/app_localizations.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// The top level: a bottom [NavigationBar] — Journal · Stats · Settings
/// (router-less, Fuchsbau TECH_STACK). [IndexedStack] keeps each tab's state.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [JournalScreen(), StatsScreen(), SettingsScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Symbols.calendar_month_rounded),
            selectedIcon: const Icon(Symbols.calendar_month_rounded, fill: 1),
            label: l10n.navJournal,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.insights_rounded),
            selectedIcon: const Icon(Symbols.insights_rounded, fill: 1),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Symbols.settings_rounded),
            selectedIcon: const Icon(Symbols.settings_rounded, fill: 1),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
