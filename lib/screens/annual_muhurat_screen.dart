import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/disha_service.dart';
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
  List<_DayRow> _month = const [];
  String _place = 'उज्जैन';
  MuhuratActivity _activity = MuhuratActivity.general;
  bool _loading = true;

  static const _tyajya = {'राहु काल', 'यमगण्ड', 'गुलिक काल', 'निशीथ काल'};

  String _label(MuhuratActivity a) => switch (a) {
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
  void initState() {
    super.initState();
    _day = DateTime.now();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final engine = MuhuratEngine();
    final solar = SolarService.forDate(date: _day, latitude: lat, longitude: lon);
    final times = SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise);
    final named = engine.dailyNamed(solar: times, weekday: _day.weekday);
    final work = engine.forActivity(activity: _activity, solar: times, weekday: _day.weekday);

    final start = DateTime(_day.year, _day.month, 1);
    final end = DateTime(_day.year, _day.month + 1, 0);
    final rows = <_DayRow>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final s = SolarService.forDate(date: d, latitude: lat, longitude: lon);
      final st = SolarTimes(sunrise: s.sunrise, sunset: s.sunset, nextSunrise: s.nextSunrise);
      final wins = engine.dailyNamed(solar: st, weekday: d.weekday);
      MuhuratWindow? find(String t) {
        for (final w in wins) {
          if (w.title == t) return w;
        }
        return null;
      }
      rows.add(_DayRow(
        date: d,
        abhijit: find('अभिजित मुहूर्त'),
        godhuli: find('गोधूलि मुहूर्त'),
        rahu: find('राहु काल'),
        shool: DishaService.avoided(d),
      ));
    }

    if (!mounted) return;
    setState(() {
      _windows = [
        ...work,
        ...named.where((w) => !work.any((x) => x.title == w.title)),
      ];
      _month = rows;
      _place = loc?.name ?? 'उज्जैन';
      _loading = false;
    });
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _wd(DateTime d) =>
      const ['सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि', 'रवि'][d.weekday - 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('वार्षिक मुहूर्त सारणी')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text('${_day.day}-${_day.month}-${_day.year} • $_place', style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('तिथि चुनें — उसी दिन के नामित मुहूर्त और पूरे महीने की सारणी'),
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
          const SizedBox(height: 8),
          DropdownButtonFormField<MuhuratActivity>(
            initialValue: _activity,
            decoration: const InputDecoration(labelText: 'किस काम के लिए?', border: OutlineInputBorder()),
            items: MuhuratActivity.values
                .map((a) => DropdownMenuItem(value: a, child: Text(_label(a))))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _activity = v);
              _load();
            },
          ),
          const SizedBox(height: 10),
          Text('दिशाशूल आज: ${DishaService.avoided(_day)}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_loading) const LinearProgressIndicator(),
          const Text('चुने दिन के मुहूर्त', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 6),
          for (final w in _windows)
            Card(
              color: _tyajya.contains(w.title) ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
              child: ListTile(
                title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('${_hm(w.start)} – ${_hm(w.end)}\n${w.description}'),
                isThreeLine: true,
              ),
            ),
          const SizedBox(height: 14),
          Text('${_day.year} / ${_day.month} — मासिक सारणी (अभिजित • गोधूलि • राहु)', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('हरी पंक्ति = अभिजित उपलब्ध। लाल = राहुकाल याद रखें। विवाह/गृहप्रवेश के लिए अभिजित+गोधूलि दोनों देखें।'),
          const SizedBox(height: 8),
          for (final r in _month)
            Card(
              color: r.date.day == _day.day ? const Color(0xFFFFF3CD) : null,
              child: ListTile(
                dense: true,
                onTap: () {
                  setState(() => _day = r.date);
                  _load();
                },
                title: Text('${r.date.day} ${_wd(r.date)} • शूल ${r.shool}', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(
                  'अभिजित ${r.abhijit == null ? '—' : '${_hm(r.abhijit!.start)}–${_hm(r.abhijit!.end)}'}'
                  '  गोधूलि ${r.godhuli == null ? '—' : _hm(r.godhuli!.start)}'
                  '  राहु ${r.rahu == null ? '—' : '${_hm(r.rahu!.start)}–${_hm(r.rahu!.end)}'}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayRow {
  const _DayRow({
    required this.date,
    this.abhijit,
    this.godhuli,
    this.rahu,
    required this.shool,
  });
  final DateTime date;
  final MuhuratWindow? abhijit;
  final MuhuratWindow? godhuli;
  final MuhuratWindow? rahu;
  final String shool;
}
