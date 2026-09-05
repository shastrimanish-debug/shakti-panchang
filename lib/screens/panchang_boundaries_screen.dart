import 'package:flutter/material.dart';
import '../models/panchang_boundaries.dart';

class PanchangBoundariesScreen extends StatelessWidget {
  final DailyPanchangBoundaries data;
  const PanchangBoundariesScreen({super.key, required this.data});

  String f(DateTime x) =>
      '${x.day.toString().padLeft(2,'0')}/${x.month.toString().padLeft(2,'0')} '
      '${x.hour.toString().padLeft(2,'0')}:${x.minute.toString().padLeft(2,'0')}';

  Widget card(String title, PanchangBoundary b) => Card(
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.schedule)),
      title: Text('$title: ${b.currentName}',
          style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text('आरंभ: ${f(b.start)}\nसमाप्ति: ${f(b.end)}\nअगला: ${b.nextName}'),
      trailing: Text('${(b.progress * 100).round()}%'),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('⏱️ तिथि परिवर्तन समय')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        card('तिथि', data.tithi),
        card('नक्षत्र', data.nakshatra),
        card('योग', data.yoga),
        card('करण', data.karana),
        const SizedBox(height: 12),
        const Text(
          'इन समयों का उपयोग Choghadiya/Muhurat filtering में किया जा सकता है। '
          'Final production validation में timezone/DST और local sunrise boundary भी cross-check होगी।',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    ),
  );
}
