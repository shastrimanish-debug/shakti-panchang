import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'kundali_screen.dart';
import 'panchang_detail_screen.dart'; 
import 'muhurat_screen.dart';
import 'yatra_screen.dart';
import 'uma_screen.dart';
import 'festivals_screen.dart';
import 'reminder_screen.dart';
import 'shubh_samay_screen.dart';

import '../models/panchang_models.dart';
import '../services/solar_service.dart'; 
import '../services/vedic_panchang_service.dart'; 
import '../services/panchang_boundary_service.dart';
import '../services/disha_service.dart';
import '../services/xalen_service.dart';

const Color _bhojBg = Color(0xFFF4E8D1);
const Color _bhojCard = Color(0xFFFAF2E4);
const Color _bhojBrown = Color(0xFF5C3A21);
const Color _bhojBorder = Color(0xFF8C6239);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  void _openUmaChat() {
    _speak("नमस्ते! शक्ति पंचांग में आपका स्वागत है।");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UmaScreen(date: DateTime.now())),
    );
  }

  void _openPanchang() async {
    final now = DateTime.now();
    final panchangService = VedicPanchangService();
    final realData = await panchangService.calculate(date: now, latitude: 23.1765, longitude: 75.7885);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => PanchangDetailScreen(date: now, data: realData)));
  }

  void _openMuhurat() {
    final now = DateTime.now();
    final solar = SolarService.forDate(date: now, latitude: 23.1765, longitude: 75.7885);
    Navigator.push(context, MaterialPageRoute(builder: (_) => MuhuratScreen(date: now, solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise))));
  }

  void _openYatra() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => YatraScreen(date: DateTime.now(), fromLat: 23.1765, fromLon: 75.7885, fromName: 'Ujjain')));
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: _bhojBg,
      appBar: AppBar(
        backgroundColor: _bhojBrown,
        foregroundColor: _bhojBg,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Shakti Panchang',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 0.5),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              '📜 सनातन वैदिक ग्रंथ एवं पंचांग',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _bhojBrown),
            ),
          ),
          const SizedBox(height: 20),

          // उमा वॉयस असिस्टेंट स्मार्ट कार्ड
          _buildUmaVoiceAssistantCard(context),
          const SizedBox(height: 20),

          // 1. Kundali Button
          _homeNavCard(
            context,
            title: 'कुंडली निर्माण एवं विश्लेषण',
            subtitle: 'जन्म विवरण डालें और सम्पूर्ण कुंडली ग्रंथ बनाएं',
            icon: Icons.auto_awesome_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KundaliScreen()));
            },
          ),
          const SizedBox(height: 16),

          // 2. Panchang Button
          _homeNavCard(
            context,
            title: 'दैनिक पंचांग (Panchang)',
            subtitle: 'आज की तिथि, नक्षत्र, योग, करण और सूर्य स्थिति',
            icon: Icons.calendar_month_rounded,
            onTap: _openPanchang,
          ),
          const SizedBox(height: 16),

          // 3. Shubh Muhurat Button 
          _homeNavCard(
            context,
            title: 'शुभ मुहूर्त (Shubh Muhurat)',
            subtitle: 'विवाह, गृहप्रवेश और नए कार्यों के लिए श्रेष्ठ समय',
            icon: Icons.access_time_filled_rounded,
            onTap: _openMuhurat,
          ),
          const SizedBox(height: 16),

          // 4. Yatra Muhurat & Dishashool Button
          _homeNavCard(
            context,
            title: 'यात्रा मुहूर्त & दिशाशूल',
            subtitle: 'आज का दिशाशूल और यात्रा के लिए शुभ दिशा',
            icon: Icons.alt_route_rounded,
            onTap: _openYatra,
          ),
          const SizedBox(height: 16),

          // 5. Festivals Button
          _homeNavCard(
            context,
            title: 'व्रत एवं त्योहार (Festivals)',
            subtitle: 'आगामी व्रत, एकादशी, पूर्णिमा और पर्व सूची',
            icon: Icons.festival_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FestivalsScreen(date: now)));
            },
          ),
          const SizedBox(height: 16),

          // 6. Shubh Samay Button
          _homeNavCard(
            context,
            title: 'श्रेष्ठ एवं अशुभ समय (Choghadiya)',
            subtitle: 'दिन और रात के चौघड़िया व राहुकाल की जानकारी',
            icon: Icons.timer_rounded,
            onTap: () async {
              try {
                final astronomyEngine = AstronomyEngineService();
                final p = await PanchangBoundaryService(astronomyEngine).calculate(now);
                final dShool = DishaService.avoided(now);
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShubhSamayScreen(
                      date: now,
                      panchang: p,
                      dishaShool: dShool,
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('शुभ समय लोड करने में त्रुटि: $e')),
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // 7. Reminders Button
          _homeNavCard(
            context,
            title: 'स्मार्ट रिमाइंडर (Reminders)',
            subtitle: 'व्रत और शुभ मुहूर्तों के लिए अलार्म व सूचनाएं',
            icon: Icons.notifications_active_rounded,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReminderScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUmaVoiceAssistantCard(BuildContext context) {
    return InkWell(
      onTap: _openUmaChat,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bhojCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _bhojBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x335C3A21),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: _bhojBrown,
              child: Icon(
                Icons.mic_rounded, 
                color: _bhojBg, 
                size: 34,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'नमस्ते, मैं उमा हूँ! 🎙️',
                    style: TextStyle(fontWeight: FontWeight.w900, color: _bhojBrown, fontSize: 17),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'टैप करके मुझसे ज्योतिषीय चर्चा करें...',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _openUmaChat,
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: _bhojBrown, size: 22),
              tooltip: 'उमा से चैट करें',
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeNavCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Card(
      color: _bhojCard,
      elevation: 4,
      shadowColor: const Color(0x335C3A21),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _bhojBorder, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: _bhojBg,
                child: Icon(icon, color: _bhojBrown, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900, color: _bhojBrown, fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: _bhojBorder),
            ],
          ),
        ),
      ),
    );
  }
}
