import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_colors.dart';
import 'core/services/notification_service.dart';
import 'data/models/ai_usage_log.dart';
import 'data/models/user_settings.dart';
import 'features/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(AiUsageLogAdapter());
  Hive.registerAdapter(UserSettingsAdapter());
  await Hive.openBox<AiUsageLog>('ai_usage_logs');
  await Hive.openBox<UserSettings>('user_settings');

  await NotificationService().init(); // Initialize notification service

  runApp(const ProviderScope(child: EcoAiTrackerApp()));
}

class EcoAiTrackerApp extends StatelessWidget {
  const EcoAiTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-AI Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        fontFamily: 'Inter',
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.textHighEmphasis,
          displayColor: AppColors.textHighEmphasis,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}