import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/challenge_controller.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final String challengeId;
  const ChallengeDetailScreen({super.key, required this.challengeId});

  @override
  _ChallengeDetailScreenState createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  final ChallengeController challengeCtrl = Get.find<ChallengeController>();
  final logCtrl = TextEditingController();
  DateTime selectedLogDate = DateTime.now();

  void _pickLogDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedLogDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedLogDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('Challenge Details', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Obx(() {
        var challenge = challengeCtrl.challenges.firstWhereOrNull((c) => c.id == widget.challengeId);
        if (challenge == null) return const Center(child: Text("Challenge not found"));

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple.withOpacity(0.1),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(challenge.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(challenge.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 15),
                  LinearProgressIndicator(
                      value: challenge.totalDays > 0 ? (challenge.daysElapsed / challenge.totalDays).clamp(0.0, 1.0) : 0,
                      backgroundColor: Colors.white,
                      color: Colors.deepPurple,
                      minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("🏃 Total: ${challenge.totalDays} Days", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("✅ Done: ${challenge.daysElapsed}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      Text("⏳ Left: ${challenge.daysRemaining}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(alignment: Alignment.centerLeft, child: Text("Daily Growth Logs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: challenge.logs.isEmpty
                  ? const Center(child: Text("No daily logs yet. Add your first achievement!"))
                  : ListView.builder(
                      itemCount: challenge.logs.length,
                      itemBuilder: (context, index) {
                        var log = challenge.logs[index];
                        return ListTile(
                          title: Text(log.entry),
                          subtitle: Text(DateFormat.yMMMd().format(log.date)),
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Log Date: ${DateFormat.yMMMd().format(selectedLogDate)}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: _pickLogDate,
                        child: const Icon(Icons.edit_calendar, size: 16, color: Colors.deepPurple),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: logCtrl,
                          decoration: const InputDecoration(
                            hintText: 'What did you achieve?',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10)
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () {
                          if (logCtrl.text.isNotEmpty) {
                            challengeCtrl.addDailyLog(challenge.id, logCtrl.text, logDate: selectedLogDate);
                            logCtrl.clear();
                            // Reset date to today after logging
                            setState(() {
                              selectedLogDate = DateTime.now();
                            });
                          }
                        },
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
