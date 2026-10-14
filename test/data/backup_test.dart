import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/backup/backup_service.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/data/import/daylio.dart';
import 'package:launenfuchs/data/import/import_writer.dart';
import 'package:launenfuchs/data/repositories/journal_repository.dart';
import 'package:launenfuchs/domain/daylio_plan.dart';
import 'package:launenfuchs/domain/day.dart';

import '../support/daylio_fixture.dart';

void main() {
  final now = DateTime(2026, 10, 14, 21);

  Future<AppDatabase> filled() async {
    final db = AppDatabase(NativeDatabase.memory());
    final a = DaylioAnalysis.of(
      parseDaylioBackup(daylioFile(sampleDaylioJson())),
    );
    final m = a.suggestedMapping();
    m.tags[77]!.action = MapAction.keep;
    m.defaultsFor(7).defaultTagId = 77;
    await writeImport(
      db,
      planImport(a, m),
      now: now,
      lastDay: const Day(2026, 9, 11),
    );
    await db
        .into(db.periods)
        .insert(
          PeriodsCompanion.insert(name: 'Holiday', startDay: '2026-09-09'),
        );
    return db;
  }

  test(
    'a backup round-trips identically (defaults and ids included)',
    () async {
      final src = await filled();
      addTearDown(src.close);
      final zip = await buildBackupZipBytes(
        src,
        now: now,
        appVersion: '0.1.0+1',
      );

      final archive = ZipDecoder().decodeBytes(zip);
      expect(archive.files.map((f) => f.name).toSet(), {
        backupManifestEntry,
        backupSqliteEntry,
        backupJsonEntry,
      });
      final manifest = jsonDecode(
        utf8.decode(
          archive.findFile(backupManifestEntry)!.content as List<int>,
        ),
      );
      expect(manifest['app'], 'launenfuchs');

      final dst = AppDatabase(NativeDatabase.memory());
      addTearDown(dst.close);
      await restoreBackupZipBytes(dst, zip);

      final a = await JournalRepository(src).loadJournal();
      final b = await JournalRepository(dst).loadJournal();
      expect(b.entries.length, a.entries.length);
      expect(b.periods.single.name, 'Holiday');
      expect(
        b.categories.first.defaultOption?.name,
        a.categories.first.defaultOption?.name,
      );
      for (final e in a.entries) {
        expect(b.entryOn(e.day)!.optionIds, e.optionIds);
        expect(b.entryOn(e.day)!.note, e.note);
      }
      expect(
        (await loadSavedMapping(dst)).tags.length,
        (await loadSavedMapping(src)).tags.length,
      );
    },
  );

  test('a restore replaces what was there', () async {
    final src = await filled();
    addTearDown(src.close);
    final zip = await buildBackupZipBytes(src, now: now);
    final dst = await filled();
    addTearDown(dst.close);
    await dst
        .into(dst.periods)
        .insert(PeriodsCompanion.insert(name: 'Extra', startDay: '2026-10-01'));
    await restoreBackupZipBytes(dst, zip);
    expect((await dst.select(dst.periods).get()).map((p) => p.name), [
      'Holiday',
    ]);
  });

  test(
    'foreign and newer backups are refused before anything changes',
    () async {
      final db = await filled();
      addTearDown(db.close);
      expect(
        () => restoreBackupZipBytes(db, [1, 2, 3]),
        throwsA(isA<NotOurBackupException>()),
      );
      expect(
        () => restoreBackupZipBytes(db, daylioFile(sampleDaylioJson())),
        throwsA(isA<NotOurBackupException>()),
      );
      expect(
        () => checkBackupManifest({
          'app': 'launenfuchs',
          'schemaVersion': 99,
        }, appSchemaVersion: 1),
        throwsA(isA<BackupVersionException>()),
      );
      expect((await JournalRepository(db).loadJournal()).entries, hasLength(4));
    },
  );
}
