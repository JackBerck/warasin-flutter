import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();
  int _safeNotifId(int id) => id & 0x7fffffff;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation('Asia/Jakarta'),
    ); // Set timezone Indonesia

    // Android settings
    final androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await requestPermissions();

    // Create notification channel for Android
    await _createNotificationChannel();
  }

  // Request notification permissions
  // Update requestPermissions method di notification_service.dart
  Future<bool> requestPermissions() async {
    // Request notification permission
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (!status.isGranted) {
        print('❌ Notification permission denied');
        return false;
      }
    }

    // For Android 13+ (API 33+) - CRITICAL!
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      print('📱 Schedule Exact Alarm permission: $status');
    }

    // TAMBAHAN: Request exact alarm permission via plugin
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImpl != null) {
      final granted = await androidImpl.requestExactAlarmsPermission();
      print('⏰ Exact Alarms Permission: $granted');

      if (granted == false) {
        print('❌ Exact alarm permission not granted!');
        // Bisa show dialog untuk guide user ke settings
      }
    }

    return true;
  }

  // Create Android notification channel
  Future<void> _createNotificationChannel() async {
    final androidChannel = AndroidNotificationChannel(
      'medicine_reminder_channel',
      'Pengingat Obat',
      description: 'Channel untuk pengingat minum obat',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(
        'notification_sound',
      ), // Custom sound
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation atau action lainnya
  }

  // Schedule daily notification
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required List<int> days,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    final baseId = _safeNotifId(id);

    print(
      '🔔 Scheduling notification for ${time.hour}:${time.minute} on days: $days',
    );
    print('📅 Current time: ${now.hour}:${now.minute} (${now.weekday})');

    for (int day in days) {
      final notificationId = _safeNotifId(baseId * 10 + day);

      // Calculate next occurrence for this day
      tz.TZDateTime scheduledDate = _nextInstanceOfDayAndTime(day, time, now);

      print('⏰ Scheduling notification:');
      print('   - ID: $notificationId');
      print('   - Day: $day (${_getDayName(day)})');
      print('   - Time: ${time.hour}:${time.minute}');
      print(
        '   - Next occurrence: ${scheduledDate.year}-${scheduledDate.month}-${scheduledDate.day} ${scheduledDate.hour}:${scheduledDate.minute}',
      );

      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        scheduledDate,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      print('✅ Scheduled notification id=$notificationId for day $day');
    }

    // Verify
    final pending = await getPendingNotifications();
    print('📊 Total pending notifications: ${pending.length}');
  }

  String _getDayName(int day) {
    const days = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    };
    return days[day] ?? 'Unknown';
  }

  // Calculate next instance of day and time
  tz.TZDateTime _nextInstanceOfDayAndTime(
    int day,
    TimeOfDay time,
    tz.TZDateTime now,
  ) {
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Adjust to correct day of week (1=Monday, 7=Sunday)
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // If the time has passed today, schedule for next week
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  // Notification details
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'medicine_reminder_channel',
        'Pengingat Obat',
        channelDescription: 'Channel untuk pengingat minum obat',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
        icon: '@mipmap/ic_launcher',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.caf', // Custom sound for iOS
        interruptionLevel: InterruptionLevel.timeSensitive,
      ),
    );
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id, List<int> days) async {
    final baseId = _safeNotifId(id);
    for (int day in days) {
      final notificationId = _safeNotifId(baseId * 10 + day);
      await _notifications.cancel(notificationId);
      print('❌ Cancelled notification $notificationId');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ Cancelled all notifications');
  }

  // Get pending notifications (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(id, title, body, _notificationDetails());
  }
}
