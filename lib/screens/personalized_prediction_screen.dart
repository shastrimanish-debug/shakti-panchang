import 'package:flutter/material.dart';
import '../models/kundali_model.dart';
import '../services/uma_prediction_engine.dart';

const Color _bg = Color(0xFFF4E8D1);
const Color _card = Color(0xFFFAF2E4);
const Color _brown = Color(0xFF5C3A21);

class PersonalizedPredictionScreen extends StatelessWidget {
  final KundaliData data;
  const PersonalizedPredictionScreen({super.key, required this.data});

  @override Widget build(BuildContext context) {
    final predictions = const UmaPredictionEngine().all(data);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _brown,
        foregroundColor: _bg,
        title: const Text('मेरी Personal Prediction', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            color: _card,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _brown)),
                  const SizedBox(height: 5),
                  Text('लग्न ${data.lagnaRashi} • चंद्र ${data.moonRashi} • ${data.nakshatra}'),
                  Text('वर्तमान दशा: ${data.mahadasha} / ${data.antardasha}'),
                  const SizedBox(height: 8),
                  const Text('यह reading आपकी जन्म-कुंडली के उपलब्ध भाव, ग्रह और दशा संकेतों से तैयार होती है; यह generic राशिफल नहीं है।', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...predictions.map((p) => Card(
            color: _card,
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              title: Text(p.area, style: const TextStyle(fontWeight: FontWeight.w900, color: _brown)),
              subtitle: Text(p.headline),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                Align(alignment: Alignment.centerLeft, child: Text('क्यों: ${p.why}')),
                const SizedBox(height: 7),
                Align(alignment: Alignment.centerLeft, child: Text('समय: ${p.period}', style: const TextStyle(fontWeight: FontWeight.w700))),
                const SizedBox(height: 7),
                Align(alignment: Alignment.centerLeft, child: Text('संकेत: ${p.strength}')),
                const SizedBox(height: 7),
                Align(alignment: Alignment.centerLeft, child: Text('मार्गदर्शन: ${p.guidance}')),
                const SizedBox(height: 7),
                Align(alignment: Alignment.centerLeft, child: Text('सावधानी: ${p.caution}', style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
          const SizedBox(height: 6),
          const Text('ज्योतिषीय prediction को पारंपरिक मार्गदर्शन मानें। स्वास्थ्य, निवेश, ऋण, कानूनी या अन्य महत्वपूर्ण निर्णयों के लिए संबंधित विशेषज्ञ की सलाह लें.', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
