import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/timetable_controller.dart';

class AddTimetableEntryScreen extends StatefulWidget {
  @override
  _AddTimetableEntryScreenState createState() => _AddTimetableEntryScreenState();
}

class _AddTimetableEntryScreenState extends State<AddTimetableEntryScreen> {
  final subjectCtrl = TextEditingController();
  final topicCtrl = TextEditingController();
  TimeOfDay? selectedStart;
  TimeOfDay? selectedEnd;

  final TimetableController timetableCtrl = Get.find<TimetableController>();

  void _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFF2994A))), child: child!),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedStart = picked;
          selectedEnd ??= picked;
        } else {
          selectedEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('Add Study Slot', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Study Schedule 📖", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              const SizedBox(height: 5),
              const Text("Add your subjects with time to plan your full day", style: TextStyle(fontSize: 14, color: Colors.black45)),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: subjectCtrl,
                      decoration: InputDecoration(
                        labelText: 'Subject Name',
                        hintText: 'e.g. Mathematics, Physics, English',
                        prefixIcon: const Icon(Icons.menu_book, color: Color(0xFFF2994A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: topicCtrl,
                      decoration: InputDecoration(
                        labelText: 'Topic / Chapter (Optional)',
                        hintText: 'e.g. Chapter 5 - Trigonometry',
                        prefixIcon: const Icon(Icons.topic, color: Color(0xFFF2994A)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2994A).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF2994A).withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.play_circle_outline, color: Color(0xFFF2994A)),
                                  const SizedBox(height: 4),
                                  const Text("Start Time", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  Text(
                                    selectedStart == null ? "Tap to set" : selectedStart!.format(context),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: selectedStart == null ? Colors.grey : const Color(0xFFF2994A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDD2476).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFDD2476).withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.stop_circle_outlined, color: Color(0xFFDD2476)),
                                  const SizedBox(height: 4),
                                  const Text("End Time", style: TextStyle(color: Colors.black54, fontSize: 12)),
                                  Text(
                                    selectedEnd == null ? "Tap to set" : selectedEnd!.format(context),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: selectedEnd == null ? Colors.grey : const Color(0xFFDD2476)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2994A),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (subjectCtrl.text.isNotEmpty && selectedStart != null && selectedEnd != null) {
                          String title = subjectCtrl.text;
                          if (topicCtrl.text.isNotEmpty) {
                            title = "$title - ${topicCtrl.text}";
                          }
                          timetableCtrl.addEntry(title, selectedStart!, selectedEnd!);
                          Get.back();
                          Get.snackbar('Subject Added! 📚', '${subjectCtrl.text} scheduled', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
                        } else {
                          Get.snackbar('Missing Info', 'Subject name and time required', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      },
                      child: const Text('📅 Add to Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("💡 Tips", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text("• Add subjects one by one with their time", style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Text("• Math, Physics, Chemistry etc. sab alag alag add karo", style: TextStyle(color: Colors.black54, fontSize: 13)),
                    Text("• Break time bhi add kar sakte ho!", style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
