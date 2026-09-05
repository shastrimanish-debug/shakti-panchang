import 'package:flutter/material.dart';
import 'festivals_screen.dart';
import 'locations_screen.dart';
import 'reminder_screen.dart';
import 'kundali_screen.dart';

class ToolsScreen extends StatelessWidget {
  final DateTime date;
  const ToolsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('✨ Shakti Panchang Tools')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _tile(context, Icons.auto_awesome, 'जन्म कुंडली', 'Lahiri • लग्न • ग्रह • भाव • दशा', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KundaliScreen()))),
        _tile(context, Icons.event_note, 'पर्व और व्रत',
          'एकादशी, पूर्णिमा, अमावस्या और प्रमुख पर्व',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => FestivalsScreen(date: date)))),
        _tile(context, Icons.location_on, 'मेरे स्थान',
          'Vadodara, Mumbai, Burhanpur आदि सेव करें',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationsScreen()))),
        _tile(context, Icons.notifications_active, 'उमा Reminder',
          'शुभ समय या यात्रा का समय याद रखें',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()))),
      ],
    ),
  );

  Widget _tile(BuildContext context, IconData icon, String title, String sub, VoidCallback tap) =>
      Card(child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(sub),
        trailing: const Icon(Icons.chevron_right),
        onTap: tap,
      ));
}
