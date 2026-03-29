import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/timetable_controller.dart';
import 'add_timetable_entry_screen.dart';
import 'study_stopwatch_screen.dart';
import '../widgets/study_stopwatch_card.dart';

class TimetableScreen extends StatefulWidget {
  TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  TimetableController get timetableCtrl => Get.find<TimetableController>();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  final List<Color> _slotColors = const [
    Color(0xFF6A11CB),
    Color(0xFFFF512F),
    Color(0xFF11998E),
    Color(0xFFF2994A),
    Color(0xFF2575FC),
    Color(0xFFDD2476),
    Color(0xFF38EF7D),
    Color(0xFFF2C94C),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('Study Timetable 📖', style: TextStyle(fontWeight: FontWeight.bold))),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Obx(() {
          if (timetableCtrl.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text("No subjects scheduled", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  const Text("Add your subjects with time\nto create your daily study plan!", textAlign: TextAlign.center, style: TextStyle(color: Colors.black38)),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => Get.to(() => AddTimetableEntryScreen(), transition: Transition.downToUp),
                    icon: const Icon(Icons.add_circle, color: Color(0xFFF2994A)),
                    label: const Text("Add First Subject", style: TextStyle(fontSize: 16, color: Color(0xFFF2994A), fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const StudyStopwatchScreen(), transition: Transition.rightToLeftWithFade),
                    icon: const Icon(Icons.timer_rounded, color: Color(0xFF1D4350)),
                    label: const Text("Open Stopwatch", style: TextStyle(fontSize: 16, color: Color(0xFF1D4350), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: StudyStopwatchCard(
                  title: 'Study Stopwatch',
                  subtitle: 'Full-screen landscape stopwatch yahan se kholo',
                ),
              ),
              // Summary bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFF2994A), Color(0xFFF2C94C)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("📚 ${timetableCtrl.entries.length} Subjects", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text("Your Daily Plan", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: timetableCtrl.entries.length,
                  itemBuilder: (context, index) {
                    var entry = timetableCtrl.entries[index];
                    Color accentColor = _slotColors[index % _slotColors.length];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                        border: Border(left: BorderSide(color: accentColor, width: 5)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(color: accentColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(entry.startTime.format(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor)),
                              Text("-", style: TextStyle(fontSize: 8, color: Colors.grey.shade400)),
                              Text(entry.endTime.format(context), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: accentColor)),
                            ],
                          ),
                        ),
                        title: Text(entry.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => timetableCtrl.deleteEntry(entry.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddTimetableEntryScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 350)),
        backgroundColor: const Color(0xFFF2994A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Subject", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}


