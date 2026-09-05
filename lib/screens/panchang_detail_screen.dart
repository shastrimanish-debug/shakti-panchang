import 'package:flutter/material.dart';
import '../models/vedic_panchang.dart';

class PanchangDetailScreen extends StatelessWidget {
  final VedicPanchang data;
  final DateTime date;

  const PanchangDetailScreen({super.key, required this.data, required this.date});

  Widget row(String title, String value, IconData icon) => Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      trailing: Text(value, textAlign: TextAlign.right),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📜 पूरा पंचांग')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'पंचांग — ${date.day}/${date.month}/${date.year}',
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          row('वार', data.weekday, Icons.today),
          row('पक्ष', data.paksha, Icons.brightness_6),
          row('मास', data.masa, Icons.calendar_month),
          row('तिथि', data.tithi, Icons.event_note),
          row('नक्षत्र', data.nakshatra, Icons.star),
          row('योग', data.yoga, Icons.auto_awesome),
          row('करण', data.karana, Icons.timelapse),
          row('संवत', data.samvat, Icons.history),
          row('अयनांश', data.ayanamsha, Icons.explore),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '⚠️ ${data.calculationNote}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
