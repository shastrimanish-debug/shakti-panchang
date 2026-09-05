import 'package:flutter/material.dart';
import '../services/festival_service.dart';

class FestivalsScreen extends StatelessWidget {
  final DateTime date;
  const FestivalsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final items = FestivalService.upcoming(date, count: 20);
    return Scaffold(
      appBar: AppBar(title: const Text('📅 पर्व और व्रत')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'एकादशी, पूर्णिमा, अमावस्या और प्रमुख पर्व एक जगह। '
                'विशेष व्रत/पूजा के exact समय के लिए चुनी हुई location के पंचांग नियम देखें।',
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((x) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.event)),
              title: Text(x.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${x.date.day.toString().padLeft(2,'0')}-${x.date.month.toString().padLeft(2,'0')}-${x.date.year} • ${x.type}'),
            ),
          )),
          const SizedBox(height: 18),
          const Text(
            '2026 calendar data is based on a location-specific Hindu calendar reference; '
            'lunar observances can differ by location and tradition.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
