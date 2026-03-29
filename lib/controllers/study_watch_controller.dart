import 'dart:async';

import 'package:get/get.dart';

import '../models/study_session_model.dart';
import '../services/storage_service.dart';

class StudyWatchController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxBool isRunning = false.obs;
  final RxInt elapsedMilliseconds = 0.obs;
  final RxList<StudySession> dailyLogs = <StudySession>[].obs;

  Timer? _ticker;
  int _accumulatedMilliseconds = 0;
  int _sessionBaselineMilliseconds = 0;
  DateTime? _startedAt;
  DateTime? _sessionStartedAt;

  @override
  void onInit() {
    super.onInit();
    dailyLogs.assignAll(_normalizeDailyLogs(_storage.getStudySessions()));
    _persistDailyLogs();
    _restoreState();
  }

  void start() {
    if (isRunning.value) {
      return;
    }

    final now = DateTime.now();
    _startedAt = now;
    _sessionStartedAt = now;
    _sessionBaselineMilliseconds = _accumulatedMilliseconds;
    isRunning.value = true;
    _syncElapsed();
    _startTicker();
    _saveState();
  }

  StudySession? pause() {
    if (!isRunning.value) {
      return null;
    }

    final endedAt = DateTime.now();
    _syncElapsed(endedAt);

    final segmentDurationMilliseconds =
        elapsedMilliseconds.value - _sessionBaselineMilliseconds;
    StudySession? savedLog;

    if (_sessionStartedAt != null && segmentDurationMilliseconds >= 1000) {
      savedLog = _saveSegmentAcrossDays(_sessionStartedAt!, endedAt);
    }

    _accumulatedMilliseconds = elapsedMilliseconds.value;
    _sessionBaselineMilliseconds = _accumulatedMilliseconds;
    _startedAt = null;
    _sessionStartedAt = null;
    isRunning.value = false;
    _stopTicker();
    _saveState();
    return savedLog;
  }

  void reset() {
    _accumulatedMilliseconds = 0;
    _sessionBaselineMilliseconds = 0;
    elapsedMilliseconds.value = 0;

    if (isRunning.value) {
      final now = DateTime.now();
      _startedAt = now;
      _sessionStartedAt = now;
      _startTicker();
    } else {
      _startedAt = null;
      _sessionStartedAt = null;
      _stopTicker();
    }

    _saveState();
  }

  void setElapsed(Duration duration) {
    _accumulatedMilliseconds = duration.inMilliseconds;
    elapsedMilliseconds.value = _accumulatedMilliseconds;
    _sessionBaselineMilliseconds = _accumulatedMilliseconds;

    if (isRunning.value) {
      final now = DateTime.now();
      _startedAt = now;
      _sessionStartedAt = now;
      _startTicker();
    }

    _saveState();
  }

  String get formattedElapsed => formatDuration(elapsedMilliseconds.value);

  int get todayStudyMilliseconds {
    final now = DateTime.now();
    final persistedTodayMilliseconds = dailyLogs
        .where((log) => _isSameDay(log.endedAt, now))
        .fold<int>(0, (total, log) => total + log.durationMilliseconds);

    return persistedTodayMilliseconds + _runningMillisecondsForDay(now);
  }

  int get totalStudyMilliseconds {
    final persistedMilliseconds = dailyLogs.fold<int>(
      0,
      (total, log) => total + log.durationMilliseconds,
    );

    if (!isRunning.value || _sessionStartedAt == null) {
      return persistedMilliseconds;
    }

    return persistedMilliseconds +
        DateTime.now().difference(_sessionStartedAt!).inMilliseconds;
  }

  List<StudySession> get recentDailyLogs => dailyLogs.take(7).toList();

  String formatDuration(int milliseconds) {
    final totalSeconds = milliseconds ~/ 1000;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _restoreState() {
    final state = _storage.getStudyWatchState();
    _accumulatedMilliseconds =
        (state['accumulatedMilliseconds'] as num?)?.toInt() ?? 0;
    _sessionBaselineMilliseconds =
        (state['sessionBaselineMilliseconds'] as num?)?.toInt() ??
            _accumulatedMilliseconds;

    final storedStartedAt = state['startedAt'] as String?;
    final storedSessionStartedAt = state['sessionStartedAt'] as String?;
    final storedIsRunning = state['isRunning'] == true;

    if (storedIsRunning && storedStartedAt != null) {
      _startedAt = DateTime.tryParse(storedStartedAt);
      _sessionStartedAt = storedSessionStartedAt == null
          ? _startedAt
          : DateTime.tryParse(storedSessionStartedAt);
      isRunning.value = _startedAt != null;
    } else {
      _startedAt = null;
      _sessionStartedAt = null;
      isRunning.value = false;
    }

    _syncElapsed();

    if (isRunning.value) {
      _startTicker();
    }
  }

  void _syncElapsed([DateTime? now]) {
    final currentTime = now ?? DateTime.now();
    if (isRunning.value && _startedAt != null) {
      elapsedMilliseconds.value = _accumulatedMilliseconds +
          currentTime.difference(_startedAt!).inMilliseconds;
      return;
    }

    elapsedMilliseconds.value = _accumulatedMilliseconds;
  }

  void _startTicker() {
    _stopTicker();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncElapsed();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _saveState() {
    _storage.saveStudyWatchState({
      'isRunning': isRunning.value,
      'accumulatedMilliseconds': _accumulatedMilliseconds,
      'startedAt': _startedAt?.toIso8601String(),
      'sessionStartedAt': _sessionStartedAt?.toIso8601String(),
      'sessionBaselineMilliseconds': _sessionBaselineMilliseconds,
    });
  }

  List<StudySession> _normalizeDailyLogs(List<StudySession> rawLogs) {
    final Map<String, StudySession> grouped = {};

    for (final log in rawLogs) {
      final key =
          '${log.endedAt.year}-${log.endedAt.month}-${log.endedAt.day}';
      final existing = grouped[key];
      if (existing == null) {
        grouped[key] = log;
        continue;
      }

      grouped[key] = StudySession(
        id: existing.id,
        startedAt: existing.startedAt.isBefore(log.startedAt)
            ? existing.startedAt
            : log.startedAt,
        endedAt: existing.endedAt.isAfter(log.endedAt)
            ? existing.endedAt
            : log.endedAt,
        durationMilliseconds:
            existing.durationMilliseconds + log.durationMilliseconds,
      );
    }

    final normalized = grouped.values.toList()
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));
    return normalized;
  }

  int _runningMillisecondsForDay(DateTime day) {
    if (!isRunning.value || _sessionStartedAt == null) {
      return 0;
    }

    final now = DateTime.now();
    return _overlapMillisecondsForDay(
      rangeStart: _sessionStartedAt!,
      rangeEnd: now,
      day: day,
    );
  }

  StudySession? _saveSegmentAcrossDays(DateTime startedAt, DateTime endedAt) {
    if (!endedAt.isAfter(startedAt)) {
      return null;
    }

    DateTime chunkStart = startedAt;
    StudySession? currentDayLog;

    while (chunkStart.isBefore(endedAt)) {
      final nextMidnight = DateTime(
        chunkStart.year,
        chunkStart.month,
        chunkStart.day + 1,
      );
      final chunkEnd = endedAt.isBefore(nextMidnight) ? endedAt : nextMidnight;
      final chunkDurationMilliseconds =
          chunkEnd.difference(chunkStart).inMilliseconds;

      if (chunkDurationMilliseconds >= 1000) {
        final savedLog = _mergeDailyLog(
          startedAt: chunkStart,
          endedAt: chunkEnd,
          durationMilliseconds: chunkDurationMilliseconds,
        );

        if (_isSameDay(savedLog.endedAt, endedAt)) {
          currentDayLog = savedLog;
        }
      }

      chunkStart = chunkEnd;
    }

    if (dailyLogs.length > 365) {
      dailyLogs.removeRange(365, dailyLogs.length);
    }
    dailyLogs.sort((a, b) => b.endedAt.compareTo(a.endedAt));
    _persistDailyLogs();

    return currentDayLog;
  }

  StudySession _mergeDailyLog({
    required DateTime startedAt,
    required DateTime endedAt,
    required int durationMilliseconds,
  }) {
    final sameDayIndex =
        dailyLogs.indexWhere((log) => _isSameDay(log.endedAt, startedAt));

    if (sameDayIndex == -1) {
      final newLog = StudySession(
        id: startedAt.microsecondsSinceEpoch.toString(),
        startedAt: startedAt,
        endedAt: endedAt,
        durationMilliseconds: durationMilliseconds,
      );
      dailyLogs.insert(0, newLog);
      return newLog;
    }

    final existing = dailyLogs[sameDayIndex];
    final updatedLog = StudySession(
      id: existing.id,
      startedAt: existing.startedAt.isBefore(startedAt)
          ? existing.startedAt
          : startedAt,
      endedAt: existing.endedAt.isAfter(endedAt) ? existing.endedAt : endedAt,
      durationMilliseconds:
          existing.durationMilliseconds + durationMilliseconds,
    );
    dailyLogs[sameDayIndex] = updatedLog;
    return updatedLog;
  }

  int _overlapMillisecondsForDay({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required DateTime day,
  }) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final overlapStart = rangeStart.isAfter(dayStart) ? rangeStart : dayStart;
    final overlapEnd = rangeEnd.isBefore(dayEnd) ? rangeEnd : dayEnd;

    if (!overlapEnd.isAfter(overlapStart)) {
      return 0;
    }

    return overlapEnd.difference(overlapStart).inMilliseconds;
  }

  void _persistDailyLogs() {
    _storage.saveStudySessions(dailyLogs.toList().reversed.toList());
  }

  @override
  void onClose() {
    _stopTicker();
    super.onClose();
  }
}
