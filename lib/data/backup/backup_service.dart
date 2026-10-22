import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../db/database.dart';
import '../../system_prompt.dart';

/// Backup & restore — the Fuchsbau pattern (ETHOS "Backup & device moves"),
/// adapted from checkfuchs. The ZIP holds:
///  * `launenfuchs.sqlite` — a `VACUUM INTO` snapshot (consistent while the
///    database is open); the restore source, migrated forward on open;
///  * `backup.json` — every table, human-readable (no lock-in);
///  * `manifest.json` — app id, app version, schema version, timestamp.
const backupAppId = 'launenfuchs';
const backupManifestEntry = 'manifest.json';
const backupSqliteEntry = 'launenfuchs.sqlite';
const backupJsonEntry = 'backup.json';

/// A backup from a newer app version than this build can read.
class BackupVersionException extends FormatException {
  BackupVersionException(int version, int supported)
    : super('Backup schema $version is newer than supported ($supported).');
}

/// Not a launenfuchs backup at all.
class NotOurBackupException extends FormatException {
  const NotOurBackupException(super.message);
}

Future<Uint8List> buildBackupZipBytes(
  AppDatabase db, {
  required DateTime now,
  String appVersion = 'unknown',
}) async {
  final Uint8List sqliteBytes;
  final tmp = await Directory.systemTemp.createTemp('launenfuchs-backup-');
  try {
    final snapshot = File('${tmp.path}/$backupSqliteEntry');
    await db.customStatement('VACUUM INTO ?', [snapshot.path]);
    sqliteBytes = await snapshot.readAsBytes();
  } finally {
    await tmp.delete(recursive: true);
  }

  final tables = <String, List<Map<String, Object?>>>{};
  for (final table in db.allTables) {
    final name = table.actualTableName;
    final rows = await db.customSelect('SELECT * FROM "$name"').get();
    tables[name] = [for (final r in rows) r.data];
  }
  final jsonBytes = utf8.encode(
    const JsonEncoder.withIndent('  ').convert({
      'app': backupAppId,
      'schemaVersion': db.schemaVersion,
      'exportedAt': now.toIso8601String(),
      'tables': tables,
    }),
  );
  final manifestBytes = utf8.encode(
    jsonEncode({
      'app': backupAppId,
      'appVersion': appVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': now.toIso8601String(),
    }),
  );
  final archive = Archive()
    ..addFile(
      ArchiveFile(backupManifestEntry, manifestBytes.length, manifestBytes),
    )
    ..addFile(ArchiveFile(backupSqliteEntry, sqliteBytes.length, sqliteBytes))
    ..addFile(ArchiveFile(backupJsonEntry, jsonBytes.length, jsonBytes));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

void checkBackupManifest(
  Map<String, dynamic> manifest, {
  required int appSchemaVersion,
}) {
  if (manifest['app'] != backupAppId) {
    throw const NotOurBackupException('Not a launenfuchs backup.');
  }
  final version = (manifest['schemaVersion'] as num?)?.toInt();
  if (version == null) {
    throw const NotOurBackupException('Backup manifest has no schema version.');
  }
  if (version > appSchemaVersion) {
    throw BackupVersionException(version, appSchemaVersion);
  }
}

/// Replaces everything in [db] with a backup's contents, in one transaction
/// (validate first; the live file is never swapped; a failure rolls back).
Future<void> restoreBackupZipBytes(AppDatabase db, List<int> zipBytes) async {
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(zipBytes);
  } catch (_) {
    throw const NotOurBackupException('Not a zip file.');
  }
  final manifestFile = archive.findFile(backupManifestEntry);
  if (manifestFile == null) {
    throw const NotOurBackupException('No manifest.json.');
  }
  final manifest = jsonDecode(utf8.decode(manifestFile.content as List<int>));
  if (manifest is! Map<String, dynamic>) {
    throw const NotOurBackupException('Manifest is not an object.');
  }
  checkBackupManifest(manifest, appSchemaVersion: db.schemaVersion);
  final entry = archive.findFile(backupSqliteEntry);
  if (entry == null) {
    throw const NotOurBackupException('No database in the backup.');
  }

  final tmp = await Directory.systemTemp.createTemp('launenfuchs-restore-');
  try {
    final file = File('${tmp.path}/$backupSqliteEntry');
    await file.writeAsBytes(entry.content as List<int>, flush: true);
    final src = AppDatabase(NativeDatabase(file));
    final List<MoodLabelRow> moodLabels;
    final List<CategoryRow> categories;
    final List<CategorySpanRow> spans;
    final List<OptionRow> options;
    final List<EntryRow> entries;
    final List<EntryOptionRow> links;
    final List<PeriodRow> periods;
    final List<ImportMapRow> maps;
    final List<AppSettingsRow> settings;
    try {
      moodLabels = await src.select(src.moodLabels).get();
      categories = await src.select(src.categories).get();
      spans = await src.select(src.categorySpans).get();
      options = await src.select(src.categoryOptions).get();
      entries = await src.select(src.entries).get();
      links = await src.select(src.entryOptions).get();
      periods = await src.select(src.periods).get();
      maps = await src.select(src.importMaps).get();
      settings = await src.select(src.appSettings).get();
    } finally {
      await src.close();
    }

    await db.transaction(() async {
      // Children before parents (foreign keys are on).
      await db.delete(db.entryOptions).go();
      await db.delete(db.entries).go();
      await db
          .update(db.categories)
          .write(const CategoriesCompanion(defaultOptionId: Value(null)));
      await db.delete(db.categoryOptions).go();
      await db.delete(db.categorySpans).go();
      await db.delete(db.categories).go();
      await db.delete(db.periods).go();
      await db.delete(db.importMaps).go();
      await db.delete(db.moodLabels).go();
      await db.delete(db.appSettings).go();
      // Parents before children, original ids kept. Categories go in without
      // their default first (it points at an option not yet inserted).
      await db.batch((b) {
        b.insertAll(db.moodLabels, [for (final r in moodLabels) r]);
        b.insertAll(db.categories, [
          for (final r in categories)
            r.copyWith(defaultOptionId: const Value(null)),
        ]);
        b.insertAll(db.categorySpans, [for (final r in spans) r]);
        b.insertAll(db.categoryOptions, [for (final r in options) r]);
        b.insertAll(db.entries, [for (final r in entries) r]);
        b.insertAll(db.entryOptions, [for (final r in links) r]);
        b.insertAll(db.periods, [for (final r in periods) r]);
        b.insertAll(db.importMaps, [for (final r in maps) r]);
        b.insertAll(db.appSettings, [for (final r in settings) r]);
      });
      for (final c in categories) {
        if (c.defaultOptionId != null) {
          await (db.update(
            db.categories,
          )..where((t) => t.id.equals(c.id))).write(
            CategoriesCompanion(defaultOptionId: Value(c.defaultOptionId)),
          );
        }
      }
    });
  } finally {
    await tmp.delete(recursive: true);
  }
}

