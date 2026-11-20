import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifier {
  static final _p = FlutterLocalNotificationsPlugin();
  static const _id = 1;

  static Future<void> init() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
    } catch (_) {}
    await _p.initialize(
        settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
    await _p.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> schedule(DateTime at, String title, String body) async {
    try {
      await _p.zonedSchedule(
          id: _id,
          scheduledDate: tz.TZDateTime.from(at, tz.local),
          title: title,
          body: body,
          notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails('pomi_timer', 'Timer', channelDescription: 'Session and break alerts', importance: Importance.high, priority: Priority.high),
              iOS: DarwinNotificationDetails(presentSound: true)),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
    } catch (e) {
      debugPrint('notification schedule failed: $e');
    }
  }

  static Future<void> cancel() => _p.cancel(id: _id);
}
