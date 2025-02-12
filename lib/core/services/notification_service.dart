import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();


  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // GlobalKey navigatorKey;
        // showDialog(
        //   context: navigatorKey.currentContext!,
        //   builder: (context) => AlertDialog(
        //     title: Text(title ?? "Task Reminder"),
        //     content: Text(body ?? "You have a task due!"),
        //     actions: [
        //       TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))
        //     ],
        //   ),
        // );
      },
    );

    final InitializationSettings initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _notificationsPlugin.initialize(initSettings);
// Request permission for iOS
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    tz.initializeTimeZones(); // Required for scheduled notifications
  }

  /// 🔔 Show Instant Notification
  static Future<void> showNotification(
      {required int id,required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_channel_id',
      'Task Notifications',
      channelDescription: 'Reminders for tasks',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: 'Task Reminders',
        interruptionLevel: InterruptionLevel.critical);

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  /// ⏰ Schedule Task Reminder Notification
  static Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Reminders for tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