/// The platform shell: the system SAVE dialog out (a path, not bytes — MIUI
/// wrote 0-byte files from bytes), [restoreFromPath] in.
class BackupService {
  BackupService(this.db);
  final AppDatabase db;

  /// Returns the saved size in bytes, or null when the dialog was cancelled.
  Future<int?> saveBackup() async {
    final now = DateTime.now();
    var appVersion = 'unknown';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    final bytes = await buildBackupZipBytes(
      db,
      now: now,
      appVersion: appVersion,
    );
    final stamp = DateFormat('yyyyMMdd-HHmmss').format(now);
    final name = 'launenfuchs-backup-$stamp.zip';
    final file = File('${Directory.systemTemp.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    try {
      final saved = await systemPrompt(
        () => FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(
            sourceFilePath: file.path,
            fileName: name,
            mimeTypesFilter: const ['application/zip'],
          ),
        ),
      );
      return saved != null ? bytes.length : null;
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  Future<void> restoreFromPath(String path) async =>
      restoreBackupZipBytes(db, await File(path).readAsBytes());
}

/// Picks a document with flutter_file_dialog (streams to EOF; no mime filter
/// — the content check is the validator). Null when cancelled.
Future<String?> pickDocument() => systemPrompt(
  () => FlutterFileDialog.pickFile(
    params: const OpenFileDialogParams(dialogType: OpenFileDialogType.document),
  ),
);
