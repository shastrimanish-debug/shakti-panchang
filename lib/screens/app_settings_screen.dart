import 'package:flutter/material.dart';
import '../services/app_settings.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});
  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  Locale get locale => AppSettings.instance.locale;
  ThemeMode get theme => AppSettings.instance.themeMode;

  Future<void> _locale(Locale value) async {
    await AppSettings.instance.setLocale(value);
    if (mounted) setState(() {});
  }

  Future<void> _theme(ThemeMode value) async {
    await AppSettings.instance.setThemeMode(value);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(child: Column(children: [
            RadioListTile<Locale>(value: const Locale('hi', 'IN'), groupValue: locale, title: const Text('हिन्दी'), onChanged: (v) => v == null ? null : _locale(v)),
            RadioListTile<Locale>(value: const Locale('en', 'US'), groupValue: locale, title: const Text('English'), onChanged: (v) => v == null ? null : _locale(v)),
            RadioListTile<Locale>(value: const Locale('gu', 'IN'), groupValue: locale, title: const Text('ગુજરાતી'), onChanged: (v) => v == null ? null : _locale(v)),
          ])),
          const SizedBox(height: 20),
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(child: Column(children: [
            RadioListTile<ThemeMode>(value: ThemeMode.light, groupValue: theme, title: const Text('Light'), onChanged: (v) => v == null ? null : _theme(v)),
            RadioListTile<ThemeMode>(value: ThemeMode.dark, groupValue: theme, title: const Text('Dark'), onChanged: (v) => v == null ? null : _theme(v)),
            RadioListTile<ThemeMode>(value: ThemeMode.system, groupValue: theme, title: const Text('System default'), onChanged: (v) => v == null ? null : _theme(v)),
          ])),
          const SizedBox(height: 20),
          const ListTile(leading: Icon(Icons.info_outline), title: Text('Shakti Panchang'), subtitle: Text('Language and appearance preferences are saved on this device.')),
        ],
      ),
    );
  }
}
