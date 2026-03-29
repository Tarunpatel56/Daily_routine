import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/routine_controller.dart';
import 'controllers/timetable_controller.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'bindings/initial_binding.dart';
import 'views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  Get.put(NotificationService(), permanent: true);

  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future<void>.delayed(const Duration(milliseconds: 300), () async {
      final notificationService = Get.find<NotificationService>();
      await notificationService.init();
      await notificationService.requestPermissions();

      if (Get.isRegistered<RoutineController>()) {
        Get.find<RoutineController>().rescheduleNotifications();
      }

      if (Get.isRegistered<TimetableController>()) {
        Get.find<TimetableController>().rescheduleNotifications();
      }
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Daily Routine',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF), brightness: Brightness.light),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),
      initialBinding: InitialBinding(),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
