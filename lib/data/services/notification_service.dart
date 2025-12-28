import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/task_model.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions for Android 13+
    await _requestNotificationPermissions();
  }

  static Future<void> _requestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('❌ Notification permission denied');
      } else {
        print('✅ Notification permission granted');
      }
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific task
  }

  // Schedule a one-time notification for task deadline
  static Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderTime == null) return;

    try {
      final scheduledTime = tz.TZDateTime.from(task.reminderTime!, tz.local);

      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode, // Unique ID based on task
        _getMotivationalTitle(task),
        _getMotivationalBody(task),
        scheduledTime,
        _getNotificationDetails(task.priority),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: task.id.toString(),
      );

      print('✅ Reminder scheduled for: ${task.title}');
    } catch (e) {
      print('❌ Error scheduling reminder: $e');
    }
  }

  // Schedule recurring notifications for daily/weekly/monthly tasks
  static Future<void> scheduleRecurringReminder(Task task) async {
    if (task.reminderTime == null || task.recurrence == TaskRecurrence.none) {
      return;
    }

    try {
      DateTimeComponents? dateTimeComponents;

      switch (task.recurrence) {
        case TaskRecurrence.daily:
          dateTimeComponents = DateTimeComponents.time;
          break;
        case TaskRecurrence.weekly:
          dateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
          break;
        case TaskRecurrence.monthly:
          dateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
          break;
        case TaskRecurrence.none:
          return;
      }

      final scheduledTime = tz.TZDateTime.from(task.reminderTime!, tz.local);

      await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        _getRecurringTitle(task),
        _getRecurringBody(task),
        scheduledTime,
        _getNotificationDetails(task.priority),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: dateTimeComponents,
        payload: task.id.toString(),
      );

      print('✅ Recurring reminder scheduled for: ${task.title}');
    } catch (e) {
      print('❌ Error scheduling recurring reminder: $e');
    }
  }

  // Get notification details based on priority
  static NotificationDetails _getNotificationDetails(TaskPriority priority) {
    Color lightColor;
    Color ledColor;
    String channelId;
    String channelName;
    Importance importance;

    switch (priority) {
      case TaskPriority.critical:
        lightColor = const Color(0xFFFF0000);
        ledColor = const Color(0xFFFF0000);
        channelId = 'critical_tasks';
        channelName = 'Critical Tasks';
        importance = Importance.max;
        break;
      case TaskPriority.high:
        lightColor = const Color(0xFFFF6B00);
        ledColor = const Color(0xFFFF6B00);
        channelId = 'high_priority_tasks';
        channelName = 'High Priority Tasks';
        importance = Importance.high;
        break;
      case TaskPriority.medium:
        lightColor = const Color(0xFF00C896);
        ledColor = const Color(0xFF00C896);
        channelId = 'medium_priority_tasks';
        channelName = 'Medium Priority Tasks';
        importance = Importance.defaultImportance;
        break;
      case TaskPriority.low:
        lightColor = const Color(0xFF6C63FF);
        ledColor = const Color(0xFF6C63FF);
        channelId = 'low_priority_tasks';
        channelName = 'Low Priority Tasks';
        importance = Importance.low;
        break;
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notifications for $channelName',
        importance: importance,
        priority: Priority.high,
        ledColor: ledColor,
        ledOnMs: 1000,
        ledOffMs: 500,
        color: lightColor,
        icon: '@mipmap/ic_launcher',
        styleInformation: const BigTextStyleInformation(''),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: priority == TaskPriority.critical ? 'alarm.wav' : null,
      ),
    );
  }

  // Generate motivational titles based on task and time
  static String _getMotivationalTitle(Task task) {
    final hour = task.reminderTime!.hour;

    if (hour < 12) {
      return "🌅 Rise & Dominate!";
    } else if (hour < 17) {
      return "⚡ Conquer Your Afternoon!";
    } else {
      return "🔥 Evening Victory Awaits!";
    }
  }

  // Generate motivational notification body
  static String _getMotivationalBody(Task task) {
    final messages = [
      "Time to crush '${task.title}' - You're unstoppable! 💪",
      "Your goal '${task.title}' is calling - Answer with excellence! 🎯",
      "Champions act now: '${task.title}' awaits your dominance! 🏆",
      "Unleash your power on '${task.title}' - No limits! ⚡",
      "Victory is yours: Complete '${task.title}' like the boss you are! 👑",
    ];

    return messages[DateTime.now().millisecond % messages.length];
  }

  // Generate recurring notification titles
  static String _getRecurringTitle(Task task) {
    switch (task.recurrence) {
      case TaskRecurrence.daily:
        return "🔥 Daily Domination Time!";
      case TaskRecurrence.weekly:
        return "📅 Weekly Goal Crusher!";
      case TaskRecurrence.monthly:
        return "🚀 Monthly Mission Alert!";
      case TaskRecurrence.none:
        return "⚡ Task Reminder";
    }
  }

  // Generate recurring notification body
  static String _getRecurringBody(Task task) {
    final recurringMessages = {
      TaskRecurrence.daily: [
        "Another day, another victory! Dominate '${task.title}' 🔥",
        "Daily excellence calls: '${task.title}' is your battlefield! ⚔️",
        "Consistency breeds champions - Crush '${task.title}' today! 💎",
      ],
      TaskRecurrence.weekly: [
        "Weekly warrior mode: Time to conquer '${task.title}' 🏹",
        "Your weekly mission: Dominate '${task.title}' with style! 🎯",
        "Week after week, you rise: '${task.title}' awaits! 🏆",
      ],
      TaskRecurrence.monthly: [
        "Monthly mastermind moment: '${task.title}' is your target! 🎯",
        "Once a month, you shine: Crush '${task.title}' spectacularly! ✨",
        "Monthly milestone: '${task.title}' is your stepping stone to greatness! 🚀",
      ],
      TaskRecurrence.none: [
        "Time to take action on '${task.title}'! 💪",
      ],
    };

    final messages = recurringMessages[task.recurrence] ??
        recurringMessages[TaskRecurrence.none]!;
    return messages[DateTime.now().millisecond % messages.length];
  }

  // Cancel specific notification
  static Future<void> cancelNotification(int notificationId) async {
    await _notificationsPlugin.cancel(notificationId);
    print('✅ Notification canceled: $notificationId');
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print('✅ All notifications canceled');
  }
}
