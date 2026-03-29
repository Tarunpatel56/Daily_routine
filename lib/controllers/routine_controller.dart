import 'package:get/get.dart';

import '../models/routine_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class RoutineController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  var routines = <Routine>[].obs;

  @override
  void onInit() {
    super.onInit();
    routines.assignAll(_storage.getRoutines());
  }

  void addRoutine(String title, String description, DateTime date) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newRoutine = Routine(
      id: id,
      title: title,
      description: description,
      date: date,
    );

    routines.add(newRoutine);
    _scheduleRoutineNotifications(newRoutine, allowInstantReminder: true);
    _save();
  }

  void toggleRoutineCompletion(String id) {
    final index = routines.indexWhere((r) => r.id == id);
    if (index != -1) {
      routines[index].isCompleted = !routines[index].isCompleted;
      routines.refresh();
      _save();
    }
  }

  void deleteRoutine(String id) {
    routines.removeWhere((r) => r.id == id);
    Get.find<NotificationService>().cancelNotifications(_notificationIds(id));
    _save();
  }

  void rescheduleNotifications() {
    _rescheduleSavedRoutines();
  }

  void _rescheduleSavedRoutines() {
    for (final routine in routines) {
      _scheduleRoutineNotifications(routine, allowInstantReminder: false);
    }
  }

  void _scheduleRoutineNotifications(
    Routine routine, {
    required bool allowInstantReminder,
  }) {
    final ns = Get.find<NotificationService>();
    final ids = _notificationIds(routine.id);
    final reminderId = ids.first;
    final startId = ids.last;

    final now = DateTime.now();
    final startTime = routine.date;
    final reminderTime = startTime.subtract(const Duration(minutes: 10));

    if (reminderTime.isAfter(now)) {
      ns.scheduleNotification(
        id: reminderId,
        title: '${routine.title} 10 min me start hoga',
        body: 'Routine start hone wala hai. Tayyar ho jao.',
        scheduledDate: reminderTime,
      );
    } else if (allowInstantReminder && startTime.isAfter(now)) {
      ns.showInstantNotification(
        id: reminderId,
        title: '${routine.title} jaldi start hoga',
        body: 'Routine ${_remainingMinutes(startTime, now)} me start hoga.',
      );
    }

    if (startTime.isAfter(now)) {
      ns.scheduleNotification(
        id: startId,
        title: '${routine.title} ab start ho gaya',
        body: 'Routine ka time ho gaya hai. Ab shuru karo.',
        scheduledDate: startTime,
      );
    }
  }

  List<int> _notificationIds(String routineId) {
    final ns = Get.find<NotificationService>();
    return [
      ns.buildNotificationId('routine:$routineId:before'),
      ns.buildNotificationId('routine:$routineId:start'),
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

  void _save() {
    _storage.saveRoutines(routines.toList());
  }
}
