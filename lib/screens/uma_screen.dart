import 'dart:async';
import 'package:flutter/material.dart';
import '../models/uma_decision.dart';
import '../models/panchang_models.dart';
import '../services/uma_command_router.dart';
import '../services/uma_decision_engine.dart';
import '../services/panchang_boundary_service.dart';
import '../services/disha_service.dart';
import '../services/uma_ai_service.dart';
import '../services/xalen_service.dart';
import '../models/kundali_model.dart';
import '../services/kundali_calculator.dart';
import '../services/uma_app_intelligence.dart';
import '../services/vedic_panchang_service.dart';
import '../services/location_store.dart';
import '../services/solar_service.dart';
import '../services/choghadiya_service.dart';
import '../services/inauspicious_service.dart';
import '../services/festival_service.dart';
import '../services/uma_vidvan_engine.dart';

class UmaScreen extends StatefulWidget {
  final DateTime date;
  final KundaliData? kundali;
  final String? pageContext;
  final String? pageDescription;
  const UmaScreen({super.key, required this.date, this.kundali, this.pageContext, this.pageDescription});

  @override
  State<UmaScreen> createState() => _UmaScreenState();
}

class _UmaScreenState extends State<UmaScreen> {
  final TextEditingController input = TextEditingController();
  final UmaCommandRouter router = const UmaCommandRouter();
  final UmaDecisionEngine engine = const UmaDecisionEngine();
  final AstronomyEngineService astronomyEngine = AstronomyEngineService();
  final UmaAiService uma = UmaAiService();
  final UmaAppIntelligence appIntelligence = const UmaAppIntelligence();
  final UmaVidvanEngine vidvan = const UmaVidvanEngine();
  KundaliData? _activeKundali;
  UmaProfileSnapshot? _appContext;
  bool _loadingAppContext = true;

  UmaDecision? decision;
  String? lastActivity;
  String? lastQuestion;
  bool isProcessing = false;

  String get _pageInfoQuestion => 'इस पन्ने की जानकारी';
  final List<Map<String, String>> chatHistory = [];

  @override
  void initState() {
    super.initState();
    _activeKundali = widget.kundali;
    _loadAppContext();
  }

