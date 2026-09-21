import 'package:flutter/material.dart';
import '../models/astronomical_panchang.dart';
import '../models/panchang_models.dart';
import '../services/astronomical_panchang_service.dart';
import '../services/calc_settings.dart';
import '../services/choghadiya_service.dart';
import '../services/disha_service.dart';
import '../services/inauspicious_service.dart';
import '../services/muhurat_engine.dart';
import '../services/panchang_boundary_service.dart';
import '../services/xalen_service.dart';
import 'accuracy_screen.dart';
import 'uma_screen.dart';

class PanchangDetailScreen extends StatefulWidget {
  final DateTime date;
  final AstronomicalPanchang data;
  final double lat;
  final double lon;
  final String place;

  const PanchangDetailScreen({
    super.key,
    required this.date,
    required this.data,
    this.lat = 23.1765,
    this.lon = 75.7885,
    this.place = 'उज्जैन',
  });

  @override
  State<PanchangDetailScreen> createState() => _PanchangDetailScreenState();
}

class _PanchangDetailScreenState extends State<PanchangDetailScreen> {
  late DateTime _date;
  late AstronomicalPanchang _data;
  CalcSettings _s = const CalcSettings();
  int _tab = 0;

  static const _wd = {
    1: 'सोमवार', 2: 'मंगलवार', 3: 'बुधवार', 4: 'गुरुवार',
    5: 'शुक्रवार', 6: 'शनिवार', 7: 'रविवार',
  };

