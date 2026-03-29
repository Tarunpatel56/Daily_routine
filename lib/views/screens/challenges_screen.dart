import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/challenge_controller.dart';
import 'add_challenge_screen.dart';
import 'challenge_detail_screen.dart';

class ChallengesScreen extends StatefulWidget {
  ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with SingleTickerProviderStateMixin {
  ChallengeController get challengeCtrl => Get.find<ChallengeController>();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('My Challenges 🔥', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Obx(() {
          if (challengeCtrl.challenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                  const SizedBox(height: 16),
                  const Text("No active challenges", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Get.to(() => AddChallengeScreen(), transition: Transition.downToUp),
                    child: const Text("Start your first challenge!", style: TextStyle(fontSize: 16, color: Color(0xFF11998E), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challengeCtrl.challenges.length,
            itemBuilder: (context, index) {
              var challenge = challengeCtrl.challenges[index];
              double progress = challenge.totalDays > 0 ? (challenge.daysElapsed / challenge.totalDays).clamp(0.0, 1.0) : 0;

              return GestureDetector(
                onTap: () => Get.to(() => ChallengeDetailScreen(challengeId: challenge.id), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 350)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with gradient
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(challenge.description, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white70),
                              onPressed: () => challengeCtrl.deleteChallenge(challenge.id),
                            ),
                          ],
                        ),
                      ),
                      // Progress section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: const Color(0xFF11998E).withOpacity(0.15),
                                color: const Color(0xFF11998E),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statLabel("✅ Done", "${challenge.daysElapsed}", Colors.green),
                                _statLabel("⏳ Left", "${challenge.daysRemaining}", const Color(0xFF6C63FF)),
                                _statLabel("📊 Total", "${challenge.totalDays}", Colors.black54),
                                _statLabel("📝 Logs", "${challenge.logs.length}", Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddChallengeScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 350)),
        backgroundColor: const Color(0xFF11998E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Challenge", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _statLabel(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black45)),
      ],
    );
  }
}
