import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/choghadiya_service.dart';
import '../services/disha_service.dart';
import '../services/inauspicious_service.dart';
import 'shubh_samay_screen.dart';
import '../services/panchang_boundary_service.dart';
import '../services/xalen_service.dart';

class ChoghadiyaScreen extends StatelessWidget {
  final SolarTimes solar;
  final DateTime date;
  const ChoghadiyaScreen({super.key, required this.solar, required this.date});

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final day = ChoghadiyaService.day(solar, date.weekday);
    final night = ChoghadiyaService.night(solar, date.weekday);
    final bad = InauspiciousService.daytime(solar.sunrise, solar.sunset, date.weekday);
    final shool = DishaService.avoided(date);

    return Scaffold(
      appBar: AppBar(title: const Text('चौघड़िया • राहुकाल')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF4DC),
            child: ListTile(
              title: Text('दिशाशूल: $shool', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('सूर्योदय ${_hm(solar.sunrise)}  सूर्यास्त ${_hm(solar.sunset)}'),
            ),
          ),
          const SizedBox(height: 8),
          const Text('त्याज्य काल', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ...bad.map((w) => Card(
                color: const Color(0xFFFFEBEE),
                child: ListTile(
                  title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  trailing: Text('${_hm(w.start)}–${_hm(w.end)}'),
                  subtitle: Text(w.description),
                ),
              )),
          const SizedBox(height: 12),
          const Text('दिन चौघड़िया', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ...day.map(_row),
          const SizedBox(height: 12),
          const Text('रात्रि चौघड़िया', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ...night.map(_row),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final p = await PanchangBoundaryService(AstronomyEngineService()).calculate(date);
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShubhSamayScreen(date: date, panchang: p, dishaShool: shool),
                ),
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('कार्य अनुसार शुभ समय'),
          ),
        ],
      ),
    );
  }

  Widget _row(ChoghadiyaPeriod c) {
    final bad = c.nature == ChoghadiyaNature.inauspicious;
    return Card(
      color: bad ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
      child: ListTile(
        dense: true,
        title: Text('${c.name} — ${c.meaning}', style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: Text('${_hm(c.start)}–${_hm(c.end)}', style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}
