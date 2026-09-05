import 'package:flutter/material.dart';
import '../models/muhurat_result.dart';
import '../models/panchang_boundaries.dart';
import '../services/muhurat_rules_v9.dart';

class ShubhSamayScreen extends StatefulWidget {
  final DailyPanchangBoundaries panchang;
  final DateTime date;
  final String? dishaShool;

  const ShubhSamayScreen({
    super.key,
    required this.panchang,
    required this.date,
    required this.dishaShool,
  });

  @override
  State<ShubhSamayScreen> createState() => _ShubhSamayScreenState();
}

class _ShubhSamayScreenState extends State<ShubhSamayScreen> {
  final rules = const MuhuratRulesV9();
  String activity = 'सामान्य शुभ कार्य';

  static const activities = [
    'सामान्य शुभ कार्य',
    'यात्रा',
    'नया व्यापार',
    'वाहन खरीद',
    'भूमि / प्रॉपर्टी',
    'गृह प्रवेश',
    'शिक्षा',
    'नामकरण',
    'विवाह',
  ];

  String _grade(MuhuratGrade g) => switch (g) {
    MuhuratGrade.excellent => 'बहुत शुभ',
    MuhuratGrade.good => 'शुभ संकेत',
    MuhuratGrade.neutral => 'मिश्रित',
    MuhuratGrade.avoid => 'सावधानी',
  };

  @override
  Widget build(BuildContext context) {
    final result = rules.evaluate(
      activity: activity,
      when: widget.date,
      panchang: widget.panchang,
      dishaShool: widget.dishaShool,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('✨ शुभ समय सलाह')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: activity,
            decoration: const InputDecoration(
              labelText: 'किस काम के लिए?',
              border: OutlineInputBorder(),
            ),
            items: activities.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() => activity = v ?? activity),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_grade(result.grade),
                      style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(result.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  const Text('सकारात्मक संकेत',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  ...result.positives.map((x) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(x),
                  )),
                  const Text('सावधानियाँ',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                  ...result.cautions.map((x) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.info_outline),
                    title: Text(x),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'V9 का score conservative screening है। विवाह, गृह प्रवेश, नामकरण, '
            'प्रॉपर्टी आदि के लिए पूर्ण लग्न/दोष/स्थानीय परंपरा filtering को अंतिम accuracy gate में रखना जरूरी है।',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
