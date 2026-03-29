import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/study_watch_controller.dart';
import '../screens/study_stopwatch_screen.dart';

class StudyStopwatchCard extends StatelessWidget {
  const StudyStopwatchCard({
    super.key,
    this.title = 'Study Stopwatch',
    this.subtitle = 'Open full screen watch for your study session',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final studyWatchCtrl = Get.find<StudyWatchController>();

    return Obx(() {
      final isRunning = studyWatchCtrl.isRunning.value;
      final recentLogs = studyWatchCtrl.recentDailyLogs.take(3).toList();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4350).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.timer_rounded,
                    size: 34,
                    color: Color(0xFF1D4350),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isRunning
                        ? const Color(0xFF11998E).withValues(alpha: 0.12)
                        : const Color(0xFF718096).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isRunning ? 'Running' : 'Ready',
                    style: TextStyle(
                      color: isRunning
                          ? const Color(0xFF11998E)
                          : const Color(0xFF4A5568),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _summaryTile(
                    title: 'Today',
                    value: studyWatchCtrl.formatDuration(
                      studyWatchCtrl.todayStudyMilliseconds,
                    ),
                    color: const Color(0xFF11998E),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryTile(
                    title: 'All Time',
                    value: studyWatchCtrl.formatDuration(
                      studyWatchCtrl.totalStudyMilliseconds,
                    ),
                    color: const Color(0xFF2575FC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.to(
                () => const StudyStopwatchScreen(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 300),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4350),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                isRunning ? Icons.open_in_full_rounded : Icons.play_circle_fill_rounded,
              ),
              label: Text(
                isRunning ? 'Open Running Stopwatch' : 'Open Stopwatch',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (recentLogs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Daily study data yahan save hota rahega. Stopwatch kholkar study start karo.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Study Log',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...recentLogs.map((log) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dateLabel(log.endedAt),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Text(
                              studyWatchCtrl.formatDuration(
                                log.durationMilliseconds,
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _summaryTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C),
            ),
          ),
        ],
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

