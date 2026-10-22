import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../domain/mood.dart';
import '../system_prompt.dart';

/// The platform half of the daily reminder (design-concept §2.8; the *when*
/// is the pure [reminderTimes]). Discrete one-off notifications, re-filled on
/// every sync — logging today simply drops today's from the input. Inexact
/// alarms: no special permission, a few minutes' drift is fine.
///
/// On Android the reminder is native (`Reminder.kt`): a notification with the
/// five moods, which flutter_local_notifications can't lay out. The plugin
/// stays for iOS and for the Android permission prompt.
class ReminderScheduler {
  ReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool _unavailable = false;

  static const _channelId = 'daily-reminder';
  static const _firstId = 100;
  static const _maxIds = 31;

  static const _android = MethodChannel('launenfuchs/reminder');
  static bool get _native => !kIsWeb && Platform.isAndroid;

  /// A tapped reminder (also on a cold start from one), with the mood when a
  /// face was tapped.
  final _taps = StreamController<Mood?>.broadcast();
  Stream<Mood?> get taps => _taps.stream;

  void _tapped(int? mood) => _taps.add(
    mood != null && mood >= 1 && mood <= 5 ? Mood.fromValue(mood) : null,
  );

  Future<bool> _ensureReady() async {
    if (_ready) return true;
    if (_unavailable) return false;
    try {
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (_) => _taps.add(null),
      );
      if (_native) {
        _android.setMethodCallHandler((call) async {
          if (call.method == 'tap') _tapped(call.arguments as int?);
        });
        final mood = await _android.invokeMethod<int>('launchTap');
        if (mood != null) scheduleMicrotask(() => _tapped(mood));
      } else {
        final launch = await _plugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) {
          scheduleMicrotask(() => _tapped(null));
        }
      }
      _ready = true;
      return true;
    } catch (e) {
      // No notification runtime (tests, desktop): reminders are simply off.
      debugPrint('ReminderScheduler unavailable: $e');
      _unavailable = true;
      return false;
    }
  }

  /// Starts listening for taps early (app start).
  Future<void> init() => _ensureReady();

  Future<bool> requestPermission() async {
    if (!await _ensureReady()) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final a = await systemPrompt(
        () async => android?.requestNotificationsPermission(),
      );
      final i = await systemPrompt(
        () async =>
            ios?.requestPermissions(alert: true, badge: true, sound: true),
      );
      return a ?? i ?? true;
    } catch (e) {
      debugPrint('requestPermission failed: $e');
      return false;
    }
  }

  /// Replaces the schedule with [times] (empty = reminders off).
  /// [moods] are the five labels, worst first (for TalkBack on the faces);
  /// [todayLogged] clears a reminder still showing.
  Future<void> sync(
    List<DateTime> times, {
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
    required List<String> moods,
    required bool todayLogged,
  }) async {
    if (!await _ensureReady()) return;
    try {
      // On Android this also clears what builds before Reminder.kt scheduled.
      for (var i = 0; i < _maxIds; i++) {
        await _plugin.cancel(id: _firstId + i);
      }
      if (_native) {
        await _android.invokeMethod<void>('sync', {
          'times': [for (final t in times) t.millisecondsSinceEpoch],
          'title': title,
          'body': body,
          'channelName': channelName,
          'channelDescription': channelDescription,
          'moods': moods,
          'todayLogged': todayLogged,
        });
        return;
      }
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      for (var i = 0; i < times.length && i < _maxIds; i++) {
        await _plugin.zonedSchedule(
          id: _firstId + i,
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(times[i], tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('reminder sync failed: $e');
    }
  }
}
