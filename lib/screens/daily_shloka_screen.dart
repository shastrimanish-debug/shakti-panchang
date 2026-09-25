import 'package:flutter/material.dart';
import '../data/daily_shloka_data.dart';

class DailyShlokaScreen extends StatelessWidget {
  const DailyShlokaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DailyShlokaData.forDate(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('आज का श्लोक')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF8E7),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('आज का श्लोक', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
                  const SizedBox(height: 10),
                  Text(today.sanskrit, style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Text(today.hindi, style: const TextStyle(height: 1.45)),
                  const SizedBox(height: 8),
                  Text(today.source, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('संग्रह', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 8),
          ...DailyShlokaData.shlokas.map((s) => Card(
                child: ListTile(
                  title: Text(s.sanskrit, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(s.source),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(s.source),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.sanskrit, style: const TextStyle(fontWeight: FontWeight.w800, height: 1.45)),
                            const SizedBox(height: 10),
                            Text(s.hindi),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
