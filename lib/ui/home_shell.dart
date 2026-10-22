import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/journal.dart';
import '../domain/mood.dart';
import '../domain/reminder.dart';
import '../domain/starter.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'entry_sheet.dart';
import 'journal_screen.dart';
import 'mood_style.dart';
import 'settings_screen.dart';
import 'stats/stats_screen.dart';

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
  StreamSubscription<Mood?>? _taps;
  Timer? _syncDebounce;

  @override
  void initState() {
    super.initState();
    final scheduler = ref.read(reminderSchedulerProvider);
    // A tapped reminder opens today's entry on the Journal tab — with the
    // mood picked when a face was tapped.
    _taps = scheduler.taps.listen((mood) {
      if (!mounted) return;
      setState(() => _index = 0);
      showEntrySheet(context, day: logicalToday(ref), initialMood: mood);
    });
    scheduler.init();
  }

  @override
  void dispose() {
    _taps?.cancel();
    _syncDebounce?.cancel();
    super.dispose();
  }

  /// Re-fills the reminder schedule (§2.8) after any journal or settings
  /// change — logging today drops today's reminder.
  void _scheduleSync() {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final s = ref.read(settingsProvider);
      if (!s.loaded) return;
      final l10n = AppLocalizations.of(context);
      final journal = ref.read(journalProvider).value ?? Journal.empty;
      final logged = {for (final e in journal.entries) e.day};
      final times = s.reminderOn
          ? reminderTimes(
              now: ref.read(clockProvider).now(),
              minutes: s.reminderMinutes,
              logged: logged,
            )
          : const <DateTime>[];
      ref
          .read(reminderSchedulerProvider)
          .sync(
            times,
            title: l10n.notifTitle,
            body: l10n.notifBody,
            channelName: l10n.notifChannel,
            channelDescription: l10n.notifChannelDescription,
            moods: [for (final m in Mood.values) MoodStyle.label(m, l10n)],
            todayLogged: logged.contains(logicalToday(ref)),
          );
    });
  }

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
    ref.listen(journalProvider, (_, _) => _scheduleSync());
    ref.listen(settingsProvider, (_, _) => _scheduleSync());
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
