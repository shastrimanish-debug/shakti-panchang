import 'package:flutter/material.dart';

import '../models/kundali_model.dart';
import '../services/advanced_kundali_service.dart';
import '../services/kundali_calculator.dart';
import '../services/kundali_profile_store.dart';
import 'kundali_modules_screen.dart';
import 'kundali_screen.dart';

class VargaAnalysisScreen extends StatefulWidget {
  const VargaAnalysisScreen({super.key});

  @override
  State<VargaAnalysisScreen> createState() => _VargaAnalysisScreenState();
}

class _VargaAnalysisScreenState extends State<VargaAnalysisScreen> {
  KundaliData? _data;
  String _area = 'विवाह';
  String? _error;
  bool _loading = true;

  static const _areas = ['विवाह', 'करियर', 'धन'];

  static const _vargas = [
    ('D1', 'राशि / लग्न', 'समग्र जीवन और शरीर'),
    ('D2', 'होरा', 'धन-संचय'),
    ('D3', 'द्रेष्काण', 'सहोदर और साहस'),
    ('D4', 'चतुर्थांश', 'संपत्ति और भूमि'),
    ('D7', 'सप्तमांश', 'संतान'),
    ('D9', 'नवमांश', 'धर्म और दाम्पत्य'),
    ('D10', 'दशमांश', 'कर्म और पद'),
    ('D12', 'द्वादशांश', 'माता-पिता'),
    ('D16', 'षोडशांश', 'सुख-वाहन'),
    ('D20', 'विंशांश', 'उपासना'),
    ('D24', 'चतुर्विंशांश', 'विद्या'),
    ('D30', 'त्रिंशांश', 'अरिष्ट'),
    ('D60', 'षष्ट्यांश', 'सूक्ष्म संस्कार'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profiles = await KundaliProfileStore.getSavedProfiles();
      if (profiles.isEmpty) {
        if (!mounted) return;
        setState(() {
          _data = null;
          _error = 'पहले कुंडली बनाकर सेव करें।';
          _loading = false;
        });
        return;
      }
      final p = profiles.first;
      final rawDate = (p['date'] ?? p['birthDate'] ?? '').toString();
      final parts = rawDate.contains('T')
          ? rawDate.substring(0, 10).split('-')
          : rawDate.split('-');
      late int y, m, d;
      if (parts.length == 3 && (rawDate.contains('T') || parts[0].length == 4)) {
        y = int.tryParse(parts[0]) ?? DateTime.now().year;
        m = int.tryParse(parts[1]) ?? 1;
        d = int.tryParse(parts[2]) ?? 1;
      } else if (parts.length == 3) {
        d = int.tryParse(parts[0]) ?? 1;
        m = int.tryParse(parts[1]) ?? 1;
        y = int.tryParse(parts[2]) ?? DateTime.now().year;
      } else {
        final now = DateTime.now();
        y = now.year;
        m = now.month;
        d = now.day;
      }
      final t = (p['time'] ?? p['birthTime'] ?? '12:00').toString().split(':');
      final k = await KundaliCalculator.calculate(
        name: p['name']?.toString() ?? 'जातक',
        birthDate: DateTime(y, m, d),
        birthTime:
            '${(int.tryParse(t.first) ?? 12).toString().padLeft(2, '0')}:${t.length > 1 ? t[1] : '00'}',
        birthPlace: (p['place'] ?? p['birthPlace'] ?? '').toString(),
        latitude: (p['lat'] as num?)?.toDouble() ?? 23.1765,
        longitude: (p['lng'] as num?)?.toDouble() ?? 75.7885,
      );
      if (!mounted) return;
      setState(() {
        _data = k;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      appBar: AppBar(title: const Text('वर्ग विश्लेषण')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : d == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error ?? 'कुंडली नहीं मिली'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const KundaliScreen()),
                          ).then((_) => _load()),
                          child: const Text('कुंडली बनाएँ'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      '${d.name} • लग्न ${d.lagnaRashi} • चंद्र ${d.moonRashi}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    Text('दशा ${d.mahadasha} / ${d.antardasha}'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _areas
                          .map(
                            (a) => ChoiceChip(
                              label: Text(a),
                              selected: _area == a,
                              onSelected: (_) => setState(() => _area = a),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$_area — D1 संकेत',
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            ...AdvancedKundaliService.lifeAnalysis(d, _area).map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text('• $t'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('षोडश वर्ग', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    ..._vargas.map(
                      (v) => Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(v.$1, style: const TextStyle(fontSize: 11)),
                          ),
                          title: Text(v.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(v.$3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => KundaliModulesScreen(data: d)),
                      ),
                      icon: const Icon(Icons.grid_on_rounded),
                      label: const Text('D1–D60 चक्र खोलें'),
                    ),
                    const SizedBox(height: 8),
                    Builder(builder: (_) {
                      final av = AdvancedKundaliService.ashtakavarga(d);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('सर्वाष्टकवर्ग (मेष → मीन)',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              Text(av.sarva.join(', ')),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
    );
  }
}
