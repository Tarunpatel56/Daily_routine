import 'package:get/get.dart';
import '../controllers/routine_controller.dart';
import '../controllers/target_controller.dart';
import '../controllers/challenge_controller.dart';
import '../controllers/timetable_controller.dart';
import '../controllers/study_watch_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(RoutineController(), permanent: true);
    Get.put(TargetController(), permanent: true);
    Get.put(ChallengeController(), permanent: true);
    Get.put(TimetableController(), permanent: true);
    Get.put(StudyWatchController(), permanent: true);
  }
}
