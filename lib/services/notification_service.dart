import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static const String _channelId = 'routine_alarm_channel_v2';
  static const String _channelName = 'Routine Alarm Notifications';
  static const String _channelDescription =
      'Alarm alerts for routines and study timetable';
  static const RawResourceAndroidNotificationSound _alarmSound =
      RawResourceAndroidNotificationSound('alarm');

  static final Int64List _vibrationPattern =
      Int64List.fromList([0, 700, 300, 700, 300, 700]);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  AndroidFlutterLocalNotificationsPlugin? _androidImpl;
  Future<void>? _initializingFuture;
  bool _isInitialized = false;

  Future<NotificationService> init() async {
    await _ensureInitialized();

    return this;
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    if (_initializingFuture != null) {
      await _initializingFuture;
      return;
    }

    _initializingFuture = _performInitialization();
    await _initializingFuture;
  }

  Future<void> _performInitialization() async {
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _plugin.initialize(initSettings);
      _androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await _createAndroidChannel();
      _isInitialized = true;
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] Initialization failed: $error\n$stackTrace',
      );
    } finally {
      _initializingFuture = null;
    }
  }

  Future<void> _createAndroidChannel() async {
    final androidImpl = _androidImpl;

    if (androidImpl == null) {
      return;
    }

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
      playSound: true,
      sound: _alarmSound,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await androidImpl.createNotificationChannel(channel);
  }

  Future<void> requestPermissions() async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return;
    }

    final androidImpl = _androidImpl;

    if (androidImpl != null) {
      try {
        await androidImpl.requestExactAlarmsPermission();
        await androidImpl.requestNotificationsPermission();
      } catch (error, stackTrace) {
        debugPrint(
          '[NotificationService] Permission request failed: $error\n$stackTrace',
        );
      }
    }
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }

    final androidImpl = _androidImpl;
    if (androidImpl == null) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    final canScheduleExact =
        await androidImpl.canScheduleExactNotifications() ?? false;
    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  int buildNotificationId(String seed) {
    var hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  NotificationDetails _details() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        playSound: true,
        sound: _alarmSound,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return;
    }

    try {
      await _plugin.show(id, title, body, _details());
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] Instant notification failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return;
    }

    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
        '[NotificationService] Skipped past notification for $scheduledDate',
      );
      return;
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final scheduleMode = await _scheduleMode();

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        _details(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] Scheduled notification failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return;
    }

    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    final scheduleMode = await _scheduleMode();

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        _details(),
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] Daily notification failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    if (!_isInitialized) {
      return;
    }

    try {
      await _plugin.cancel(id);
    } catch (error, stackTrace) {
      debugPrint(
        '[NotificationService] Cancel notification failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> cancelNotifications(Iterable<int> ids) async {
    for (final id in ids) {
      await cancelNotification(id);
    }
  }
}
