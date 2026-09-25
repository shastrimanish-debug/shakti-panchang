import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/location_store.dart';
import '../services/muhurat_engine.dart';
import '../services/solar_service.dart';

class AnnualMuhuratScreen extends StatefulWidget {
  const AnnualMuhuratScreen({super.key});

  @override
  State<AnnualMuhuratScreen> createState() => _AnnualMuhuratScreenState();
}

class _AnnualMuhuratScreenState extends State<AnnualMuhuratScreen> {
  late DateTime _day;
  List<MuhuratWindow> _windows = const [];
  String _place = 'उज्जैन';

  @override
  void initState() {
    super.initState();
    _day = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final solar = SolarService.forDate(date: _day, latitude: lat, longitude: lon);
    final list = MuhuratEngine().dailyNamed(
      solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise),
      weekday: _day.weekday,
    );
    if (!mounted) return;
    setState(() {
      _windows = list;
      _place = loc?.name ?? 'उज्जैन';
    });
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मुहूर्त सारणी')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('${_day.day}-${_day.month}-${_day.year} • $_place', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('तिथि बदलकर उसी दिन के नामित मुहूर्त देखें'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: DateTime(_day.year - 1),
                lastDate: DateTime(_day.year + 2),
              );
              if (picked == null) return;
              setState(() => _day = picked);
              await _load();
            },
          ),
          const SizedBox(height: 10),
          for (final w in _windows)
            Card(
              child: ListTile(
                title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${_hm(w.start)} – ${_hm(w.end)}\n${w.description}'),
                isThreeLine: true,
              ),
            ),
        ],
      ),
    );
  }
}
