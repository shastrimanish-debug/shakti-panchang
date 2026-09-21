import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/muhurat_engine.dart';
import '../services/disha_service.dart';

class MuhuratScreen extends StatefulWidget {
  final SolarTimes solar;
  final DateTime date;

  const MuhuratScreen({
    super.key,
    required this.solar,
    required this.date,
  });

  @override
  State<MuhuratScreen> createState() => _MuhuratScreenState();
}

class _MuhuratScreenState extends State<MuhuratScreen> {
  MuhuratActivity activity = MuhuratActivity.general;
  final engine = MuhuratEngine();
  int tab = 0;

  String label(MuhuratActivity a) => switch (a) {
        MuhuratActivity.general => 'सामान्य शुभ कार्य',
        MuhuratActivity.travel => 'यात्रा',
        MuhuratActivity.business => 'नया व्यापार',
        MuhuratActivity.vehiclePurchase => 'वाहन खरीद',
        MuhuratActivity.property => 'भूमि / प्रॉपर्टी',
        MuhuratActivity.houseEntry => 'गृह प्रवेश',
        MuhuratActivity.education => 'शिक्षा / अध्ययन',
        MuhuratActivity.naming => 'नामकरण',
        MuhuratActivity.marriage => 'विवाह',
      };

  @override
  Widget build(BuildContext context) {
    final daily = engine.dailyNamed(solar: widget.solar, weekday: widget.date.weekday);
    final work = engine.forActivity(
      activity: activity,
      solar: widget.solar,
      weekday: widget.date.weekday,
    );
    final shool = DishaService.avoided(widget.date);
    final tyajyaTitles = {'राहु काल', 'यमगण्ड', 'गुलिक काल', 'निशीथ काल'};

    return Scaffold(
      appBar: AppBar(title: const Text('आज के वैदिक मुहूर्त')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _tabBtn(0, 'आज के मुहूर्त'),
              const SizedBox(width: 8),
              _tabBtn(1, 'कार्य अनुसार'),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFF4DC),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'दिशाशूल आज: $shool दिशा। सूर्योदय ${_fmt(widget.solar.sunrise)} · सूर्यास्त ${_fmt(widget.solar.sunset)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (tab == 0)
            ...daily.map((m) => _row(m, tyajyaTitles.contains(m.title)))
          else ...[
            DropdownButtonFormField<MuhuratActivity>(
              initialValue: activity,
              decoration: const InputDecoration(
                labelText: 'किस काम के लिए?',
                border: OutlineInputBorder(),
              ),
              items: MuhuratActivity.values
                  .map((a) => DropdownMenuItem(value: a, child: Text(label(a))))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => activity = v);
              },
            ),
            const SizedBox(height: 12),
            ...work.map((m) => _row(m, tyajyaTitles.contains(m.title))),
          ],
        ],
      ),
    );
  }

  Widget _tabBtn(int i, String text) {
    final on = tab == i;
    return Expanded(
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: on ? const Color(0xFF5C3A21) : const Color(0xFFF4E8D1),
          foregroundColor: on ? Colors.white : const Color(0xFF5C3A21),
        ),
        onPressed: () => setState(() => tab = i),
        child: Text(text),
      ),
    );
  }

  Widget _row(MuhuratWindow m, bool tyajya) {
    return Card(
      color: tyajya ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
      child: ListTile(
        title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(m.description),
        trailing: Text(
          m.start == m.end ? _fmt(m.start) : '${_fmt(m.start)}–${_fmt(m.end)}',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
