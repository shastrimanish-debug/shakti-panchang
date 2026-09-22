import 'package:flutter/material.dart';
import '../services/daily_rashifal_engine.dart';
import '../services/location_store.dart';
import '../services/kundali_profile_store.dart';
import '../services/kundali_calculator.dart';
import '../services/deep_daily_rashifal_service.dart';
import 'premium_daily_report_screen.dart';

const Color _bg = Color(0xFFF4E8D1);
const Color _card = Color(0xFFFAF2E4);
const Color _brown = Color(0xFF5C3A21);

class DailyRashifalScreen extends StatefulWidget {
  const DailyRashifalScreen({super.key});
  @override
  State<DailyRashifalScreen> createState() => _DailyRashifalScreenState();
}

class _DailyRashifalScreenState extends State<DailyRashifalScreen> {
  int _selected = 0;
  DateTime _date = DateTime.now();
  DailyRashifalResult? _result;
  SavedLocation? _location;
  String? _error;
  bool _loading = true;
  bool _useBirthChart = true;
  List<SavedKundaliProfile> _profiles = const [];
  SavedKundaliProfile? _deepProfile;
  DeepDailyReading? _deepReading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await KundaliProfileStore.load();
    SavedKundaliProfile? active = _deepProfile;
    if (active == null && profiles.isNotEmpty) active = profiles.first;
    int selectedRashi = _selected;
    // When a saved birth chart is available, automatically use its natal Moon
    // sign as the daily Rashifal basis. This makes the daily reading genuinely
    // personalized instead of silently defaulting to Aries.
    if (active != null && _useBirthChart) {
      final natal = await KundaliCalculator.calculate(
        name: active.name, birthDate: active.birthDate, birthTime: active.birthTime,
        birthPlace: active.birthPlace, latitude: active.latitude, longitude: active.longitude,
      );
      selectedRashi = DailyRashifalEngine.rashis.indexOf(natal.moonRashi);
      if (selectedRashi < 0) selectedRashi = _selected;
    }
    if (mounted) setState(() { _profiles = profiles; _deepProfile = active; _selected = selectedRashi; });
    setState(() { _loading = true; _error = null; });
    try {
      final location = await LocationStore().selected();
      if (location == null) {
        setState(() {
          _location = null;
          _result = null;
          _error = 'पहले अपना स्थान चुनें। फिर उसी स्थान के पंचांग और ग्रह-स्थितियों से दैनिक राशिफल निकलेगा।';
          _loading = false;
        });
        return;
      }
      final result = await DailyRashifalEngine().calculate(
        date: _date,
        rashiIndex: selectedRashi,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      DeepDailyReading? deep;
      if (_deepProfile != null) {
        deep = await const DeepDailyRashifalService().calculate(profile: _deepProfile!, date: _date);
      }
      if (!mounted) return;
      setState(() { _location = location; _result = result; _deepReading = deep; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'राशिफल की गणना नहीं हो सकी: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: _bg,
        title: const Text('दैनिक राशिफल', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: _card,
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: _brown),
              title: Text('${_date.day}-${_date.month}-${_date.year}'),
              subtitle: Text(_location == null ? 'स्थान चयनित नहीं' : 'स्थान: ${_location!.name}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar, color: _brown),
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2035));
                  if (d != null) { setState(() => _date = d); await _load(); }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_profiles.isNotEmpty) ...[
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('जन्म-कुंडली से Personalize करें', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(_useBirthChart ? 'चुनी हुई कुंडली की चंद्र राशि आधार बनेगी' : 'राशि आप manually चुन सकते हैं'),
              value: _useBirthChart,
              onChanged: (v) async {
                setState(() {
                  _useBirthChart = v;
                  if (!v) _deepProfile = null;
                  if (v && _deepProfile == null && _profiles.isNotEmpty) _deepProfile = _profiles.first;
                });
                await _load();
              },
            ),
          ],
          DropdownButtonFormField<int>(
            value: _selected,
            decoration: const InputDecoration(labelText: 'राशि चुनें', filled: true, fillColor: _card, border: OutlineInputBorder()),
            items: List.generate(12, (i) => DropdownMenuItem(value: i, child: Text('${DailyRashifalEngine.rashis[i]} राशि'))),
            onChanged: _useBirthChart ? null : (v) async { if (v != null) { setState(() => _selected = v); await _load(); } },
          ),
          const SizedBox(height: 14),
          if (_profiles.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              value: _deepProfile?.id,
              decoration: const InputDecoration(labelText: 'जन्म-कुंडली से Daily Rashifal personalize करें', filled: true, fillColor: _card, border: OutlineInputBorder()),
              items: _profiles.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} • ${p.birthPlace}'))).toList(),
              onChanged: (id) async {
                if (id == null) return;
                final p = _profiles.firstWhere((x) => x.id == id);
                setState(() { _deepProfile = p; _useBirthChart = true; });
                await _load();
              },
            ),
            const SizedBox(height: 8),
            const Text('Personalization ON होने पर चुनी हुई जन्म-कुंडली की चंद्र राशि Daily Rashifal की आधार राशि बनेगी; दशा, जन्म चंद्र/लग्न और दैनिक गोचर की संयुक्त व्याख्या नीचे दिखेगी। OFF करने पर राशि manually चुन सकते हैं।', style: TextStyle(fontSize: 12, color: _brown)),
            const SizedBox(height: 6),
          ],
          if (_deepProfile != null)
            Card(color: _card, child: ListTile(leading: const Icon(Icons.auto_awesome, color: _brown), title: Text('Personalized: ${_deepProfile!.name}'), subtitle: Text('आधार राशि: ${DailyRashifalEngine.rashis[_selected]} • जन्म-कुंडली आधारित'),)),
          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (_error != null)
            Card(color: _card, child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!)))
          else if (_result != null)
            _resultCard(_result!),
          if (_deepReading != null) _deepCard(_deepReading!),
        ],
      ),
    );
  }

  Widget _resultCard(DailyRashifalResult r) => Column(
    children: [
      Card(color: _card, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${r.rashi} — आज का संकेत', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _brown)),
        const SizedBox(height: 8),
        Text(r.theme, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        _line('💼 करियर', r.career),
        _line('💰 धन', r.money),
        _line('❤️ संबंध', r.love),
        _line('🧘 स्वास्थ्य', r.health),
        const Divider(),
        Text('शुभ अंक: ${r.luckyNumbers.join(' • ')}   •   प्रमुख: ${r.luckyNumber}   •   शुभ रंग: ${r.luckyColor}', style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text('गणना: ${r.luckyMethod}', style: const TextStyle(fontSize: 11)),
      ])),
      Card(color: _card, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('आज की गणना', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _brown)),
        const SizedBox(height: 8),
        Text('चंद्र राशि: ${r.moonSign} • सूर्य राशि: ${r.sunSign} • राहु: ${r.nodeSign}'),
        Text('तिथि: ${r.tithi} • नक्षत्र: ${r.nakshatra} • योग: ${r.yoga}'),
        Text('आपकी राशि से चंद्र ${r.moonHouse}वें, सूर्य ${r.sunHouse}वें और राहु ${r.nodeHouse}वें भाव-सदृश गोचर में।'),
        const SizedBox(height: 6),
        Text('गणना इंजन: ${r.calculationEngine}', style: const TextStyle(fontSize: 11)),
      ])),
      const SizedBox(height: 8),
      const Text('यह पारंपरिक राशि-आधारित फलादेश है। इसे व्यक्तिगत चिकित्सा, वित्तीय या कानूनी सलाह न मानें।', style: TextStyle(fontSize: 12)),
    ],
  );

  Widget _deepCard(DeepDailyReading d) => Card(
    color: _card,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🔮 Deep Astrological Interpretation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _brown)),
        const SizedBox(height: 6),
        Text('कुंडली: ${d.profileName}', style: const TextStyle(fontWeight: FontWeight.w800)),
        Text('वर्तमान दशा: ${d.dasha}', style: const TextStyle(fontWeight: FontWeight.w900, color: _brown)),
        const SizedBox(height: 4),
        Text('सूक्ष्मदशा: ${d.sukshmaDasha ?? '—'} • प्राणदशा: ${d.pranaDasha ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800, color: _brown)),
        const SizedBox(height: 4),
        Text('अष्टकवर्ग: ${d.ashtakavargaStrongest} • ${d.ashtakavargaSummary}', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 4),
        const Text('Vimshottari Dasha Integration: महादशा + अंतरदशा + उपलब्ध प्रत्यंतर + जन्म-भाव स्थिति', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Text(d.headline),
        const SizedBox(height: 10),
        _line('💼 करियर', d.career),
        _line('💰 धन', d.money),
        _line('❤️ संबंध', d.relationship),
        _line('🧘 स्वास्थ्य', d.health),
        const Divider(),
        const Text('क्यों?', style: TextStyle(fontWeight: FontWeight.w900, color: _brown)),
        const SizedBox(height: 4),
        ...d.evidence.map((e) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $e'))),
        const SizedBox(height: 6),
        Text('शुभ अंक: ${d.luckyNumbers.join(' • ')}   •   प्रमुख: ${d.luckyNumbers.first}', style: const TextStyle(fontWeight: FontWeight.w900)),
        Text('Lucky calculation: ${d.luckyMethod}', style: const TextStyle(fontSize: 11)),
        Text('आधार: ${d.luckyBasis.join(' | ')}', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 6),
        Text('गोचर: ${d.transitSummary}', style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 10),
        Card(
          color: Colors.white.withValues(alpha: 0.55),
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded, color: _brown),
              title: const Text('Large Premium Report', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('सूक्ष्मदशा • प्राणदशा • अष्टकवर्ग • Dasha • Transit • Lucky analysis'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumDailyReportScreen(reading: d))),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('यह पारंपरिक ज्योतिषीय interpretation है, निश्चित भविष्यवाणी नहीं। स्वास्थ्य/वित्तीय निर्णयों में वास्तविक विशेषज्ञ सलाह को प्राथमिकता दें।', style: TextStyle(fontSize: 11)),
      ]),
    ),
  );

  Widget _line(String title, String text) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _brown)), const SizedBox(height: 3), Text(text)]));
}
