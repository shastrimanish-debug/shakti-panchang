import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/astronomical_panchang.dart';
import '../services/astronomical_panchang_service.dart';
import '../services/location_store.dart';
import '../widgets/moon_phase_chart.dart';

class MoonPhaseScreen extends StatefulWidget {
  const MoonPhaseScreen({super.key});

  @override
  State<MoonPhaseScreen> createState() => _MoonPhaseScreenState();
}

class _MoonPhaseScreenState extends State<MoonPhaseScreen> {
  AstronomicalPanchang? _data;
  String _place = 'उज्जैन';
  String? _error;
  DateTime _day = DateTime.now();
  bool _showCycle = true;

  static const _tithiNames = [
    'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पंचमी',
    'षष्ठी', 'सप्तमी', 'अष्टमी', 'नवमी', 'दशमी',
    'एकादशी', 'द्वादशी', 'त्रयोदशी', 'चतुर्दशी',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loc = await LocationStore().selected();
      final lat = loc?.latitude ?? 23.1765;
      final lon = loc?.longitude ?? 75.7885;
      final p = await AstronomicalPanchangService().calculate(
        date: _day,
        latitude: lat,
        longitude: lon,
      );
      if (!mounted) return;
      setState(() {
        _data = p;
        _place = loc?.name ?? 'उज्जैन';
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  double _elong(AstronomicalPanchang p) {
    var d = (p.lunarLongitude - p.solarLongitude) % 360;
    if (d < 0) d += 360;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final p = _data;
    final elong = p == null ? 0.0 : _elong(p);
    final illum = ((1 - math.cos(elong * math.pi / 180)) / 2).clamp(0.0, 1.0);
    final waxing = elong <= 180;
    final tithiNum = p?.tithiNumber ?? ((elong / 12).floor() + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('चन्द्र कला'),
        actions: [
          IconButton(
            tooltip: 'तिथि बदलें',
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: DateTime(_day.year - 1),
                lastDate: DateTime(_day.year + 1),
              );
              if (picked == null) return;
              setState(() {
                _day = picked;
                _data = null;
              });
              await _load();
            },
          ),
        ],
      ),
      body: p == null
          ? Center(child: _error == null ? const CircularProgressIndicator() : Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_day.day}-${_day.month}-${_day.year} • $_place',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text('दृक-सिद्ध सूर्य-चन्द्र कोणीय अंतर से वास्तविक कला'),
                const SizedBox(height: 12),
                MoonPhaseChart(
                  solarLongitude: p.solarLongitude,
                  lunarLongitude: p.lunarLongitude,
                  tithi: p.tithi,
                  paksha: p.paksha,
                  nakshatra: p.nakshatra,
                  lunarRashi: p.lunarRashiName,
                  tithiProgress: p.tithiProgress,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _metric('चन्द्र प्रकाश', '${(illum * 100).toStringAsFixed(1)}%', illum)),
                    const SizedBox(width: 8),
                    Expanded(child: _metric('सूर्य-चन्द्र अंतर', '${elong.toStringAsFixed(1)}°', (elong % 12) / 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(
                      '${waxing ? 'शुक्ल — वर्धमान' : 'कृष्ण — क्षीयमान'} • ${p.tithi}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      'राशि ${p.lunarRashiName} • नक्षत्र ${p.nakshatra} चरण ${p.nakshatraPada}\n'
                      'तिथि व्यतीत ${(p.tithiProgress.clamp(0, 1) * 100).round()}%  •  इस तिथि में ${(elong % 12).toStringAsFixed(1)}° / 12°',
                    ),
                    isThreeLine: true,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('३० तिथि महा-चक्र', style: TextStyle(fontWeight: FontWeight.w800)),
                  value: _showCycle,
                  onChanged: (v) => setState(() => _showCycle = v),
                ),
                if (_showCycle)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [for (var i = 1; i <= 30; i++) _tithiChip(i, tithiNum)],
                  ),
                const SizedBox(height: 12),
                const Text(
                  'तिथि सूर्य-चन्द्र अन्तर के प्रत्येक १२ अंश से बनती है। पूर्णिमा पर प्रकाश लगभग १००%, अमावस्या पर लगभग शून्य।',
                ),
              ],
            ),
    );
  }

  Widget _metric(String title, String value, double bar) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: bar.clamp(0.02, 1)),
          ],
        ),
      ),
    );
  }

  Widget _tithiChip(int i, int current) {
    final shukla = i <= 15;
    final idx = (i - 1) % 15;
    final name = idx == 14 ? (shukla ? 'पूर्णिमा' : 'अमावस्या') : _tithiNames[idx];
    final on = i == current;
    return Chip(
      backgroundColor: on ? const Color(0xFF5C3A21) : (shukla ? const Color(0xFFFFF3CD) : const Color(0xFFE8EAF6)),
      label: Text(
        '$i ${shukla ? 'शुक्ल' : 'कृष्ण'} $name',
        style: TextStyle(
          color: on ? const Color(0xFFF4E8D1) : const Color(0xFF5C3A21),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
