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
        date: DateTime.now(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('चन्द्र कला')),
      body: _data == null
          ? Center(child: _error == null ? const CircularProgressIndicator() : Text(_error!))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('स्थान: $_place', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                MoonPhaseChart(
                  solarLongitude: _data!.solarLongitude,
                  lunarLongitude: _data!.lunarLongitude,
                  tithi: _data!.tithi,
                  paksha: _data!.paksha,
                  nakshatra: _data!.nakshatra,
                  lunarRashi: _data!.lunarRashiName,
                  tithiProgress: _data!.tithiProgress,
                ),
                const SizedBox(height: 12),
                const Text(
                  'तिथि सूर्य-चन्द्र अन्तर के प्रत्येक १२ अंश से बनती है। '
                  'पूर्णिमा पर प्रकाश लगभग १००%, अमावस्या पर लगभग शून्य।',
                ),
              ],
            ),
    );
  }
}
