import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:launenfuchs/data/db/database.dart';
import 'package:launenfuchs/domain/clock.dart';
import 'package:launenfuchs/main.dart';
import 'package:launenfuchs/providers.dart';
import 'package:launenfuchs/system_prompt.dart';
import 'package:launenfuchs/ui/app_lock.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';

/// The phone's unlock prompt: each call waits until the test answers it.
class _FakeAuth extends LocalAuthPlatform {
  int prompts = 0;
  Completer<bool>? pending;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    required Iterable<AuthMessages> authMessages,
    AuthenticationOptions options = const AuthenticationOptions(),
  }) {
    prompts++;
    return (pending = Completer<bool>()).future;
  }
}

void main() {
  late _FakeAuth auth;

  setUpAll(AppLockGate.guardBackButton);
  setUp(() => LocalAuthPlatform.instance = auth = _FakeAuth());

  Future<void> pumpLockedApp(WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db
        .into(db.appSettings)
        .insert(
          const AppSettingsCompanion(
            id: Value(1),
            onboardingDone: Value(true),
            appLock: Value(true),
            appLockDelaySeconds: Value(0),
          ),
        );
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
  }

  Future<void> unlock(WidgetTester tester) async {
    auth.pending!.complete(true);
    await tester.pumpAndSettle();
  }

  Future<void> leaveAndReturn(WidgetTester tester) async {
    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pumpAndSettle();
  }

  final locked = find.text('Launenfuchs is locked');
  final statsEmpty = find.text('Stats appear once you have logged a few days.');

  testWidgets('unlocking returns to the same tab', (tester) async {
    await pumpLockedApp(tester);
    expect(locked, findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing, reason: 'hidden');
    await unlock(tester);

    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    await leaveAndReturn(tester);
    expect(locked, findsOneWidget);
    expect(auth.prompts, 2);
    expect(
      await tester.binding.handlePopRoute(),
      isTrue,
      reason: 'back must not pop the screens hidden under the lock',
    );

    await unlock(tester);
    expect(locked, findsNothing);
    expect(statsEmpty, findsOneWidget);
  });

  testWidgets('our own system dialogs do not lock the app', (tester) async {
    await pumpLockedApp(tester);
    await unlock(tester);

    final permission = Completer<bool>();
    final asked = systemPrompt(() => permission.future);
    await leaveAndReturn(tester);
    permission.complete(true);
    await asked;
    await tester.pumpAndSettle();
    expect(locked, findsNothing);
    expect(auth.prompts, 1);
  });
}
