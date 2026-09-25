// lib/screens/panchang_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/astronomical_panchang.dart';
import '../models/panchang_models.dart';
import '../services/astronomical_panchang_service.dart';
import '../services/choghadiya_service.dart';
import '../services/inauspicious_service.dart';
import '../services/muhurat_engine.dart';
import '../services/hora_panchak_yoga_service.dart';
import '../services/whatsapp_panchang_share_service.dart';
import '../services/bhojpatra_pdf_service.dart';
import '../services/disha_service.dart';
import '../widgets/flutter_panchang_cards.dart';
import '../widgets/moon_phase_chart.dart';
import 'uma_screen.dart';
import 'digital_compass_screen.dart';
import 'moon_phase_screen.dart';

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
  int _activeTab = 0;

  static const _wd = {
    1: 'सोमवार', 2: 'मंगलवार', 3: 'बुधवार', 4: 'गुरुवार',
    5: 'शुक्रवार', 6: 'शनिवार', 7: 'रविवार',
  };

  @override
  void initState() {
    super.initState();
    _date = widget.date;
    _data = widget.data;
  }

  String get _samvat {
    var y = _date.year + 57;
    if (_date.month < 4) y -= 1;
    return 'विक्रम $y';
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

  void _shareWhatsAppSuprabhat() {
    final solar = SolarTimes(
      sunrise: _data.localSunrise,
      sunset: _data.localSunset,
      nextSunrise: _data.nextLocalSunrise,
    );
    final muhurat = MuhuratEngine().dailyNamed(solar: solar, weekday: _date.weekday);
    final inaus = InauspiciousService.daytime(solar.sunrise, solar.sunset, _date.weekday);
    final panchak = HoraPanchakYogaService.calculatePanchak(nakshatra: _data.nakshatra, weekdayNumber: _date.weekday);
    final bhadra = HoraPanchakYogaService.calculateBhadra(karana: _data.karana, lunarRashi: _data.lunarRashiName, sunrise: _data.localSunrise, sunset: _data.localSunset);
    final specialYogas = HoraPanchakYogaService.calculateSpecialYogas(nakshatra: _data.nakshatra, weekdayNumber: _date.weekday, tithi: _data.tithi);
    final abhijit = muhurat.where((m) => m.title.contains('अभिजित')).firstOrNull;
    final rahu = inaus.where((m) => m.title.contains('राहु')).firstOrNull;
    final shareText = WhatsAppPanchangShareService.buildWhatsAppShareText(
      date: _date,
      weekday: _wd[_date.weekday] ?? 'सोमवार',
      tithi: _data.tithi,
      paksha: _data.paksha,
      masa: _data.masa,
      samvat: _samvat,
      nakshatra: _data.nakshatra,
      yoga: _data.yoga,
      karana: _data.karana,
      sunrise: _hm(_data.localSunrise),
      sunset: _hm(_data.localSunset),
      lunarRashi: _data.lunarRashiName,
      solarRashi: _data.solarRashi,
      abhijitMuhurat: abhijit != null ? '${_hm(abhijit.start)} - ${_hm(abhijit.end)}' : 'आज नहीं',
      rahuKaal: rahu != null ? '${_hm(rahu.start)} - ${_hm(rahu.end)}' : '—',
      panchakName: panchak.typeNameHindi,
      bhadraStatus: bhadra.isActive ? '${bhadra.vas} (${bhadra.nature == "varjya" ? "वर्जित" : "शुभ"})' : 'भद्रा मुक्त',
      specialYogas: specialYogas.map((y) => y.name).toList(),
      locationName: widget.place,
    );
    SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'सनातन शक्ति पंचांग - ${_wd[_date.weekday]}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solar = SolarTimes(
      sunrise: _data.localSunrise,
      sunset: _data.localSunset,
      nextSunrise: _data.nextLocalSunrise,
    );
    final specialYogas = HoraPanchakYogaService.calculateSpecialYogas(
      nakshatra: _data.nakshatra,
      weekdayNumber: _date.weekday,
      tithi: _data.tithi,
    );
    final panchak = HoraPanchakYogaService.calculatePanchak(
      nakshatra: _data.nakshatra,
      weekdayNumber: _date.weekday,
    );
    final bhadra = HoraPanchakYogaService.calculateBhadra(
      karana: _data.karana,
      lunarRashi: _data.lunarRashiName,
      sunrise: _data.localSunrise,
      sunset: _data.localSunset,
    );
    final horas = HoraPanchakYogaService.calculate24Horas(
      sunrise: _data.localSunrise,
      sunset: _data.localSunset,
      nextSunrise: _data.nextLocalSunrise,
      weekdayNumber: _date.weekday,
    );
    final currentHora = horas.where((h) => h.isActive).firstOrNull;
    final muhurat = MuhuratEngine().dailyNamed(solar: solar, weekday: _date.weekday);
    final tyajya = {'राहु काल', 'यमगण्ड', 'गुलिक काल', 'निशीथ काल'};
    final inaus = InauspiciousService.daytime(solar.sunrise, solar.sunset, _date.weekday);
    final dayCh = ChoghadiyaService.day(solar, _date.weekday);
    final shool = DishaService.avoided(_date);
    final dayDurationHours = _data.localSunset.difference(_data.localSunrise).inMinutes / 60.0;
    final nightDurationHours = _data.nextLocalSunrise.difference(_data.localSunset).inMinutes / 60.0;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF381E0C),
        foregroundColor: const Color(0xFFFEE180),
        elevation: 0,
        title: const Text('सनातन शक्ति पंचांग', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'व्हाट्सएप शेयर',
            icon: const Icon(Icons.share, color: Color(0xFF25D366)),
            onPressed: _shareWhatsAppSuprabhat,
          ),
          IconButton(
            tooltip: 'भोजपत्र PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => BhojpatraPdfService.panchang(
              p: _data,
              date: _date,
              place: widget.place,
            ),
          ),
          IconButton(
            tooltip: 'उमा AI',
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFF9D976)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UmaScreen(date: _date, pageContext: 'पंचांग', pageDescription: 'आज का पंचांग'),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5D5BC)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF5C3A21)),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_wd[_date.weekday]}  ${_date.day}/${_date.month}/${_date.year}',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF381E0C)),
                      ),
                      Text(
                        widget.place,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8C5D35), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF5C3A21)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _tabChip(0, '🛒 मुख्य'),
                _tabChip(1, '♄ गोचर'),
                _tabChip(2, '⏳ होरा (२४ h)'),
                _tabChip(3, '✨ मुहूर्त'),
                _tabChip(4, '🔭 खगोल'),
                _tabChip(5, '🧭 दिशा'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_activeTab == 0) ...[
            HeroTithiCard(
              tithi: _data.tithi,
              paksha: _data.paksha,
              masa: _data.masa,
              samvat: _samvat,
              progress: _data.tithiProgress,
            ),
            const SizedBox(height: 10),
            SpecialYogaBanner(yogas: specialYogas),
            PanchakBhadraRow(panchak: panchak, bhadra: bhadra),
            const SizedBox(height: 10),
            MoonPhaseChart(
              solarLongitude: _data.solarLongitude,
              lunarLongitude: _data.lunarLongitude,
              tithi: _data.tithi,
              paksha: _data.paksha,
              nakshatra: _data.nakshatra,
              lunarRashi: _data.lunarRashiName,
              tithiProgress: _data.tithiProgress,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoonPhaseScreen()),
                ),
                child: const Text('चन्द्र कला बड़ा देखें'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _angaCard('🌟 नक्षत्र', _data.nakshatra, 'चरण ${_data.nakshatraPada}')),
                const SizedBox(width: 8),
                Expanded(child: _angaCard('☯️ योग', _data.yoga, 'दैनिक योग')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _angaCard('⚡ करण', _data.karana, 'आधा तिथि मान')),
                const SizedBox(width: 8),
                Expanded(child: _angaCard('♈ राशि', 'चन्द्र: ${_data.lunarRashiName}', 'सूर्य: ${_data.solarRashi}')),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _shareWhatsAppSuprabhat,
              icon: const Icon(Icons.share),
              label: const Text('📲 व्हाट्सएप सुप्रभात पंचांग कार्ड भेजें', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ] else if (_activeTab == 1) ...[
            _sectionHeader('♄ प्रत्यक्ष ग्रह गोचर'),
            _kv('सूर्य राशि', _data.solarRashi),
            _kv('चन्द्र राशि', _data.lunarRashiName),
            _kv('नक्षत्र', '${_data.nakshatra} (चरण ${_data.nakshatraPada})'),
            _kv('अयनांश', '${_data.ayanamshaName} ${_data.ayanamsha.toStringAsFixed(4)}°'),
          ] else if (_activeTab == 2) ...[
            _sectionHeader('⏳ दैनिक २४ घंटे होरा चक्र'),
            if (currentHora != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFC107)),
                ),
                child: Text(
                  '🌟 वर्तमान सक्रिय: ${currentHora.symbol} ${currentHora.planet} होरा (${_hm(currentHora.start)}–${_hm(currentHora.end)})',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF664D03)),
                ),
              ),
            ...horas.map((h) => Card(
              color: h.isActive ? const Color(0xFFFFF8E1) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: h.isActive ? const Color(0xFFFFA000) : Colors.black12),
              ),
              child: ListTile(
                dense: true,
                leading: Text(h.symbol, style: const TextStyle(fontSize: 20)),
                title: Text('${h.planet} होरा (${h.isDay ? "दिन" : "रात्रि"})', style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(h.description, style: const TextStyle(fontSize: 11)),
                trailing: Text('${_hm(h.start)}–${_hm(h.end)}', style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              ),
            )),
          ] else if (_activeTab == 3) ...[
            _sectionHeader('✨ दैनिक शुभ व अशुभ मुहूर्त'),
            ...inaus.map((w) => _timeCard(w.title, _hm(w.start), _hm(w.end), tyajya: true)),
            ...muhurat.map((w) => _timeCard(
                  w.title,
                  _hm(w.start),
                  _hm(w.end),
                  tyajya: tyajya.contains(w.title),
                  note: w.description,
                )),
            const SizedBox(height: 8),
            _sectionHeader('दिन चौघड़िया'),
            ...dayCh.map((c) => _timeCard(
                  '${c.name} — ${c.meaning}',
                  _hm(c.start),
                  _hm(c.end),
                  tyajya: c.nature == ChoghadiyaNature.inauspicious,
                )),
          ] else if (_activeTab == 4) ...[
            _sectionHeader('🔭 सूर्य व चन्द्र खगोलीय स्थिति'),
            _kv('सूर्योदय', _hm(_data.localSunrise)),
            _kv('सूर्यास्त', _hm(_data.localSunset)),
            _kv('दिनमान', '${dayDurationHours.toStringAsFixed(2)} घंटे'),
            _kv('रात्रिमान', '${nightDurationHours.toStringAsFixed(2)} घंटे'),
            _kv('अक्षांश', '${widget.lat.toStringAsFixed(4)}° N'),
            _kv('देशांतर', '${widget.lon.toStringAsFixed(4)}° E'),
          ] else if (_activeTab == 5) ...[
            _sectionHeader('🧭 आज का दिशाशूल'),
            Card(
              color: const Color(0xFFFFF4DC),
              child: ListTile(
                leading: const Icon(Icons.explore, color: Color(0xFFB56A00)),
                title: const Text('आज का दिशाशूल', style: TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('$shool दिशा में नई यात्रा शुरू न करें।\n${DishaService.advice(shool, _date)}'),
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DigitalCompassScreen(shoolDirection: shool),
                ),
              ),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('वैदिक दिशा-सूचक खोलें'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tabChip(int i, String label) {
    final isSelected = _activeTab == i;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? Colors.white : const Color(0xFF5C3A21))),
        selected: isSelected,
        selectedColor: const Color(0xFF5C3A21),
        backgroundColor: Colors.white,
        onSelected: (_) => setState(() => _activeTab = i),
      ),
    );
  }

  Widget _angaCard(String title, String val, String sub) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5D5BC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF8C5D35))),
        const SizedBox(height: 3),
        Text(val, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF381E0C))),
        Text(sub, style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    ),
  );

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF381E0C))),
  );

  Widget _kv(String k, String v) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      dense: true,
      title: Text(k, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      trailing: Text(v, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF5C3A21))),
    ),
  );

  Widget _timeCard(String title, String a, String b, {bool tyajya = false, String? note}) => Card(
    margin: const EdgeInsets.only(bottom: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: tyajya ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
    child: ListTile(
      dense: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: note == null ? null : Text(note, style: const TextStyle(fontSize: 11)),
      trailing: Text('$a–$b', style: const TextStyle(fontWeight: FontWeight.w900, fontFamily: 'monospace')),
    ),
  );
}
