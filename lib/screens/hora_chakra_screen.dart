import 'package:flutter/material.dart';
import '../services/hora_panchak_yoga_service.dart';
import '../services/location_store.dart';
import '../services/solar_service.dart';

class HoraChakraScreen extends StatefulWidget {
  const HoraChakraScreen({super.key});

  @override
  State<HoraChakraScreen> createState() => _HoraChakraScreenState();
}

class _HoraChakraScreenState extends State<HoraChakraScreen> {
  List<HoraSlot> _slots = const [];
  String _place = 'उज्जैन';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final now = DateTime.now();
    final solar = SolarService.forDate(date: now, latitude: lat, longitude: lon);
    final slots = HoraPanchakYogaService.calculate24Horas(
      sunrise: solar.sunrise,
      sunset: solar.sunset,
      nextSunrise: solar.nextSunrise,
      weekdayNumber: now.weekday,
      currentTime: now,
    );
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _place = loc?.name ?? 'उज्जैन';
    });
  }

  Color _tone(String nature) {
    switch (nature) {
      case 'shubh':
        return const Color(0xFFE8F5E9);
      case 'ashubh':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFFFF8E1);
    }
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('होरा चक्र • $_place')),
      body: _slots.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _slots.length,
              itemBuilder: (_, i) {
                final h = _slots[i];
                return Card(
                  color: h.isActive ? const Color(0xFFFFE0B2) : _tone(h.nature),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(h.symbol)),
                    title: Text(
                      '${h.hourNumber}. ${h.planet} होरा${h.isActive ? ' • अभी' : ''}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('${_hm(h.start)}–${_hm(h.end)} • ${h.isDay ? 'दिन' : 'रात्रि'}\n${h.description}'),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
