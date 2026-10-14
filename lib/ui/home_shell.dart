import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/starter.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// The top level: a bottom [NavigationBar] — Journal · Stats · Settings
/// (router-less, Fuchsbau TECH_STACK). [IndexedStack] keeps each tab's state.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // First run: the neutral starter set, in the user's language (§2.7).
    if (_seeded) return;
    _seeded = true;
    final l10n = AppLocalizations.of(context);
    ref
        .read(journalRepositoryProvider)
        .seedStarterSetIfNeeded(
          starterSet(starterNamesOf(l10n)),
          logicalToday(ref),
          ref.read(clockProvider).now(),
        );
  }

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

/// The localised starter-set names.
StarterNames starterNamesOf(AppLocalizations l) => StarterNames(
  work: l.starterWork,
  workedNormally: l.starterWorkedNormally,
  workedLess: l.starterWorkedLess,
  dayOff: l.starterDayOff,
  sick: l.starterSick,
  health: l.starterHealth,
  walk: l.starterWalk,
  exercise: l.starterExercise,
  sport: l.starterSport,
  social: l.starterSocial,
  friends: l.starterFriends,
  family: l.starterFamily,
  partner: l.starterPartner,
  timeAlone: l.starterTimeAlone,
  hobbies: l.starterHobbies,
  reading: l.starterReading,
  gaming: l.starterGaming,
  music: l.starterMusic,
  creative: l.starterCreative,
  sleep: l.starterSleep,
  sleepPoor: l.starterSleepPoor,
  sleepOk: l.starterSleepOk,
  sleepGood: l.starterSleepGood,
);
