import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../system_prompt.dart';

/// The platform half of the daily reminder (design-concept §2.8; the *when*
/// is the pure [reminderTimes]). Discrete one-off notifications, re-filled on
/// every sync — logging today simply drops today's from the input. Inexact
/// alarms: no special permission, a few minutes' drift is fine.
class ReminderScheduler {
  ReminderScheduler({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;
  bool _unavailable = false;

  static const _channelId = 'daily-reminder';
  static const _firstId = 100;
  static const _maxIds = 31;

  /// Called when a reminder is tapped (also on a cold start from one).
  final _taps = StreamController<void>.broadcast();
  Stream<void> get taps => _taps.stream;

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
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        scheduleMicrotask(() => _taps.add(null));
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
  Future<void> sync(
    List<DateTime> times, {
    required String title,
    required String body,
    required String channelName,
    required String channelDescription,
  }) async {
    if (!await _ensureReady()) return;
    try {
      for (var i = 0; i < _maxIds; i++) {
        await _plugin.cancel(id: _firstId + i);
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
