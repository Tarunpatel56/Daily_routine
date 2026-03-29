import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/study_watch_controller.dart';

class StudyStopwatchScreen extends StatefulWidget {
  const StudyStopwatchScreen({super.key});

  @override
  State<StudyStopwatchScreen> createState() => _StudyStopwatchScreenState();
}

class _StudyStopwatchScreenState extends State<StudyStopwatchScreen> {
  StudyWatchController get studyWatchCtrl => Get.find<StudyWatchController>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06141F),
      body: SafeArea(
        child: Obx(() {
          final isRunning = studyWatchCtrl.isRunning.value;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Stopwatch',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Landscape full-screen focus timer',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: Get.back,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: Text(
                          studyWatchCtrl.formattedElapsed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          isRunning
                              ? 'Study chal rahi hai'
                              : 'Start dabao aur study shuru karo',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (isRunning) {
                                  final savedLog = studyWatchCtrl.pause();
                                  if (savedLog != null) {
                                    Get.snackbar(
                                      'Daily Log Updated',
                                      'Aaj ka total ${studyWatchCtrl.formatDuration(savedLog.durationMilliseconds)} par update hua.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.white,
                                    );
                                  }
                                } else {
                                  studyWatchCtrl.start();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isRunning
                                    ? const Color(0xFFDD2476)
                                    : const Color(0xFF11998E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Icon(
                                isRunning
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              label: Text(
                                isRunning ? 'Stop & Save' : 'Start',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _showSetTimeDialog,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.alarm_rounded),
                              label: const Text(
                                'Set Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: studyWatchCtrl.reset,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text(
                                'Reset',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Study Data',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _summaryTile(
                        'Today',
                        studyWatchCtrl.formatDuration(
                          studyWatchCtrl.todayStudyMilliseconds,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _summaryTile(
                        'All Time',
                        studyWatchCtrl.formatDuration(
                          studyWatchCtrl.totalStudyMilliseconds,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Per Day Log',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: studyWatchCtrl.recentDailyLogs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Abhi tak daily log save nahi hua.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    studyWatchCtrl.recentDailyLogs.length,
                                itemBuilder: (context, index) {
                                  final log =
                                      studyWatchCtrl.recentDailyLogs[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.06),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _dateLabel(log.endedAt),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          studyWatchCtrl.formatDuration(
                                            log.durationMilliseconds,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _summaryTile(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSetTimeDialog() {
    final elapsed = studyWatchCtrl.elapsedMilliseconds.value ~/ 1000;
    final hourCtrl = TextEditingController(text: (elapsed ~/ 3600).toString());
    final minuteCtrl =
        TextEditingController(text: ((elapsed % 3600) ~/ 60).toString());
    final secondCtrl = TextEditingController(text: (elapsed % 60).toString());

    Get.dialog(
      AlertDialog(
        title: const Text('Set Study Watch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Yahan se stopwatch ka starting time set kar sakte ho.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _timeInputField(hourCtrl, 'Hours')),
                const SizedBox(width: 10),
                Expanded(child: _timeInputField(minuteCtrl, 'Minutes')),
                const SizedBox(width: 10),
                Expanded(child: _timeInputField(secondCtrl, 'Seconds')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final hours = int.tryParse(hourCtrl.text) ?? 0;
              final minutes = int.tryParse(minuteCtrl.text) ?? 0;
              final seconds = int.tryParse(secondCtrl.text) ?? 0;

              if (hours < 0 ||
                  minutes < 0 ||
                  seconds < 0 ||
                  minutes > 59 ||
                  seconds > 59) {
                Get.snackbar(
                  'Invalid time',
                  'Minutes aur seconds 0 se 59 ke beech hone chahiye.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              studyWatchCtrl.setElapsed(
                Duration(
                  hours: hours,
                  minutes: minutes,
                  seconds: seconds,
                ),
              );
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _timeInputField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }
}

