import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'screens/book_home_screen.dart';
import 'config/app_config.dart';
import 'services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await intl.initializeDateFormatting('hi_IN');
  runApp(const ShaktiPanchangApp());
  unawaited(ReminderService.instance.init());
}

class ShaktiPanchangApp extends StatelessWidget {
  const ShaktiPanchangApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFB56A00),
        scaffoldBackgroundColor: const Color(0xFFFFFBF4),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
      ),
      home: const BookHomeScreen(),
    );
  }
}
