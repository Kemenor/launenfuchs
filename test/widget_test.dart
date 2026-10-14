import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
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
    expect(find.text('Typeface'), findsOneWidget);
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

  testWidgets('a settings change is persisted (24 h labels in German)', (
    tester,
  ) async {
    final db = await pumpApp(tester, locale: const Locale('de'));

    await tester.tap(find.text('Einstellungen').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neuer Tag beginnt um'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('02:00'));
    await tester.pumpAndSettle();

    final row = await db.select(db.appSettings).getSingle();
    expect(row.dayCutoffHour, 2);
  });
}
