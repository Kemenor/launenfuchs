import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart' show FuchsbauFont;

import 'data/backup/backup_service.dart';
import 'data/db/database.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/journal_repository.dart';
import 'domain/clock.dart';
import 'domain/day.dart';
import 'domain/journal.dart';
import 'notifications/reminder_scheduler.dart';

/// The injected clock — overridden with a [FixedClock] in tests.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// The on-device database. Overridden with an in-memory database in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => ReminderScheduler(),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(ref.watch(databaseProvider)),
);

/// The whole journal, re-emitted after every write.
final journalProvider = StreamProvider<Journal>(
  (ref) => ref.watch(journalRepositoryProvider).watchJournal(),
);

/// The day a new entry made now belongs to (the late-night cut-off, §2.2).
/// Computed on every call, never cached — an app left open past the cut-off
/// must roll over to the new day.
Day logicalToday(WidgetRef ref) => logicalDay(
  ref.read(clockProvider).now(),
  cutoffHour: ref.watch(settingsProvider).dayCutoffHour,
);

// --- settings ----------------------------------------------------------------

/// User settings: theme, typeface (the Fuchsbau accessibility picker),
/// language, and the hour a new day starts.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.font = FuchsbauFont.figtree,
    this.localeCode = 'system',
    this.dayCutoffHour = defaultDayCutoffHour,
    this.statsTiles,
    this.reminderOn = false,
    this.reminderMinutes = 20 * 60,
    this.appLock = false,
    this.appLockDelaySeconds = 0,
    this.loaded = false,
  });

  final ThemeMode themeMode;
  final FuchsbauFont font;

  /// App-language override ('system' = follow the OS locale).
  final String localeCode;

  /// Entries made before this hour count for the day before (§2.2).
  final int dayCutoffHour;

  /// Stats tiles in display order with their switch; null = the default
  /// layout. Unknown ids are dropped, new tiles appended (see tile_catalog).
  final List<(String, bool)>? statsTiles;

  /// The daily reminder (§2.8) and its time, in minutes after midnight.
  final bool reminderOn;
  final int reminderMinutes;

  /// App lock (§2.6) and how long the app may be away before it re-locks.
  final bool appLock;
  final int appLockDelaySeconds;

  /// The stored row has been read — the app lock waits for this so the
  /// journal never flashes before the lock on a cold start.
  final bool loaded;

  /// What MaterialApp.locale wants: null = system.
  Locale? get locale => localeCode == 'system' ? null : Locale(localeCode);

  Settings copyWith({
    ThemeMode? themeMode,
    FuchsbauFont? font,
    String? localeCode,
    int? dayCutoffHour,
    List<(String, bool)>? statsTiles,
    bool? reminderOn,
    int? reminderMinutes,
    bool? appLock,
    int? appLockDelaySeconds,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    font: font ?? this.font,
    localeCode: localeCode ?? this.localeCode,
    dayCutoffHour: dayCutoffHour ?? this.dayCutoffHour,
    statsTiles: statsTiles ?? this.statsTiles,
    reminderOn: reminderOn ?? this.reminderOn,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    appLock: appLock ?? this.appLock,
    appLockDelaySeconds: appLockDelaySeconds ?? this.appLockDelaySeconds,
    loaded: loaded,
  );
}

/// Loads the singleton settings row once (no drift *watch* → no widget-test
/// timer), holds it, and persists changes.
class SettingsController extends Notifier<Settings> {
  /// Set on the first user change; a still-in-flight [_load] must not clobber
  /// a fresher choice with the stale stored row.
  bool _touched = false;

  @override
  Settings build() {
    _touched = false;
    _load();
    return const Settings();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final row = await db.select(db.appSettings).getSingleOrNull();
    if (_touched) return;
    if (row == null) {
      state = const Settings(loaded: true);
      return;
    }
    {
      state = Settings(
        loaded: true,
        themeMode: ThemeMode.values[row.themeModeIndex.clamp(0, 2)],
        font: FuchsbauFont
            .values[row.fontIndex.clamp(0, FuchsbauFont.values.length - 1)],
        localeCode: row.localeCode,
        dayCutoffHour: row.dayCutoffHour.clamp(0, 23),
        statsTiles: _decodeTiles(row.statsTiles),
        reminderOn: row.reminderOn,
        reminderMinutes: row.reminderMinutes.clamp(0, 24 * 60 - 1),
        appLock: row.appLock,
        appLockDelaySeconds: row.appLockDelaySeconds,
      );
    }
  }

  static List<(String, bool)>? _decodeTiles(String? json) {
    if (json == null) return null;
    try {
      return [
        for (final e in jsonDecode(json) as List)
          ((e as Map)['id'] as String, e['on'] as bool),
      ];
    } catch (_) {
      return null;
    }
  }

  Future<void> setStatsTiles(List<(String, bool)> tiles) =>
      _update(state.copyWith(statsTiles: List.unmodifiable(tiles)));

  Future<void> setReminder({bool? on, int? minutes}) =>
      _update(state.copyWith(reminderOn: on, reminderMinutes: minutes));

  Future<void> setAppLock({bool? on, int? delaySeconds}) =>
      _update(state.copyWith(appLock: on, appLockDelaySeconds: delaySeconds));

  Future<void> setThemeMode(ThemeMode mode) =>
      _update(state.copyWith(themeMode: mode));

  Future<void> setFont(FuchsbauFont font) =>
      _update(state.copyWith(font: font));

  Future<void> setLocaleCode(String code) =>
      _update(state.copyWith(localeCode: code));

  Future<void> setDayCutoffHour(int hour) =>
      _update(state.copyWith(dayCutoffHour: hour));

  Future<void> _update(Settings next) async {
    _touched = true;
    state = next;
    final db = ref.read(databaseProvider);
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion(
            id: const Value(1),
            themeModeIndex: Value(state.themeMode.index),
            fontIndex: Value(state.font.index),
            localeCode: Value(state.localeCode),
            dayCutoffHour: Value(state.dayCutoffHour),
            reminderOn: Value(state.reminderOn),
            reminderMinutes: Value(state.reminderMinutes),
            appLock: Value(state.appLock),
            appLockDelaySeconds: Value(state.appLockDelaySeconds),
            statsTiles: Value(
              state.statsTiles == null
                  ? null
                  : jsonEncode([
                      for (final (id, on) in state.statsTiles!)
                        {'id': id, 'on': on},
                    ]),
            ),
          ),
        );
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);