  @override
  void initState() {
    super.initState();
    _date = widget.date;
    _data = widget.data;
    CalcSettingsStore().load().then((v) {
      if (mounted) setState(() => _s = v);
    });
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _shift(int days) async {
    final next = _date.add(Duration(days: days));
    final p = await AstronomicalPanchangService().calculate(
      date: next,
      latitude: widget.lat,
      longitude: widget.lon,
    );
    if (!mounted) return;
    setState(() {
      _date = next;
      _data = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    final solar = SolarTimes(
      sunrise: _data.localSunrise,
      sunset: _data.localSunset,
      nextSunrise: _data.nextLocalSunrise,
    );
    final muhurat = MuhuratEngine().dailyNamed(solar: solar, weekday: _date.weekday);
    final tyajya = {'राहु काल', 'यमगण्ड', 'गुलिक काल', 'निशीथ काल'};
    final shool = DishaService.avoided(_date);
    final dayCh = ChoghadiyaService.day(solar, _date.weekday);
    final inaus = InauspiciousService.daytime(solar.sunrise, solar.sunset, _date.weekday);
    final moonRashi = const [
      'मेष','वृषभ','मिथुन','कर्क','सिंह','कन्या',
      'तुला','वृश्चिक','धनु','मकर','कुंभ','मीन',
    ][(_data.lunarLongitude / 30).floor() % 12];

    return Scaffold(
      appBar: AppBar(
        title: const Text('पूरा पंचांग'),
        actions: [
          IconButton(
            tooltip: 'उमा',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UmaScreen(date: _date, pageContext: 'पंचांग', pageDescription: 'आज का पंचांग'),
              ),
            ),
          ),
          IconButton(
            tooltip: 'जाँच',
            icon: const Icon(Icons.science_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccuracyScreen(lat: widget.lat, lon: widget.lon, date: _date),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left)),
              Expanded(
                child: Text(
                  '${_wd[_date.weekday]}  ${_date.day}/${_date.month}/${_date.year}\n${widget.place}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chip(0, 'अंग'),
              _chip(1, 'मुहूर्त'),
              _chip(2, 'दिशा'),
            ],
          ),
          const SizedBox(height: 12),
          if (_tab == 0) ...[
            _kv('पक्ष / तिथि', '${_data.paksha}  ${_data.tithi}  (${(_data.tithiProgress * 100).round()}%)'),
            _kv('नक्षत्र', '${_data.nakshatra}  (${(_data.nakshatraProgress * 100).round()}%)'),
            _kv('योग', _data.yoga),
            _kv('करण', _data.karana),
            _kv('सूर्य राशि', _data.solarRashi),
            _kv('चंद्र राशि', moonRashi),
            _kv('अयनांश', '${_data.ayanamshaName}  ${_data.ayanamsha.toStringAsFixed(4)}°'),
            _kv('सूर्योदय', _hm(_data.localSunrise)),
            _kv('सूर्यास्त', _hm(_data.localSunset)),
            _kv('इंजन', _data.engine),
            const SizedBox(height: 8),
            FutureBuilder(
              future: PanchangBoundaryService(AstronomyEngineService()).calculate(_date),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(minHeight: 2),
                  );
                }
                final b = snap.data!;
                String f(DateTime x) =>
                    '${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';
                return Column(
                  children: [
                    _kv('तिथि आरंभ–समाप्ति', '${f(b.tithi.start)} – ${f(b.tithi.end)}  → ${b.tithi.nextName}'),
                    _kv('नक्षत्र आरंभ–समाप्ति', '${f(b.nakshatra.start)} – ${f(b.nakshatra.end)}  → ${b.nakshatra.nextName}'),
                    _kv('योग आरंभ–समाप्ति', '${f(b.yoga.start)} – ${f(b.yoga.end)}  → ${b.yoga.nextName}'),
                    _kv('करण', '${f(b.karana.start)}  ${b.karana.currentName}'),
                  ],
                );
              },
            ),
            const Divider(),
            const Text('गणना विकल्प', style: TextStyle(fontWeight: FontWeight.w900)),
            DropdownButtonFormField<String>(
              key: ValueKey('aya-${_s.ayanamsha}'),
              initialValue: _s.ayanamsha,
              decoration: const InputDecoration(labelText: 'अयनांश'),
              items: const [
                DropdownMenuItem(value: 'lahiri', child: Text('लाहिरी')),
                DropdownMenuItem(value: 'raman', child: Text('रमन')),
                DropdownMenuItem(value: 'kp', child: Text('के.पी.')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                final n = _s.copyWith(ayanamsha: v);
                await CalcSettingsStore().save(n);
                final p = await AstronomicalPanchangService().calculate(
                  date: _date, latitude: widget.lat, longitude: widget.lon,
                );
                if (!mounted) return;
                setState(() {
                  _s = n;
                  _data = p;
                });
              },
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('node-${_s.nodeType}'),
              initialValue: _s.nodeType,
              decoration: const InputDecoration(labelText: 'राहु'),
              items: const [
                DropdownMenuItem(value: 'mean', child: Text('मध्य राहु')),
                DropdownMenuItem(value: 'true', child: Text('सत्य राहु')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                final n = _s.copyWith(nodeType: v);
                await CalcSettingsStore().save(n);
                if (mounted) setState(() => _s = n);
              },
            ),
            DropdownButtonFormField<String>(
              key: ValueKey('house-${_s.houseSystem}'),
              initialValue: _s.houseSystem,
              decoration: const InputDecoration(labelText: 'भाव'),
              items: const [
                DropdownMenuItem(value: 'whole', child: Text('राशि-भाव')),
                DropdownMenuItem(value: 'sripati', child: Text('श्रीपति')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                final n = _s.copyWith(houseSystem: v);
                await CalcSettingsStore().save(n);
                if (mounted) setState(() => _s = n);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_data.precisionNote, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ),
          ] else if (_tab == 1) ...[
            ...inaus.map((w) => _timeCard(w.title, _hm(w.start), _hm(w.end), tyajya: true)),
            ...muhurat.map((w) => _timeCard(
                  w.title,
                  _hm(w.start),
                  _hm(w.end),
                  tyajya: tyajya.contains(w.title),
                  note: w.description,
                )),
            const SizedBox(height: 8),
            const Text('दिन चौघड़िया', style: TextStyle(fontWeight: FontWeight.w900)),
            ...dayCh.map((c) => _timeCard(
                  '${c.name} — ${c.meaning}',
                  _hm(c.start),
                  _hm(c.end),
                  tyajya: c.nature == ChoghadiyaNature.inauspicious,
                )),
          ] else ...[
            Card(
              color: const Color(0xFFFFF4DC),
              child: ListTile(
                leading: const Icon(Icons.explore, color: Color(0xFFB56A00)),
                title: const Text('आज का दिशाशूल', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('$shool दिशा में नई यात्रा शुरू न करें।\n${DishaService.advice(shool, _date)}'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(int i, String t) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _tab == i ? const Color(0xFF5C3A21) : const Color(0xFFF4E8D1),
              foregroundColor: _tab == i ? Colors.white : const Color(0xFF5C3A21),
            ),
            onPressed: () => setState(() => _tab = i),
            child: Text(t),
          ),
        ),
      );

  Widget _kv(String k, String v) => Card(
        child: ListTile(
          dense: true,
          title: Text(k, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          subtitle: Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      );

  Widget _timeCard(String title, String a, String b, {bool tyajya = false, String? note}) => Card(
        color: tyajya ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        child: ListTile(
          dense: true,
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: note == null ? null : Text(note),
          trailing: Text('$a–$b', style: const TextStyle(fontWeight: FontWeight.w900)),
        ),
      );
}
