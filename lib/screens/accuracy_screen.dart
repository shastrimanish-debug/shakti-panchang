import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/astronomical_panchang_service.dart';
import '../services/calc_settings.dart';
import '../services/meeus_engine.dart';
import '../models/astronomical_panchang.dart';

class AccuracyScreen extends StatefulWidget {
  final double lat;
  final double lon;
  final DateTime date;
  const AccuracyScreen({
    super.key,
    required this.lat,
    required this.lon,
    required this.date,
  });

  @override
  State<AccuracyScreen> createState() => _AccuracyScreenState();
}

class _AccuracyScreenState extends State<AccuracyScreen> {
  CalcSettings _s = const CalcSettings();

  @override
  void initState() {
    super.initState();
    CalcSettingsStore().load().then((v) {
      if (mounted) setState(() => _s = v);
    });
  }

  Future<void> _save(CalcSettings next) async {
    await CalcSettingsStore().save(next);
    if (mounted) setState(() => _s = next);
  }

  @override
  Widget build(BuildContext context) {
    final aya = MeeusEngine.ayanamsha(widget.date, _s.ayanamsha);
    final meeusSun = MeeusEngine.norm(MeeusEngine.sunTropical(widget.date) - aya);
    return Scaffold(
      appBar: AppBar(title: const Text('गणना जाँच')),
      body: FutureBuilder<AstronomicalPanchang>(
        future: AstronomicalPanchangService().calculate(
          date: widget.date,
          latitude: widget.lat,
          longitude: widget.lon,
        ),
        builder: (context, snap) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('गणना विकल्प', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _s.ayanamsha,
                decoration: const InputDecoration(labelText: 'अयनांश'),
                items: const [
                  DropdownMenuItem(value: 'lahiri', child: Text('लाहिरी / चित्रपक्ष')),
                  DropdownMenuItem(value: 'raman', child: Text('बी.वी. रमन')),
                  DropdownMenuItem(value: 'kp', child: Text('के.पी.')),
                ],
                onChanged: (v) {
                  if (v != null) _save(_s.copyWith(ayanamsha: v));
                },
              ),
              DropdownButtonFormField<String>(
                value: _s.nodeType,
                decoration: const InputDecoration(labelText: 'राहु'),
                items: const [
                  DropdownMenuItem(value: 'mean', child: Text('मध्य राहु')),
                  DropdownMenuItem(value: 'true', child: Text('सत्य राहु')),
                ],
                onChanged: (v) {
                  if (v != null) _save(_s.copyWith(nodeType: v));
                },
              ),
              DropdownButtonFormField<String>(
                value: _s.houseSystem,
                decoration: const InputDecoration(labelText: 'भाव'),
                items: const [
                  DropdownMenuItem(value: 'whole', child: Text('राशि भाव')),
                  DropdownMenuItem(value: 'sripati', child: Text('श्रीपति')),
                ],
                onChanged: (v) {
                  if (v != null) _save(_s.copyWith(houseSystem: v));
                },
              ),
              const SizedBox(height: 16),
              if (snap.connectionState != ConnectionState.done)
                const Center(child: CircularProgressIndicator())
              else if (snap.hasError)
                Text('Engine: ${snap.error}')
              else ...[
                _r('Engine', snap.data!.engine),
                _r('तिथि', '${snap.data!.tithi} (#${snap.data!.tithiNumber})'),
                _r('नक्षत्र', snap.data!.nakshatra),
                _r('योग', snap.data!.yoga),
                _r('करण', snap.data!.karana),
                _r('XALEN/मुख्य सूर्य', '${snap.data!.solarLongitude.toStringAsFixed(2)}°'),
                _r('मीयस सूर्य', '${meeusSun.toStringAsFixed(2)}°'),
                _r('XALEN/मुख्य चंद्र', '${snap.data!.lunarLongitude.toStringAsFixed(2)}°'),
                _r('अयनांश', '${snap.data!.ayanamsha.toStringAsFixed(4)}°'),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(snap.data!.precisionNote, style: const TextStyle(fontSize: 12)),
                ),
              ],
              const SizedBox(height: 16),
              Text('रिलीज़: ${AppConfig.releaseName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(AppConfig.githubReleasesUrl, style: const TextStyle(fontSize: 12)),
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
