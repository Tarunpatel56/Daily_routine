import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/target_controller.dart';
import 'add_target_screen.dart';

class TargetsScreen extends StatelessWidget {
  TargetsScreen({super.key});

  TargetController get targetCtrl => Get.find<TargetController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Study Targets', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (targetCtrl.targets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars, size: 80, color: Colors.black12),
                const SizedBox(height: 16),
                const Text("No active targets.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Get.to(() => AddTargetScreen()),
                  child: const Text("Set a new goal!", style: TextStyle(fontSize: 16, color: Color(0xFFFF512F))),
                )
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: targetCtrl.targets.length,
          itemBuilder: (context, index) {
            var target = targetCtrl.targets[index];
            bool isUrgent = target.daysRemaining <= 3 && !target.isCompleted;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: target.isCompleted ? Colors.green : (isUrgent ? Colors.redAccent : const Color(0xFFFF512F)), width: 6))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              target.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: target.isCompleted ? TextDecoration.lineThrough : null,
                                color: target.isCompleted ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: target.isCompleted ? Colors.green.withOpacity(0.1) : (isUrgent ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            child: Text(
                              target.isCompleted ? "Done" : "${target.daysRemaining} days left",
                              style: TextStyle(
                                color: target.isCompleted ? Colors.green : (isUrgent ? Colors.red : Colors.orange),
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(target.description, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text("Deadline: ${DateFormat.yMMMd().format(target.targetDate)}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: Icon(target.isCompleted ? Icons.check_circle : Icons.circle_outlined, color: target.isCompleted ? Colors.green : Colors.grey, size: 28),
                                onPressed: () => targetCtrl.toggleTargetCompletion(target.id),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
                                onPressed: () => targetCtrl.deleteTarget(target.id),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddTargetScreen()),
        backgroundColor: const Color(0xFFFF512F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Target", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
