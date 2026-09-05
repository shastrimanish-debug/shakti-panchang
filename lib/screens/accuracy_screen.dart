import 'package:flutter/material.dart';
import '../services/astronomical_panchang_service.dart';
import '../models/astronomical_panchang.dart';

class AccuracyScreen extends StatelessWidget {
  final double lat;
  final double lon;
  final DateTime date;
  const AccuracyScreen({
    super.key, required this.lat, required this.lon, required this.date
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔬 गणना जाँच')),
      body: FutureBuilder<AstronomicalPanchang>(
        future: AstronomicalPanchangService().calculate(
          date: date, latitude: lat, longitude: lon,
        ),
        builder: (context, s) {
          if (s.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Engine error: ${s.error}'),
            ));
          }
          final p = s.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _r('Engine', p.engine),
              _r('Sunrise', p.localSunrise.toString()),
              _r('Sunset', p.localSunset.toString()),
              _r('Next sunrise', p.nextLocalSunrise.toString()),
              _r('Tithi', '${p.tithi} (#${p.tithiNumber})'),
              _r('Tithi progress', '${(p.tithiProgress * 100).toStringAsFixed(2)}%'),
              _r('Nakshatra', '${p.nakshatra} (#${p.nakshatraNumber})'),
              _r('Yoga', '${p.yoga} (#${p.yogaNumber})'),
              _r('Karana', '${p.karana} (#${p.karanaNumber})'),
              _r('Sun longitude', '${p.solarLongitude.toStringAsFixed(6)}°'),
              _r('Moon longitude', '${p.lunarLongitude.toStringAsFixed(6)}°'),
              _r('Ayanamsha', '${p.ayanamsha.toStringAsFixed(6)}°'),
              const SizedBox(height: 12),
              Text(p.precisionNote, style: const TextStyle(fontSize: 12)),
            ],
          );
        },
      ),
    );
  }

  Widget _r(String a, String b) => Card(
    child: ListTile(title: Text(a), subtitle: Text(b)),
  );
}
