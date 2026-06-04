import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {

  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  
  static Future<void> init() async {

    // INITIALIZE TIMEZONE
    tz.initializeTimeZones();

    tz.setLocalLocation(
      tz.getLocation('Asia/Kolkata'),
    );

    // ANDROID SETTINGS
    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    // INITIALIZE
    await flutterLocalNotificationsPlugin
        .initialize(settings);

    // NOTIFICATION PERMISSION
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // EXACT ALARM PERMISSION
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // =========================================
  // DAILY NOTIFICATIONS
  // =========================================
  static Future<void>
      scheduleDailyNotifications() async {

    // REMOVE OLD NOTIFICATIONS
    await flutterLocalNotificationsPlugin
        .cancelAll();

    await flutterLocalNotificationsPlugin
        .zonedSchedule(
      0,

      "🌞 Good Morning from Wallet Wiz!",

      "💰 Track your expenses today and grow your savings smartly 🚀",

      _morningTime(),

      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_channel',
          'Morning Notifications',

          channelDescription:
              'Daily morning reminders',

          importance: Importance.max,
          priority: Priority.high,

          playSound: true,
          enableVibration: true,
        ),
      ),

      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,

      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,

      matchDateTimeComponents:
          DateTimeComponents.time,
    );

    await flutterLocalNotificationsPlugin
        .zonedSchedule(
      1,

      "🌙 Wallet Wiz Reminder",

      "📊 Don’t forget to update today’s expenses before ending your day 💸",

      _eveningTime(),

      const NotificationDetails(
        android: AndroidNotificationDetails(
          'evening_channel',
          'Evening Notifications',

          channelDescription:
              'Daily evening reminders',

          importance: Importance.max,
          priority: Priority.high,

          playSound: true,
          enableVibration: true,
        ),
      ),

      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,

      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime,

      matchDateTimeComponents:
          DateTimeComponents.time,
    );
  }

  // =========================================
  // TEST NOTIFICATION
  // =========================================
  static Future<void>
      showTestNotification() async {

    await flutterLocalNotificationsPlugin
        .show(
      100,

      "😊 Welcome to Wallet Wiz",

      "💰 Make savings today that help build a better future for you 🚀",

      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',

          channelDescription:
              'Test notification',

          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // =========================================
  // MORNING TIME - 10:30 AM
  // =========================================
  static tz.TZDateTime
      _morningTime() {

    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(
      tz.local,

      now.year,
      now.month,
      now.day,

      10,
      30,
    );

    if (scheduledDate.isBefore(now)) {

      scheduledDate =
          scheduledDate.add(
        const Duration(days: 1),
      );
    }

    return scheduledDate;
  }

  // =========================================
  // EVENING TIME - 6:00 PM
  // =========================================
  static tz.TZDateTime
      _eveningTime() {

    final tz.TZDateTime now =
        tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(
      tz.local,

      now.year,
      now.month,
      now.day,

      18,
      0,
    );

    if (scheduledDate.isBefore(now)) {

      scheduledDate =
          scheduledDate.add(
        const Duration(days: 1),
      );
    }

    return scheduledDate;
  }
}