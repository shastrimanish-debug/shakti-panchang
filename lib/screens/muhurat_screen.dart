import 'package:flutter/material.dart';
import '../models/panchang_models.dart';
import '../services/muhurat_engine.dart';

class MuhuratScreen extends StatefulWidget {
  final SolarTimes solar;
  final DateTime date;

  const MuhuratScreen({
    super.key,
    required this.solar,
    required this.date,
  });

  @override
  State<MuhuratScreen> createState() => _MuhuratScreenState();
}

class _MuhuratScreenState extends State<MuhuratScreen> {
  MuhuratActivity activity = MuhuratActivity.naming;
  final engine = MuhuratEngine();

  String label(MuhuratActivity a) => switch (a) {
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

  String detail(MuhuratActivity a) => switch (a) {
        MuhuratActivity.general => 'सामान्य कार्यों के लिए उपलब्ध पारंपरिक शुभ विंडो',
        MuhuratActivity.travel => 'यात्रा से पहले दिशाशूल और यात्रा-दिशा जरूर जाँचें',
        MuhuratActivity.business => 'नया व्यापार/लेन-देन के लिए उपयोगी विंडो',
        MuhuratActivity.vehiclePurchase => 'वाहन खरीद/पूजन के लिए उपयोगी विंडो',
        MuhuratActivity.property => 'भूमि/प्रॉपर्टी संबंधी कार्य के लिए उपयोगी विंडो',
        MuhuratActivity.houseEntry => 'गृह प्रवेश के लिए प्राथमिक समय-विंडो',
        MuhuratActivity.education => 'अध्ययन/विद्यारंभ के लिए प्राथमिक समय-विंडो',
        MuhuratActivity.naming => 'नामकरण के लिए प्राथमिक समय-विंडो',
        MuhuratActivity.marriage => 'विवाह के लिए प्रारंभिक समय-विंडो',
      };

  @override
  Widget build(BuildContext context) {
    final list = engine.forActivity(
      activity: activity,
      solar: widget.solar,
      weekday: widget.date.weekday,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('🙏 काम के अनुसार मुहूर्त')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<MuhuratActivity>(
            initialValue: activity,
            decoration: const InputDecoration(
              labelText: 'किस काम के लिए?',
              border: OutlineInputBorder(),
            ),
            items: MuhuratActivity.values
                .map(
                  (a) => DropdownMenuItem(
                    value: a,
                    child: Text(label(a)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => activity = v);
            },
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                detail(activity),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ...list.map(
            (m) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.auto_awesome),
                ),
                title: Text(
                  m.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  '${_fmt(m.start)} – ${_fmt(m.end)}\n${m.description}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'महत्वपूर्ण: यह स्क्रीन अब काम के अनुसार अलग-अलग समय-विंडो दिखाती है। '
            'विवाह, गृह प्रवेश, नामकरण, प्रॉपर्टी आदि के लिए अंतिम शास्त्रीय मुहूर्त '
            'तय करने में तिथि, नक्षत्र, योग, करण, लग्न, चंद्रबल, ताराबल और क्षेत्रीय '
            'नियम भी लागू होने चाहिए। इन्हें अगली पूर्ण मुहूर्त engine में जोड़ा जाएगा।',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Powered by SHIV SHAKTI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
