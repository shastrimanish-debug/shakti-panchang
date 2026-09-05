import 'package:flutter/material.dart';
import '../models/kundali_model.dart';
import '../services/ashtakoot_service.dart';
import '../services/kundali_calculator.dart';
import 'location_search_screen.dart';

class KundaliMilanScreen extends StatefulWidget {
  final KundaliData first;
  const KundaliMilanScreen({super.key, required this.first});

  @override
  State<KundaliMilanScreen> createState() => _KundaliMilanScreenState();
}

class _KundaliMilanScreenState extends State<KundaliMilanScreen> {
  final _name = TextEditingController();
  final _place = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  double _lat = 23.1765;
  double _lng = 72.5714;
  bool _loading = false;
  AshtakootResult? _result;

  static const brown = Color(0xFF5C3A21);
  static const bg = Color(0xFFF4E8D1);
  static const card = Color(0xFFFAF2E4);
  static const border = Color(0xFF8C6239);

  @override
  void dispose() {
    _name.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_name.text.trim().isEmpty || _place.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('दूसरे जातक का नाम और जन्म स्थान भरें।')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final formatted = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
      final second = await KundaliCalculator.calculate(
        name: _name.text.trim(), birthDate: _date, birthTime: formatted,
        birthPlace: _place.text.trim(), latitude: _lat, longitude: _lng,
        timezoneHours: 5.5,
      );
      final result = AshtakootService.calculate(widget.first, second);
      if (mounted) setState(() { _result = result; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('मिलान गणना में त्रुटि: $e')));
      }
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationSearchScreen()));
    if (result is Map<String, dynamic>) {
      setState(() {
        _place.text = result['name']?.toString() ?? '';
        _lat = (result['lat'] as num?)?.toDouble() ?? _lat;
        _lng = (result['lng'] as num?)?.toDouble() ?? _lng;
      });
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(backgroundColor: brown, foregroundColor: bg, title: const Text('कुंडली मिलान – 36 गुण', style: TextStyle(fontWeight: FontWeight.w900))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('प्रथम जातक', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: brown)),
            const SizedBox(height: 8),
            Text(widget.first.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('चंद्र राशि: ${widget.first.moonRashi} • नक्षत्र: ${widget.first.nakshatra} • नाड़ी: ${widget.first.nadi}'),
          ])),
          const SizedBox(height: 12),
          _card(Column(children: [
            const Align(alignment: Alignment.centerLeft, child: Text('दूसरे जातक का जन्म विवरण', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: brown))),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'नाम', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _place, readOnly: true, onTap: _pickLocation, decoration: const InputDecoration(labelText: 'जन्म स्थान', border: OutlineInputBorder(), suffixIcon: Icon(Icons.location_on_rounded, color: brown))),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _pickDate, child: Text('${_date.day}-${_date.month}-${_date.year}'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: _pickTime, child: Text(_time.format(context)))),
            ]),
            const SizedBox(height: 8),
            const Text('नोट: जन्म स्थान की सटीक latitude/longitude देने पर गणना अधिक उपयुक्त रहेगी। अभी default coordinates को बदला जा सकता है।', style: TextStyle(fontSize: 11, color: Colors.black54)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: brown, foregroundColor: bg),
              onPressed: _loading ? null : _calculate,
              icon: _loading ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.favorite_rounded),
              label: const Text('36 गुण का मिलान करें', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ])),
          if (_result != null) ...[
            const SizedBox(height: 12),
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Text('${_result!.total.toStringAsFixed(1)} / 36', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: brown))),
              const SizedBox(height: 5),
              Center(child: Text(_result!.verdict, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
              const Divider(height: 24),
              ..._result!.items.map((x) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.name, style: const TextStyle(fontWeight: FontWeight.w900, color: brown)), Text(x.note, style: const TextStyle(fontSize: 11))])),
                  Text('${x.score.toStringAsFixed(1)}/${x.max.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ]),
              )),
              const Text('विवाह निर्णय के लिए केवल गुण-योग पर निर्भर न रहें; मंगल, सप्तम भाव, शुक्र/गुरु, नाड़ी/भकूट और दोनों कुंडलियों के संयुक्त संकेत भी देखें।', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ])),
          ],
        ],
      ),
    );
  }

  Widget _card(Widget child) => Card(color: card, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: border)), child: Padding(padding: const EdgeInsets.all(16), child: child));
}
