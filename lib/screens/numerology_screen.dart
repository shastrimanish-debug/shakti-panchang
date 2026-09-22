import 'package:flutter/material.dart';
import '../services/numerology_service.dart';

const Color _bg = Color(0xFFF4E8D1);
const Color _card = Color(0xFFFAF2E4);
const Color _brown = Color(0xFF5C3A21);

class NumerologyScreen extends StatefulWidget {
  const NumerologyScreen({super.key});
  @override State<NumerologyScreen> createState() => _NumerologyScreenState();
}

class _NumerologyScreenState extends State<NumerologyScreen> {
  final _name = TextEditingController();
  DateTime _dob = DateTime(1990, 1, 1);
  NumerologyResult? _result;

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _dob, firstDate: DateTime(1900), lastDate: DateTime.now());
    if (d != null) setState(() => _dob = d);
  }

  void _calculate() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया नाम दर्ज करें।')));
      return;
    }
    setState(() => _result = NumerologyService.calculate(name: _name.text.trim(), birthDate: _dob));
  }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(backgroundColor: _brown, foregroundColor: _bg, title: const Text('अंक ज्योतिष (Numerology)', style: TextStyle(fontWeight: FontWeight.w900))),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _field('नाम (English spelling)', _name, Icons.person_outline_rounded),
      const SizedBox(height: 12),
      Card(color: _card, child: ListTile(leading: const Icon(Icons.cake_rounded, color: _brown), title: Text('जन्म तिथि: ${_dob.day}-${_dob.month}-${_dob.year}'), trailing: const Icon(Icons.edit_calendar_rounded, color: _brown), onTap: _pickDate)),
      const SizedBox(height: 14),
      FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: _brown), onPressed: _calculate, icon: const Icon(Icons.auto_awesome), label: const Text('अंक गणना करें')),
      const SizedBox(height: 18),
      if (_result != null) ...[
        _numberCard('मूलांक', _result!.mulank, 'जन्म की तारीख से निकला मुख्य अंक'),
        _numberCard('भाग्यांक / Life Path', _result!.bhagyank, 'पूरी जन्म तिथि के योग से'),
        _numberCard('Expression / Destiny', _result!.expression, 'नाम के अक्षरों के Pythagorean योग से'),
        _numberCard('Soul / Heart', _result!.soul, 'नाम के vowels से'),
        _numberCard('Personality', _result!.personality, 'नाम के consonants से'),
        _numberCard('Chaldean Name', _result!.chaldeanName, 'नाम के Chaldean letter values से'),
        Card(
          color: _card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('शुभ अंक', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _brown)),
                const SizedBox(height: 8),
                Text(_result!.luckyNumbers.join(' • '), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text('नोट: अंक ज्योतिष पारंपरिक/आध्यात्मिक interpretation है; इसे निश्चित भविष्यवाणी या वित्तीय/स्वास्थ्य निर्णय का आधार न बनाएं।', style: TextStyle(fontSize: 12)),
      ],
    ]),
  );

  Widget _field(String label, TextEditingController c, IconData icon) => TextField(controller: c, decoration: InputDecoration(filled: true, fillColor: _card, prefixIcon: Icon(icon, color: _brown), labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
  Widget _numberCard(String title, int number, String subtitle) => Card(color: _card, margin: const EdgeInsets.only(bottom: 10), child: ListTile(leading: CircleAvatar(backgroundColor: _brown, foregroundColor: _bg, child: Text('$number', style: const TextStyle(fontWeight: FontWeight.w900))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: _brown)), subtitle: Text(subtitle)));
}
