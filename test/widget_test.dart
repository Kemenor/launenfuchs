import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/domain/day.dart';
import 'package:launenfuchs/domain/clock.dart';
import 'package:launenfuchs/main.dart';
import 'package:launenfuchs/providers.dart';

void main() {
  Future<AppDatabase> pumpApp(WidgetTester tester, {Locale? locale}) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    if (locale != null) {
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          clockProvider.overrideWithValue(
            FixedClock(DateTime(2026, 10, 14, 21)),
          ),
        ],
        child: const LaunenfuchsApp(),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  testWidgets('boots to the empty Journal', (tester) async {
    await pumpApp(tester);
    expect(find.text('How was today?'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Log today'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('the bottom bar reaches Stats and Settings', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(
      find.text('Stats appear once you have logged a few days.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('New day starts at'), findsOneWidget);
    expect(find.text('Categories & options'), findsOneWidget);
  });

  for (final (code, title) in [
    ('de', 'Wie war heute?'),
    ('fr', "Comment s'est passée la journée ?"),
    ('it', "Com'è andata oggi?"),
  ]) {
    testWidgets('speaks $code', (tester) async {
      await pumpApp(tester, locale: Locale(code));
      expect(find.text(title), findsOneWidget);
    });
  }

  testWidgets('first run: seeds the starter set and logs a day', (
    tester,
  ) async {
    final db = await pumpApp(tester);

    // Tap "good" on the first-run card → today's sheet with good picked.
    await tester.tap(find.text('good').first);
    await tester.pumpAndSettle();
    expect(find.text('Today · Wed, Oct 14'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget, reason: 'starter set seeded');
    expect(find.text('DEFAULT'), findsOneWidget, reason: 'Day off pending');

    await tester.tap(find.text('Walk'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final entries = await db.select(db.entries).get();
    expect(entries, hasLength(1));
    expect(entries.single.day, const Day(2026, 10, 14).key);
    expect(entries.single.mood, 4);
    // Walk + the saved default (Day off).
    expect(await db.select(db.entryOptions).get(), hasLength(2));
    expect(find.text('Edit today'), findsOneWidget);
    expect(find.text('How was today?'), findsNothing);
  });

  testWidgets('a settings change is persisted (24 h labels in German)', (
    tester,
  ) async {
    final db = await pumpApp(tester, locale: const Locale('de'));

    await tester.tap(find.text('Einstellungen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neuer Tag beginnt um'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('02:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('02:00'));
    await tester.pumpAndSettle();

    final row = await db.select(db.appSettings).getSingle();
    expect(row.dayCutoffHour, 2);
  });
}
