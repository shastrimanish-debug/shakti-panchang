import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart' as intl;
import 'screens/book_home_screen.dart';
import 'config/app_config.dart';
import 'utils/app_theme.dart';
import 'services/reminder_service.dart';
import 'services/premium_billing_service.dart';
import 'services/license_service.dart';
import 'services/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await intl.initializeDateFormatting('hi_IN');
  await intl.initializeDateFormatting('en_US');
  await intl.initializeDateFormatting('gu_IN');
  await AppSettings.instance.load();
  runApp(const ShaktiPanchangApp());
  unawaited(ReminderService.instance.init());
  unawaited(LicenseService.instance.init());
  unawaited(PremiumBillingService.instance.init());
}

class ShaktiPanchangApp extends StatefulWidget {
  const ShaktiPanchangApp({super.key});
  @override
  State<ShaktiPanchangApp> createState() => _ShaktiPanchangAppState();
}

class _ShaktiPanchangAppState extends State<ShaktiPanchangApp> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) => MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppSettings.instance.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('hi', 'IN'), Locale('en', 'US'), Locale('gu', 'IN')],
      locale: AppSettings.instance.locale,
      home: const BookHomeScreen(),
      onGenerateRoute: (settings) => null,
    ),
    );
  }
}
