import 'package:flutter/material.dart';
import '../services/sade_sati_service.dart';
import '../services/kundali_profile_store.dart';
import '../services/kundali_calculator.dart';

class SadeSatiScreen extends StatefulWidget {
  const SadeSatiScreen({super.key});
  @override
  State<SadeSatiScreen> createState() => _SadeSatiScreenState();
}

class _SadeSatiScreenState extends State<SadeSatiScreen> {
  String _moon = 'कर्क';
  SadeSatiStatus? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final profiles = await KundaliProfileStore.getSavedProfiles();
      if (profiles.isNotEmpty) {
        final p = profiles.first;
        final rawDate = (p['date'] ?? p['birthDate'] ?? '').toString();
        final parts = rawDate.contains('T') ? rawDate.substring(0, 10).split('-') : rawDate.split('-');
        if (parts.length == 3) {
          late int y, m, d;
          if (rawDate.contains('T') || parts[0].length == 4) {
            y = int.tryParse(parts[0]) ?? DateTime.now().year;
            m = int.tryParse(parts[1]) ?? 1;
            d = int.tryParse(parts[2]) ?? 1;
          } else {
            d = int.tryParse(parts[0]) ?? 1;
            m = int.tryParse(parts[1]) ?? 1;
            y = int.tryParse(parts[2]) ?? DateTime.now().year;
          }
          final t = (p['time'] ?? p['birthTime'] ?? '12:00').toString().split(':');
          final k = await KundaliCalculator.calculate(
            name: p['name']?.toString() ?? 'जातक',
            birthDate: DateTime(y, m, d),
            birthTime: '${(int.tryParse(t.first) ?? 12).toString().padLeft(2, '0')}:${t.length > 1 ? t[1] : '00'}',
            birthPlace: (p['place'] ?? p['birthPlace'] ?? '').toString(),
            latitude: (p['lat'] as num?)?.toDouble() ?? 0,
            longitude: (p['lng'] as num?)?.toDouble() ?? 0,
          );
          _moon = k.moonRashi;
        }
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _status = SadeSatiService.forMoonRashi(_moon);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Scaffold(
      appBar: AppBar(title: const Text('साढ़ेसाती व ढैया')),
      body: _loading || s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Wrap(
                  spacing: 8,
                  children: SadeSatiService.rashis
                      .map((r) => ChoiceChip(
                            label: Text(r),
                            selected: _moon == r,
                            onSelected: (_) => setState(() {
                              _moon = r;
                              _status = SadeSatiService.forMoonRashi(r);
                            }),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFFFFF8E7),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(s.summary, style: const TextStyle(height: 1.45, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
                Text('वर्तमान शनि: ${s.shaniRashi} • चंद्र से भाव ${s.houseFromMoon} • ढैया: ${s.dhaiyaType}'),
                const SizedBox(height: 12),
                ...s.phases.map((p) => Card(
                      color: p.active ? const Color(0xFFFFE8C8) : null,
                      child: ListTile(
                        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${p.shaniRashi} • ${p.window}\n${p.description}\nतीव्रता: ${p.intensity}'),
                        isThreeLine: true,
                        trailing: p.active ? const Text('सक्रिय', style: TextStyle(fontWeight: FontWeight.w900)) : null,
                      ),
                    )),
                const SizedBox(height: 12),
                const Text('शनि शांति उपाय', style: TextStyle(fontWeight: FontWeight.w900)),
                ...s.remedies.map((r) => ListTile(dense: true, leading: const Text('•'), title: Text(r))),
              ],
            ),
    );
  }
}
