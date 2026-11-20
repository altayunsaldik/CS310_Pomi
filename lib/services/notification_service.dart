import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Schedules a system notification for the moment a session/break ends so the
/// user is told even when the app is in the background.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  static const _id = 1;
  static const _channelId = 'pomodoro_timer';

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // Tapping the notification just opens the app, which lands on the timer.
    await _plugin
        .initialize(const InitializationSettings(android: android, iOS: ios));
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleAt({
    required DateTime at,
    required String title,
    required String body,
    required bool vibrate,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Timer alerts',
        channelDescription: 'Tells you when a session or break has ended',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: vibrate,
      ),
      iOS: const DarwinNotificationDetails(
          presentAlert: true, presentSound: true),
    );
    final when = tz.TZDateTime.from(at, tz.local);
    try {
      await _plugin.zonedSchedule(
        _id,
        title,
        body,
        when,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Exact alarms not permitted: fall back to an inexact one.
      try {
        await _plugin.zonedSchedule(
          _id,
          title,
          body,
          when,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (_) {}
    }
  }

  Future<void> cancel() async {
    try {
      await _plugin.cancel(_id);
    } catch (_) {}
  }
}
