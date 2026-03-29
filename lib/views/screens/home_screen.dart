import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/routine_controller.dart';
import '../../controllers/challenge_controller.dart';
import '../../controllers/target_controller.dart';
import '../../controllers/timetable_controller.dart';
import 'add_routine_screen.dart';
import 'targets_screen.dart';
import 'challenges_screen.dart';
import 'timetable_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/study_stopwatch_card.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  RoutineController get routineCtrl => Get.find<RoutineController>();
  ChallengeController get challengeCtrl => Get.find<ChallengeController>();
  TargetController get targetCtrl => Get.find<TargetController>();
  TimetableController get timetableCtrl => Get.find<TimetableController>();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting
                  const Text("Hello, Scholar! 📚", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                  const SizedBox(height: 5),
                  Text("${DateFormat.yMMMMEEEEd().format(DateTime.now())}", style: const TextStyle(fontSize: 14, color: Colors.black45)),
                  const SizedBox(height: 5),
                  const Text("Ready to crush your goals today?", style: TextStyle(fontSize: 16, color: Colors.black54)),

                  const SizedBox(height: 20),

                  const StudyStopwatchCard(
                    title: 'Study Stopwatch',
                    subtitle: 'Full-screen landscape stopwatch yahan se kholo',
                  ),

                  const SizedBox(height: 25),

                  // Stats Row
                  Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildStatChip("🔁 ${routineCtrl.routines.length}", "Routines"),
                      _buildStatChip("🎯 ${targetCtrl.targets.length}", "Targets"),
                      _buildStatChip("🔥 ${challengeCtrl.challenges.length}", "Challenges"),
                      _buildStatChip("🕐 ${timetableCtrl.entries.length}", "Schedule"),
                    ],
                  )),

                  // Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.05,
                    children: [
                      _buildDashboardCard("Routines", "Daily habits", Icons.repeat, const [Color(0xFF6A11CB), Color(0xFF2575FC)], () {
                        Get.to(() => AddRoutineScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 350));
                      }),
                      _buildDashboardCard("Targets", "Study goals", Icons.flag, const [Color(0xFFFF512F), Color(0xFFDD2476)], () => Get.to(() => TargetsScreen(), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 350))),
                      _buildDashboardCard("Challenges", "Push limits", Icons.star, const [Color(0xFF11998E), Color(0xFF38EF7D)], () => Get.to(() => ChallengesScreen(), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 350))),
                      _buildDashboardCard("Timetable", "Your schedule", Icons.schedule, const [Color(0xFFF2994A), Color(0xFFF2C94C)], () => Get.to(() => TimetableScreen(), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 350))),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Routines Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Today's Routines", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                      TextButton.icon(
                        onPressed: () => Get.to(() => AddRoutineScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 350)),
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF6C63FF), size: 20),
                        label: const Text("Add", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (routineCtrl.routines.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(30),
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))]),
                        child: const Column(
                          children: [
                            Icon(Icons.wb_sunny_outlined, size: 56, color: Color(0xFF6C63FF)),
                            SizedBox(height: 12),
                            Text("No routines yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                            SizedBox(height: 5),
                            Text("Tap + above to plan your day!", style: TextStyle(color: Colors.black38)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: routineCtrl.routines.length,
                      itemBuilder: (context, index) {
                        var routine = routineCtrl.routines[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [BoxShadow(color: routine.isCompleted ? Colors.green.withOpacity(0.1) : Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                            border: Border.all(color: routine.isCompleted ? Colors.green.withOpacity(0.3) : Colors.transparent, width: 1.5),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: GestureDetector(
                              onTap: () => routineCtrl.toggleRoutineCompletion(routine.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: routine.isCompleted ? Colors.green.withOpacity(0.15) : const Color(0xFF6C63FF).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  routine.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: routine.isCompleted ? Colors.green : const Color(0xFF6C63FF),
                                  size: 26,
                                ),
                              ),
                            ),
                            title: Text(
                              routine.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
                                color: routine.isCompleted ? Colors.black38 : Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time_filled, size: 14, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Text(DateFormat.jm().format(routine.date), style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                                  if (routine.description.isNotEmpty) ...[
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(routine.description, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
                                  ]
                                ],
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                              onPressed: () => routineCtrl.deleteRoutine(routine.id),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddRoutineScreen(), transition: Transition.downToUp, duration: const Duration(milliseconds: 350)),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Routine", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 6,
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, IconData icon, List<Color> gradientColors, VoidCallback onTap) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white24,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(color: gradientColors[1].withOpacity(0.4), blurRadius: 12, offset: const Offset(2, 6))
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: Colors.white, radius: 32, child: Icon(Icons.school, size: 36, color: Color(0xFF6A11CB))),
                SizedBox(height: 12),
                Text('Study Hub', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Stay focused, stay ahead', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _drawerItem(Icons.dashboard, "Dashboard", const Color(0xFF6C63FF), () { Get.back(); }),
          _drawerItem(Icons.flag, "Study Targets", const Color(0xFFFF512F), () { Get.back(); Get.to(() => TargetsScreen(), transition: Transition.rightToLeftWithFade); }),
          _drawerItem(Icons.star, "My Challenges", const Color(0xFF11998E), () { Get.back(); Get.to(() => ChallengesScreen(), transition: Transition.rightToLeftWithFade); }),
          _drawerItem(Icons.schedule, "Timetable", const Color(0xFFF2994A), () { Get.back(); Get.to(() => TimetableScreen(), transition: Transition.rightToLeftWithFade); }),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Study Hub v1.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}






