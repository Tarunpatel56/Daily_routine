import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/routine_model.dart';
import '../models/study_target_model.dart';
import '../models/challenge_model.dart';
import '../models/study_session_model.dart';
import '../models/timetable_model.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // Routines
  List<Routine> getRoutines() {
    List? rawData = _box.read<List>('routines');
    if (rawData == null) return [];
    return rawData.map((e) => Routine.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  void saveRoutines(List<Routine> routines) {
    _box.write('routines', routines.map((e) => e.toJson()).toList());
  }

  // Targets
  List<StudyTarget> getTargets() {
    List? rawData = _box.read<List>('targets');
    if (rawData == null) return [];
    return rawData.map((e) => StudyTarget.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  void saveTargets(List<StudyTarget> targets) {
    _box.write('targets', targets.map((e) => e.toJson()).toList());
  }

  // Challenges
  List<Challenge> getChallenges() {
    List? rawData = _box.read<List>('challenges');
    if (rawData == null) return [];
    return rawData.map((e) => Challenge.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  void saveChallenges(List<Challenge> challenges) {
    _box.write('challenges', challenges.map((e) => e.toJson()).toList());
  }

  // Timetable
  List<TimetableEntry> getTimetableEntries() {
    List? rawData = _box.read<List>('timetable');
    if (rawData == null) return [];
    return rawData.map((e) => TimetableEntry.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  void saveTimetableEntries(List<TimetableEntry> entries) {
    _box.write('timetable', entries.map((e) => e.toJson()).toList());
  }

  // Study watch
  Map<String, dynamic> getStudyWatchState() {
    final rawData = _box.read('study_watch');
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    return {};
  }

  void saveStudyWatchState(Map<String, dynamic> state) {
    _box.write('study_watch', state);
  }

  List<StudySession> getStudySessions() {
    List? rawData = _box.read<List>('study_sessions');
    if (rawData == null) return [];
    return rawData
        .map((e) => StudySession.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void saveStudySessions(List<StudySession> sessions) {
    _box.write('study_sessions', sessions.map((e) => e.toJson()).toList());
  }
}