  Future<void> _loadAppContext() async {
    try {
      var snapshot = await appIntelligence.loadSavedContext(active: _activeKundali);
      if (_activeKundali == null && snapshot.savedProfiles.isNotEmpty) {
        final p = snapshot.savedProfiles.first;
        final rawDate = (p['date'] ?? p['birthDate'] ?? '').toString();
        final dateParts = rawDate.contains('T') ? rawDate.substring(0, 10).split('-') : rawDate.split('-');
        final timeParts = (p['time'] ?? p['birthTime'] ?? '12:00').toString().split(':');
        if (dateParts.length == 3) {
          late final int day, month, year;
          if (rawDate.contains('T')) {
            year = int.tryParse(dateParts[0]) ?? DateTime.now().year;
            month = int.tryParse(dateParts[1]) ?? 1;
            day = int.tryParse(dateParts[2]) ?? 1;
          } else {
            day = int.tryParse(dateParts[0]) ?? 1;
            month = int.tryParse(dateParts[1]) ?? 1;
            year = int.tryParse(dateParts[2]) ?? DateTime.now().year;
          }
          final hour = int.tryParse(timeParts.first) ?? 12;
          final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
          final place = (p['place'] ?? p['birthPlace'] ?? '').toString();
          final lat = p['lat'] ?? p['latitude'];
          final lng = p['lng'] ?? p['longitude'];
          _activeKundali = await KundaliCalculator.calculate(
            name: p['name']?.toString() ?? 'जातक',
            birthDate: DateTime(year, month, day),
            birthTime: '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            birthPlace: place,
            latitude: lat is num ? lat.toDouble() : 0,
            longitude: lng is num ? lng.toDouble() : 0,
            timezoneHours: 5.5,
          );
          snapshot = await appIntelligence.loadSavedContext(active: _activeKundali);
        }
      }
      _appContext = snapshot;
    } catch (e) {
      _appContext = await appIntelligence.loadSavedContext(active: _activeKundali);
    }
    if (!mounted) return;
    setState(() => _loadingAppContext = false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.pageContext != null) {
        await _safeAsk(_pageInfoQuestion);
      } else {
        try {
          setState(() {
            chatHistory.add({'role': 'uma', 'message': UmaVidvanEngine.greeting});
            decision = UmaDecision(
              userQuestion: '',
              shortAnswer: UmaVidvanEngine.greeting,
              spokenAnswer: UmaVidvanEngine.greeting,
              level: UmaDecisionLevel.recommended,
              reasons: const ['उमा — काशी-उज्जैन परंपरा की विदुषी ज्योतिषाचार्य'],
              checks: const ['पंचांग, कुंडली, दशा, उपाय — कोई भी विषय पूछिए।'],
              action: 'राहुकाल, विवाह, करियर, धन या साढ़ेसाती बोलिए।',
            );
          });
          await uma.speak(UmaVidvanEngine.greeting);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> _safeAsk([String? question]) async {
    try {
      await ask(question);
    } catch (e) {
      if (!mounted) return;
      const message = 'थोड़ी अड़चन आई। एक बार और पूछ लेना।';
      setState(() {
        isProcessing = false;
        decision = UmaDecision(
          userQuestion: question ?? input.text,
          shortAnswer: message,
          spokenAnswer: message,
          level: UmaDecisionLevel.insufficientData,
          reasons: const ['UMA runtime error handled safely'],
          checks: const ['ऐप बंद नहीं होगा'],
          action: 'कृपया दोबारा पूछें।',
        );
        chatHistory.add({'role': 'uma', 'message': message});
      });
      try { await uma.speak(message); } catch (_) {}
    }
  }

  Future<void> ask([String? overrideQuestion]) async {
    final question = (overrideQuestion ?? input.text).trim();
    if (question.isEmpty) return;
    setState(() {
      isProcessing = true;
      chatHistory.add({'role': 'user', 'message': question});
    });
    input.clear();
    await uma.stop();
    final cmd = router.route(question);

    Future<void> finish(String reply) async {
      if (!mounted) return;
      setState(() {
        decision = UmaDecision(
          userQuestion: question,
          shortAnswer: reply,
          spokenAnswer: reply,
          level: UmaDecisionLevel.recommended,
          reasons: const ['विद्वान् उमा'],
          checks: const ['अगला सवाल पूछ सकते हो'],
          action: 'राहुकाल, दशा, त्योहार, यात्रा या कुंडली पूछो।',
        );
        chatHistory.add({'role': 'uma', 'message': reply});
        lastQuestion = question;
        isProcessing = false;
      });
      unawaited(uma.speak(reply));
    }

    try {
      if (_isPersonalDataQuestion(question)) {
        final extra = await appIntelligence.answerData(
          question,
          _appContext ?? await appIntelligence.loadSavedContext(active: _activeKundali),
          pageContext: widget.pageContext,
          pageDescription: widget.pageDescription,
        );
        await finish(extra);
        return;
      }
      lastActivity = cmd.activity;
      lastQuestion = question;
      if (cmd.intent == UmaIntent.festivals) {
        await finish(_festivalAnswer());
        return;
      }
      if (cmd.intent == UmaIntent.saved) {
        await finish(await _kundaliTopic(cmd.intent, question));
        return;
      }
      final snap = await _buildPanchangSnap();
      final reply = vidvan.answer(
        query: question,
        kundali: _activeKundali,
        panchang: snap,
        pageContext: widget.pageContext,
      );
      if (!mounted) return;
      setState(() {
        decision = UmaDecision(
          userQuestion: question,
          shortAnswer: reply.text,
          spokenAnswer: reply.text,
          level: UmaDecisionLevel.recommended,
          reasons: reply.reasons,
          checks: reply.checks,
          action: reply.action,
        );
        chatHistory.add({'role': 'uma', 'message': reply.text});
        lastQuestion = question;
        isProcessing = false;
      });
      unawaited(uma.speak(reply.text));
    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      await finish('हिसाब लगाते-लगाते रुक गई। फिर पूछो, अभी बताती हूँ।');
    }
  }

  bool _isPersonalDataQuestion(String q) {
    final t = q.toLowerCase();
    const keys = ['मेरा डेटा', 'मेरा data', 'मेरा डाटा', 'mera data', 'my data', 'डेटा बता', 'data बता', 'डाटा बता', 'data batao', 'डेटा बताओ', 'पूरा data', 'पूरा डेटा', 'all data', 'मैंने क्या', 'क्या डेटा', 'क्या data'];
    return keys.any(t.contains);
  }

  String _hm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<UmaPanchangSnap> _buildPanchangSnap() async {
    final ps = await _placeSolar();
    final place = ps.loc?.name ?? 'उज्जैन';
    final lat = ps.loc?.latitude ?? 23.1765;
    final lon = ps.loc?.longitude ?? 75.7885;
    String paksha = '—', tithi = '—', nak = '—', yoga = '—', karana = '—', weekday = '—';
    try {
      final p = await VedicPanchangService().calculate(date: widget.date, latitude: lat, longitude: lon);
      weekday = p.weekday; paksha = p.paksha; tithi = p.tithi; nak = p.nakshatra; yoga = p.yoga; karana = p.karana;
    } catch (_) {
      weekday = const ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'][widget.date.weekday - 1];
    }
    final windows = InauspiciousService.daytime(ps.solar.sunrise, ps.solar.sunset, ps.weekday);
    String win(String title) {
      for (final w in windows) {
        if (w.title == title) return '${_hm(w.start)} से ${_hm(w.end)} तक';
      }
      return '—';
    }
    final day = ChoghadiyaService.day(ps.solar, ps.weekday);
    final good = day.where((c) => c.nature == ChoghadiyaNature.auspicious).toList();
    final now = DateTime.now();
    String current = '';
    for (final c in day) {
      if (!now.isBefore(c.start) && now.isBefore(c.end)) {
        current = 'वर्तमान चौघड़िया: ${c.name} (${_hm(c.start)}–${_hm(c.end)})';
        break;
      }
    }
    final brahmaStart = ps.solar.sunrise.subtract(const Duration(minutes: 96));
    final brahmaEnd = ps.solar.sunrise.subtract(const Duration(minutes: 48));
    return UmaPanchangSnap(
      place: place,
      weekday: weekday,
      paksha: paksha,
      tithi: tithi,
      nakshatra: nak,
      yoga: yoga,
      karana: karana,
      sunrise: _hm(ps.solar.sunrise),
      sunset: _hm(ps.solar.sunset),
      rahuKaal: win('राहु काल'),
      yamaganda: win('यमगण्ड'),
      gulika: win('गुलिक काल'),
      shubhChoghadiya: good.isEmpty ? 'सूची तैयार हो रही है' : good.map((c) => '${c.name} ${_hm(c.start)}–${_hm(c.end)}').join(', '),
      currentChoghadiya: current,
      dishaShool: DishaService.avoided(widget.date),
      brahmaMuhurat: '${_hm(brahmaStart)} से ${_hm(brahmaEnd)} तक',
    );
  }

  Future<({SavedLocation? loc, SolarTimes solar, int weekday})> _placeSolar() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final solar = SolarService.forDate(date: widget.date, latitude: lat, longitude: lon);
    return (loc: loc, solar: solar, weekday: widget.date.weekday);
  }

  Future<String> _kundaliTopic(UmaIntent intent, String question) async {
    final ctx = _appContext ?? await appIntelligence.loadSavedContext(active: _activeKundali);
    _appContext = ctx;
    if (intent == UmaIntent.saved) return ctx.describeSavedData();
    if (_activeKundali == null && ctx.savedProfiles.isEmpty) {
      return 'यह कुंडली वाला सवाल है। पहले कुंडली अध्याय में जन्म विवरण भरें।';
    }
    return appIntelligence.answerData(question, ctx, pageContext: widget.pageContext, pageDescription: widget.pageDescription);
  }

  String _festivalAnswer() {
    final up = FestivalService.upcoming(DateTime.now(), count: 6);
    if (up.isEmpty) return 'त्योहार सूची तैयार नहीं हुई।';
    return 'आने वाले पर्व: ${up.map((f) => '${f.name} (${f.date.day}/${f.date.month})').join(', ')}।';
  }

  Future<void> voiceAsk() async {
    final q = await uma.listen();
    if (q == null || q.trim().isEmpty) return;
    input.text = q;
    await _safeAsk(q);
  }

  String level(UmaDecisionLevel x) => switch (x) {
    UmaDecisionLevel.excellent => '🟢 अति उत्तम',
    UmaDecisionLevel.recommended => '🟢 अनुकूल एवं शुभ',
    UmaDecisionLevel.caution => '🟡 सावधानी',
    UmaDecisionLevel.avoid => '🔴 टालना श्रेयस्कर',
    UmaDecisionLevel.insufficientData => '⚪ जानकारी चाहिए',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('उमा — विदुषी ज्योतिषाचार्य'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'चैट रीसेट करें',
          onPressed: () => setState(() {
            decision = null;
            lastActivity = null;
            chatHistory.clear();
          }),
        ),
      ],
    ),
    body: Column(
      children: [
        if (_loadingAppContext)
          const LinearProgressIndicator(minHeight: 2)
        else
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB56A00)),
            ),
            child: Text(
              _activeKundali == null
                  ? 'उमा: अभी active कुंडली नहीं है। सेव प्रोफाइल खोलें तो चार्ट पढ़ेगी।'
                  : 'उमा: ${_activeKundali!.name} • ${_activeKundali!.lagnaRashi} लग्न • ${_activeKundali!.moonRashi} चंद्र • ${_activeKundali!.nakshatra} • दशा ${_activeKundali!.mahadasha}/${_activeKundali!.antardasha}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('उमा से बात करो',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
                      const SizedBox(height: 6),
                      const Text('काशी-उज्जैन परंपरा की विदुषी — पंचांग, कुंडली, दशा और सात्विक उपाय।', style: TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (widget.pageContext != null)
                            ActionChip(
                              avatar: const Icon(Icons.menu_book_rounded, size: 18),
                              label: const Text('इस पन्ने की पूरी जानकारी'),
                              onPressed: isProcessing ? null : () => _safeAsk(_pageInfoQuestion),
                            ),
                          ...[
                            'आज राहुकाल',
                            'आज चौघड़िया',
                            'आज का पंचांग',
                            'पूरी कुंडली बताओ',
                            'अभी कौन सी दशा है?',
                            'करियर कैसा रहेगा?',
                            'विवाह योग है?',
                            'धन योग बताओ',
                            'साढ़ेसाती चल रही है?',
                            'स्वास्थ्य उपाय',
                            'मेरे ग्रह कहाँ हैं?',
                            'आज के त्योहार',
                            'दिशाशूल',
                            'मेरी saved कुंडलियाँ बताओ',
                          ].map((q) => ActionChip(
                            label: Text(q),
                            onPressed: isProcessing ? null : () => _safeAsk(q),
                          )),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: input,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'जैसे: आज निकलना ठीक है? करियर कैसा रहेगा?',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFFFFBF4),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7A3E00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isProcessing ? null : () => _safeAsk(),
                              icon: isProcessing
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.auto_awesome),
                              label: Text(isProcessing ? 'उमा सोच रही है…' : 'उमा से पूछो'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF7A3E00)),
                            onPressed: isProcessing ? null : voiceAsk,
                            icon: const Icon(Icons.mic, color: Colors.white),
                            tooltip: 'बोलकर पूछें',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (decision != null) ...[
                const SizedBox(height: 14),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: const Color(0xFFFFFDF9),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Color(0xFF7A3E00)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(level(decision!.level), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(decision!.shortAnswer, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4)),
                        const SizedBox(height: 14),
                        const Text('📜 ज्योतिषीय आधार:', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
                        const SizedBox(height: 6),
                        ...decision!.reasons.map((x) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(child: Text(x, style: const TextStyle(height: 1.3))),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFDF3E6), borderRadius: BorderRadius.circular(10)),
                          child: Text(decision!.action, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5A3815))),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
