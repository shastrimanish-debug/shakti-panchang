import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/festival_service.dart';

class FestivalsScreen extends StatelessWidget {
  final DateTime date;
  const FestivalsScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, d MMMM yyyy', 'hi_IN');
    final upcoming = FestivalService.upcoming(date, count: 12);
    final yearItems = FestivalService.forYear(date.year);

    return Scaffold(
      appBar: AppBar(title: const Text('हिंदी त्योहार तिथियाँ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('आगामी पर्व', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...upcoming.map((x) => Card(
            color: const Color(0xFFFFF4DC),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFB56A00),
                child: Text('${x.date.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
              title: Text(x.name, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('${fmt.format(x.date)} • ${x.type}'),
            ),
          )),
          const SizedBox(height: 16),
          Text('${date.year} की पूरी सूची', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...yearItems.map((x) => Card(
            child: ListTile(
              dense: true,
              title: Text(x.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              trailing: Text(
                DateFormat('d MMM', 'hi_IN').format(x.date),
                style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF8C6239)),
              ),
              subtitle: Text(x.type),
            ),
          )),
        ],
      ),
    );
  }
}
