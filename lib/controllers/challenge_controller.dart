import 'package:get/get.dart';
import '../models/challenge_model.dart';
import '../services/storage_service.dart';

class ChallengeController extends GetxController {
  var challenges = <Challenge>[].obs;
  final storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    challenges.assignAll(storage.getChallenges());
  }

  void addChallenge(String title, String description, int totalDays, {DateTime? startDate}) {
    var newChallenge = Challenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      totalDays: totalDays,
      startDate: startDate ?? DateTime.now(),
    );
    challenges.add(newChallenge);
    _save();
  }

  void addDailyLog(String challengeId, String entry, {DateTime? logDate}) {
    var index = challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1) {
      challenges[index].logs.add(DailyLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: logDate ?? DateTime.now(),
        entry: entry,
      ));
      // tell GetX the logs list inside challenge has updated
      challenges.refresh(); 
      _save();
    }
  }

  void deleteChallenge(String id) {
    challenges.removeWhere((c) => c.id == id);
    _save();
  }

  void _save() {
    storage.saveChallenges(challenges.toList());
  }
}
