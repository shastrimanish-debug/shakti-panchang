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

  Future<void> _locale(Locale? value) async {
    if (value == null) return;
    await AppSettings.instance.setLocale(value);
    if (mounted) setState(() {});
  }

  Future<void> _theme(ThemeMode? value) async {
    if (value == null) return;
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
          Card(
            child: Column(
              children: [
                RadioListTile<Locale>.adaptive(
                  value: const Locale('hi', 'IN'),
                  groupValue: locale,
                  title: const Text('हिन्दी'),
                  onChanged: _locale,
                ),
                RadioListTile<Locale>.adaptive(
                  value: const Locale('en', 'US'),
                  groupValue: locale,
                  title: const Text('English'),
                  onChanged: _locale,
                ),
                RadioListTile<Locale>.adaptive(
                  value: const Locale('gu', 'IN'),
                  groupValue: locale,
                  title: const Text('ગુજરાતી'),
                  onChanged: _locale,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>.adaptive(
                  value: ThemeMode.light,
                  groupValue: theme,
                  title: const Text('Light'),
                  onChanged: _theme,
                ),
                RadioListTile<ThemeMode>.adaptive(
                  value: ThemeMode.dark,
                  groupValue: theme,
                  title: const Text('Dark'),
                  onChanged: _theme,
                ),
                RadioListTile<ThemeMode>.adaptive(
                  value: ThemeMode.system,
                  groupValue: theme,
                  title: const Text('System default'),
                  onChanged: _theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Shakti Panchang'),
            subtitle: Text('Language and appearance preferences are saved on this device.'),
          ),
        ],
      ),
    );
  }
}
