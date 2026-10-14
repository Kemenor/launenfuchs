import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/category.dart';

part 'database.g.dart';

// Days are ISO `yyyy-mm-dd` TEXT (a calendar date, not an instant — see
// domain/day.dart). Instants (`createdAt`, `loggedAt`) are drift DateTimes.

/// A label/icon override per mood value (design-concept §2.1). No row (or a
/// null column) = the localised default; the value itself never changes.
@DataClassName('MoodLabelRow')
class MoodLabels extends Table {
  // drift's check() refers to the column itself — not a real recursion.
  // ignore: recursive_getters
  IntColumn get value => integer().check(value.isBetweenValues(1, 5))();
  TextColumn get label => text().nullable()();
  TextColumn get icon => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {value};
}

/// Something you track (design-concept §2.3).
@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  TextColumn get mode => textEnum<CategoryMode>()();
  TextColumn get display => textEnum<CategoryDisplay>().withDefault(
    Constant(CategoryDisplay.chips.name),
  )();

  /// Pre-selected on **new** entries only. Never read by stats — a saved
  /// default is an ordinary `entry_options` row (CLAUDE.md "saved means saved").
  IntColumn get defaultOptionId => integer().nullable().references(
    CategoryOptions,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get sort => integer().withDefault(const Constant(0))();

  /// Hidden from the entry sheet; data kept (§2.3 "Hide").
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// The date ranges in which a category counts (§2.3 tracking spans). Days
/// outside every span are *not tracked*. Hide closes the open span; bringing
/// the category back opens a new one.
@DataClassName('CategorySpanRow')
class CategorySpans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get fromDay => text()();
  TextColumn get toDay => text().nullable()();
}

/// A value a category can take (§2.4). (Not `Options`: that name would
/// shadow drift's `GeneratedDatabase.options`.)
@DataClassName('OptionRow')
class CategoryOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get sort => integer().withDefault(const Constant(0))();
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
}

/// One rated day (§2.2). `day` is unique: one entry per calendar day.
@DataClassName('EntryRow')
class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get day => text().unique()();

  /// When it was logged — display only; the day is what counts.
  DateTimeColumn get loggedAt => dateTime()();
  // ignore: recursive_getters
  IntColumn get mood => integer().check(mood.isBetweenValues(1, 5))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Entry ⇄ option. "Delete for good" is the option's cascade.
@DataClassName('EntryOptionRow')
class EntryOptions extends Table {
  IntColumn get entryId =>
      integer().references(Entries, #id, onDelete: KeyAction.cascade)();
  IntColumn get optionId =>
      integer().references(CategoryOptions, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entryId, optionId};
}

/// A named, inclusive date range (§2.5). Never changes entries; slices stats.
@DataClassName('PeriodRow')
class Periods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get startDay => text()();

  /// Null = ongoing.
  TextColumn get endDay => text().nullable()();

  /// Shaded on charts and the calendar, like a holiday.
  BoolColumn get away => boolean().withDefault(const Constant(false))();
  TextColumn get icon => text().nullable()();
}

/// The saved Daylio mapping (§7.3): a repeat import reuses it and only asks
/// about groups/tags it has not seen.
@DataClassName('ImportMapRow')
class ImportMaps extends Table {
  TextColumn get source => text()(); // 'daylio'
  TextColumn get kind => text()(); // 'group' | 'tag'
  IntColumn get sourceId => integer()();
  TextColumn get action => text()(); // 'keep' | 'merge' | 'drop'
  IntColumn get targetId => integer().nullable()();

  /// The rest of the choice as JSON (name, icon, mode, display).
  TextColumn get choice => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {source, kind, sourceId};
}

/// Singleton app settings (the checkfuchs pattern). Enums are stored as plain
/// indices so the schema doesn't couple to them.
@DataClassName('AppSettingsRow')
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get themeModeIndex => integer().withDefault(const Constant(0))();
  IntColumn get fontIndex => integer().withDefault(const Constant(0))();

  /// App-language override ('system' = follow the OS locale).
  TextColumn get localeCode => text().withDefault(const Constant('system'))();

  /// The hour a new day starts (§2.2), default 04:00.
  IntColumn get dayCutoffHour => integer().withDefault(const Constant(4))();

  /// Enabled Stats tiles in display order, JSON list. Null = the default set.
  TextColumn get statsTiles => text().nullable()();

  /// First run handled (starter set seeded or an import done) — never re-seed,
  /// even if every category is later deleted.
  BoolColumn get onboardingDone =>
      boolean().withDefault(const Constant(false))();

  /// The daily reminder (§2.8): off by default; minutes after midnight.
  BoolColumn get reminderOn => boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutes =>
      integer().withDefault(const Constant(20 * 60))();

  /// App lock (§2.6): off by default; delay before re-locking, in seconds.
  BoolColumn get appLock => boolean().withDefault(const Constant(false))();
  IntColumn get appLockDelaySeconds =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    MoodLabels,
    Categories,
    CategorySpans,
    CategoryOptions,
    Entries,
    EntryOptions,
    Periods,
    ImportMaps,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// The on-device database for the running app.
  AppDatabase.open() : super(driftDatabase(name: 'launenfuchs'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // SQLite ships with foreign keys off; the cascades (delete for good) and
    // set-null (a removed default option) depend on them.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
