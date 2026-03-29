import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/timetable_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class TimetableController extends GetxController {
  final storage = Get.find<StorageService>();

  var entries = <TimetableEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    entries.assignAll(storage.getTimetableEntries());
    _sortEntries();
  }

  void addEntry(String title, TimeOfDay start, TimeOfDay end) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final entry = TimetableEntry(
      id: id,
      title: title,
      startTime: start,
      endTime: end,
    );

    entries.add(entry);
    _sortEntries();
    _scheduleEntryNotifications(entry, allowInstantReminder: true);
    _save();
  }

  void deleteEntry(String id) {
    entries.removeWhere((e) => e.id == id);
    Get.find<NotificationService>().cancelNotifications(_notificationIds(id));
    _save();
  }

  void rescheduleNotifications() {
    _rescheduleSavedEntries();
  }

  void _rescheduleSavedEntries() {
    for (final entry in entries) {
      _scheduleEntryNotifications(entry, allowInstantReminder: false);
    }
  }

  void _scheduleEntryNotifications(
    TimetableEntry entry, {
    required bool allowInstantReminder,
  }) {
    final ns = Get.find<NotificationService>();
    final ids = _notificationIds(entry.id);
    final reminderId = ids.first;
    final startId = ids.last;

    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      entry.startTime.hour,
      entry.startTime.minute,
    );
    final reminderDateTime =
        startDateTime.subtract(const Duration(minutes: 10));
    final reminderTime = TimeOfDay.fromDateTime(reminderDateTime);

    ns.scheduleDailyNotification(
      id: reminderId,
      title: '${entry.title} 10 min me start hoga',
      body: 'Study session start hone wala hai. Tayyar ho jao.',
      time: reminderTime,
    );

    ns.scheduleDailyNotification(
      id: startId,
      title: '${entry.title} ab start ho gaya',
      body: 'Study ka time ho gaya hai. Ab shuru karo.',
      time: entry.startTime,
    );

    if (allowInstantReminder &&
        !reminderDateTime.isAfter(now) &&
        startDateTime.isAfter(now)) {
      ns.showInstantNotification(
        id: reminderId,
        title: '${entry.title} jaldi start hoga',
        body: 'Study session ${_remainingMinutes(startDateTime, now)} me start hoga.',
      );
    }
  }

  List<int> _notificationIds(String entryId) {
    final ns = Get.find<NotificationService>();
    return [
      ns.buildNotificationId('timetable:$entryId:before'),
      ns.buildNotificationId('timetable:$entryId:start'),
    ];
  }

  String _remainingMinutes(DateTime startTime, DateTime now) {
    final minutes = startTime.difference(now).inMinutes;
    if (minutes <= 0) {
      return 'less than a minute';
    }
    if (minutes == 1) {
      return '1 minute';
    }
    return '$minutes minutes';
  }

  void _sortEntries() {
    entries.sort((a, b) {
      if (a.startTime.hour != b.startTime.hour) {
        return a.startTime.hour.compareTo(b.startTime.hour);
      }
      return a.startTime.minute.compareTo(b.startTime.minute);
    });
  }

  void _save() {
    storage.saveTimetableEntries(entries.toList());
  }
}
