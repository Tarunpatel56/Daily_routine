import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/challenge_controller.dart';

class AddChallengeScreen extends StatefulWidget {
  @override
  _AddChallengeScreenState createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final daysCtrl = TextEditingController(text: "90");
  DateTime selectedStartDate = DateTime.now();

  final ChallengeController challengeCtrl = Get.find<ChallengeController>();

  void _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF11998E))), child: child!),
    );
    if (picked != null) setState(() => selectedStartDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(title: const Text('New Challenge 🏆', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Challenge yourself! 💪", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(labelText: 'Challenge Name (e.g. 90 Days DSA)', prefixIcon: const Icon(Icons.emoji_events, color: Color(0xFF11998E)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true, fillColor: Colors.grey.shade50),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      decoration: InputDecoration(labelText: 'What do you want to achieve?', prefixIcon: const Icon(Icons.description, color: Color(0xFF11998E)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true, fillColor: Colors.grey.shade50),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: daysCtrl,
                      decoration: InputDecoration(labelText: 'Total Days', prefixIcon: const Icon(Icons.calendar_month, color: Color(0xFF11998E)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), filled: true, fillColor: Colors.grey.shade50),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: const Color(0xFF11998E).withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF11998E).withOpacity(0.3))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Start Date", style: TextStyle(color: Colors.black54, fontSize: 12)),
                              Text(DateFormat.yMMMd().format(selectedStartDate), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF11998E))),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickStartDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: const Text('Change'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF11998E), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF11998E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty && daysCtrl.text.isNotEmpty) {
                          challengeCtrl.addChallenge(titleCtrl.text, descCtrl.text, int.tryParse(daysCtrl.text) ?? 90, startDate: selectedStartDate);
                          Get.back();
                          Get.snackbar('Challenge Started! 🔥', 'Let\'s go!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
                        }
                      },
                      child: const Text('🚀 Start Challenge', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    )
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
