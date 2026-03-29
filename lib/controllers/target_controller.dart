import 'package:get/get.dart';
import '../models/study_target_model.dart';
import '../services/storage_service.dart';

class TargetController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  var targets = <StudyTarget>[].obs;

  @override
  void onInit() {
    super.onInit();
    targets.assignAll(_storage.getTargets());
  }

  void addTarget(String title, String description, DateTime targetDate) {
    var newTarget = StudyTarget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      targetDate: targetDate,
    );
    targets.add(newTarget);
    _save();
  }

  void toggleTargetCompletion(String id) {
    var index = targets.indexWhere((t) => t.id == id);
    if (index != -1) {
      targets[index].isCompleted = !targets[index].isCompleted;
      targets.refresh();
      _save();
    }
  }

  void deleteTarget(String id) {
    targets.removeWhere((t) => t.id == id);
    _save();
  }

  void _save() {
    _storage.saveTargets(targets);
  }
}
