import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart' show Locale, ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuchsbau/fuchsbau.dart' show FuchsbauFont;

import 'data/db/database.dart';
import 'domain/clock.dart';
import 'domain/day.dart';

/// The injected clock — overridden with a [FixedClock] in tests.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// The on-device database. Overridden with an in-memory database in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

// --- settings ----------------------------------------------------------------

/// User settings: theme, typeface (the Fuchsbau accessibility picker),
/// language, and the hour a new day starts.
class Settings {
  const Settings({
    this.themeMode = ThemeMode.system,
    this.font = FuchsbauFont.figtree,
    this.localeCode = 'system',
    this.dayCutoffHour = defaultDayCutoffHour,
  });

  final ThemeMode themeMode;
  final FuchsbauFont font;

  /// App-language override ('system' = follow the OS locale).
  final String localeCode;

  /// Entries made before this hour count for the day before (§2.2).
  final int dayCutoffHour;

  /// What MaterialApp.locale wants: null = system.
  Locale? get locale => localeCode == 'system' ? null : Locale(localeCode);

  Settings copyWith({
    ThemeMode? themeMode,
    FuchsbauFont? font,
    String? localeCode,
    int? dayCutoffHour,
  }) => Settings(
    themeMode: themeMode ?? this.themeMode,
    font: font ?? this.font,
    localeCode: localeCode ?? this.localeCode,
    dayCutoffHour: dayCutoffHour ?? this.dayCutoffHour,
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
    if (row != null && !_touched) {
      state = Settings(
        themeMode: ThemeMode.values[row.themeModeIndex.clamp(0, 2)],
        font: FuchsbauFont
            .values[row.fontIndex.clamp(0, FuchsbauFont.values.length - 1)],
        localeCode: row.localeCode,
        dayCutoffHour: row.dayCutoffHour.clamp(0, 23),
      );
    }
  }

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
          ),
        );
  }
}

final settingsProvider = NotifierProvider<SettingsController, Settings>(
  SettingsController.new,
);
