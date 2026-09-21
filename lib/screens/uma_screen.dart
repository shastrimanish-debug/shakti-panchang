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
  KundaliData? _activeKundali;
  UmaProfileSnapshot? _appContext;
  bool _loadingAppContext = true;

  UmaDecision? decision;
  String? lastActivity;
  String? lastQuestion;
  bool isProcessing = false;

  String get _pageInfoQuestion => widget.pageContext == null
      ? 'मेरा पूरा data बताओ'
      : 'मैं अभी ${widget.pageContext} पेज पर हूँ। इस पेज की पूरी जानकारी, उपलब्ध data, मुख्य बिंदु और इसे कैसे समझें बताओ।';
  
  // Advanced Conversational History for Memory
  final List<Map<String, String>> chatHistory = [];

  @override
  void initState() {
    super.initState();
    _activeKundali = widget.kundali;
    _loadAppContext();
  }

  Future<void> _loadAppContext() async {
    try {
      // Load the saved snapshot once. The previous implementation loaded the
      // same store twice, which could delay the first UMA response and made
      // failures harder to diagnose.
      var snapshot = await appIntelligence.loadSavedContext(
        active: _activeKundali,
      );

      if (_activeKundali == null && snapshot.savedProfiles.isNotEmpty) {
        final p = snapshot.savedProfiles.first;
        final rawDate = (p['date'] ?? p['birthDate'] ?? '').toString();
        final dateParts = rawDate.contains('T')
            ? rawDate.substring(0, 10).split('-')
            : rawDate.split('-');
        final timeParts =
            (p['time'] ?? p['birthTime'] ?? '12:00').toString().split(':');

        if (dateParts.length == 3) {
          final int day;
          final int month;
          final int year;
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
          final minute =
              timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;
          final place = (p['place'] ?? p['birthPlace'] ?? '').toString();
          final lat = p['lat'] ?? p['latitude'];
          final lng = p['lng'] ?? p['longitude'];

          _activeKundali = await KundaliCalculator.calculate(
            name: p['name']?.toString() ?? 'जातक',
            birthDate: DateTime(year, month, day),
            birthTime:
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
            birthPlace: place,
            latitude: lat is num ? lat.toDouble() : 0,
            longitude: lng is num ? lng.toDouble() : 0,
            timezoneHours: 5.5,
          );

          snapshot = await appIntelligence.loadSavedContext(
            active: _activeKundali,
          );
        }
      }

      _appContext = snapshot;
    } catch (e) {
      // UMA must remain usable even if a saved profile is corrupt or the
      // native chart engine is temporarily unavailable.
      _appContext = await appIntelligence.loadSavedContext(
        active: _activeKundali,
      );
    }

    if (!mounted) return;
    setState(() => _loadingAppContext = false);

    // When UMA is opened from a book page, immediately explain that page and
    // speak the answer. When opened standalone, give a short audible greeting.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.pageContext != null) {
        await _safeAsk(_pageInfoQuestion);
      } else {
        try {
          await uma.speak('नमस्ते! मैं उमा हूँ। आप मुझसे अपने शब्दों में सवाल पूछ सकते हैं।');
        } catch (_) {
          // TTS is optional; text interaction remains available.
        }
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
      setState(() => isProcessing = false);
      const message = 'उमा को उत्तर तैयार करते समय एक अस्थायी समस्या आई। कृपया फिर से पूछें।';
      setState(() {
        decision = UmaDecision(
          userQuestion: question ?? input.text,
          shortAnswer: message,
          spokenAnswer: message,
          level: UmaDecisionLevel.insufficientData,
          reasons: const ['UMA runtime error handled safely'],
          checks: const ['ऐप बंद नहीं होगा; अगला प्रश्न फिर से पूछा जा सकता है।'],
          action: 'कृपया दोबारा पूछें।',
        );
        chatHistory.add({'role': 'uma', 'message': message});
      });
      try {
        await uma.speak(message);
      } catch (_) {
        // TTS failure must never lock the UMA UI.
      }
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
          reasons: const ['प्रत्येक प्रश्न का स्वतंत्र उत्तर'],
          checks: const ['अगला सवाल तुरंत पूछ सकते हैं'],
          action: 'राहुकाल, चौघड़िया, कुंडली, यात्रा या मुहूर्त पूछें।',
        );
        chatHistory.add({'role': 'uma', 'message': reply});
        lastQuestion = question;
        isProcessing = false;
      });
      unawaited(uma.speak(reply));
    }

    try {
    // Personal data / "मेरा डेटा बताओ"
    if (_isPersonalDataQuestion(question)) {
      final overview = await _liveOverview();
      final appContext = _appContext ??
          await appIntelligence.loadSavedContext(active: _activeKundali);
      _appContext = appContext;
      final extra = await appIntelligence.answerData(
        question,
        appContext,
        pageContext: widget.pageContext,
        pageDescription: widget.pageDescription,
      );
      await finish('$overview\n\n$extra');
      return;
    }

    // 0. App-aware UMA: answer from actual saved/calculated app data first.
    final appContext = _appContext;
    if (appContext != null) {
      final appReply = await appIntelligence.answerData(question, appContext, pageContext: widget.pageContext, pageDescription: widget.pageDescription);
      final softwareReply = appIntelligence.answerSoftware(question);
      final dataQuestion = question.toLowerCase();
      final asksApp = ['software', 'app', 'feature', 'मॉड्यूल', 'ऐप में', 'कुंडली', 'लग्न', 'महादशा', 'अष्टकवर्ग', 'शड्बल', 'd1', 'd9', 'd60', 'kp', 'jaimini', 'लाल किताब', 'जातक'].any(dataQuestion.contains);
      if (asksApp) {
        final reply = appIntelligence.isSoftwareQuestion(question) ? softwareReply : appReply;
        await finish(reply);
        return;
      }
    }

    if (cmd != null && cmd.intent == UmaIntent.help && lastActivity != null) {
      await finish(_advancedFollowUpReply(question));
      return;
    }

    if (cmd == null) {
      await finish(await _liveOverview());
      return;
    }

    if (cmd.intent == UmaIntent.help) {
      await finish(await _factualOrOverview(question));
      return;
    }

    if (cmd.intent != UmaIntent.activity) {
      await finish(await _factualForIntent(cmd));
      return;
    }

    lastActivity = cmd.activity;
    lastQuestion = question;

    final p = await PanchangBoundaryService(astronomyEngine).calculate(widget.date);
    final d = engine.decide(
      question: question,
      activity: cmd.activity,
      when: widget.date,
      panchang: p,
      dishaShool: DishaService.avoided(widget.date),
    );
    await finish('${d.spokenAnswer} ${d.reasons.take(4).join(' ')}');
    } catch (e) {
      if (!mounted) return;
      setState(() => isProcessing = false);
      await finish('उमा को इस प्रश्न पर गणना करते समय देर हो गई। कृपया फिर पूछें।');
    }
  }

  bool _isPersonalDataQuestion(String q) {
    final t = q.toLowerCase();
    const keys = [
      'मेरा डेटा',
      'मेरा data',
      'मेरा डाटा',
      'mera data',
      'my data',
      'डेटा बता',
      'data बता',
      'डाटा बता',
      'data batao',
      'डेटा बताओ',
      'पूरा data',
      'पूरा डेटा',
      'all data',
      'मैंने क्या',
      'क्या डेटा',
      'क्या data',
    ];
    return keys.any(t.contains);
  }

  Future<String> _liveOverview() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final place = loc?.name ?? 'उज्जैन';
    String panchangLine;
    try {
      final p = await VedicPanchangService().calculate(
        date: widget.date,
        latitude: lat,
        longitude: lon,
      );
      panchangLine =
          'आज $place में ${p.weekday} है। ${p.paksha} ${p.tithi}, नक्षत्र ${p.nakshatra}, योग ${p.yoga}, करण ${p.karana}।';
    } catch (_) {
      panchangLine = 'आज का पंचांग $place के लिए तैयार हो रहा है।';
    }
    final saved = _appContext?.describeSavedData() ??
        'सेव कुंडली अभी नहीं खुली। कुंडली अध्याय में जन्म विवरण भरें।';
    return '$panchangLine $saved आप राहुकाल, चौघड़िया, कुंडली या यात्रा पूछ सकते हैं।';
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<({SavedLocation? loc, SolarTimes solar, int weekday})> _placeSolar() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final solar = SolarService.forDate(date: widget.date, latitude: lat, longitude: lon);
    return (loc: loc, solar: solar, weekday: widget.date.weekday);
  }

  Future<String> _factualForIntent(UmaCommand cmd) async {
    final ps = await _placeSolar();
    final place = ps.loc?.name ?? 'उज्जैन';
    switch (cmd.intent) {
      case UmaIntent.rahu:
        final w = InauspiciousService.daytime(ps.solar.sunrise, ps.solar.sunset, ps.weekday);
        return 'आज $place में ${w.map((x) => '${x.title} ${_hm(x.start)} से ${_hm(x.end)} तक').join('। ')}। इन काल में नया शुभ कार्य न करें।';
      case UmaIntent.choghadiya:
        final day = ChoghadiyaService.day(ps.solar, ps.weekday);
        final good = day.where((c) => c.nature == ChoghadiyaNature.auspicious).toList();
        return 'आज $place के शुभ चौघड़िया: ${good.map((c) => '${c.name} ${_hm(c.start)}–${_hm(c.end)}').join(', ')}। अमृत, शुभ और लाभ में कार्य श्रेष्ठ हैं।';
      case UmaIntent.dishashool:
        final dir = DishaService.avoided(widget.date);
        return 'आज दिशाशूल $dir दिशा में है। इस दिशा में नई यात्रा शुरू न करें। अन्य दिशाएँ सामान्यतः ठीक हैं।';
      case UmaIntent.sunriseSunset:
        final brahmaStart = ps.solar.sunrise.subtract(const Duration(minutes: 96));
        final brahmaEnd = ps.solar.sunrise.subtract(const Duration(minutes: 48));
        return 'आज $place में सूर्योदय ${_hm(ps.solar.sunrise)}, सूर्यास्त ${_hm(ps.solar.sunset)}। ब्रह्म मुहूर्त ${_hm(brahmaStart)} से ${_hm(brahmaEnd)} तक।';
      case UmaIntent.panchang:
      case UmaIntent.explanation:
      case UmaIntent.help:
      case UmaIntent.activity:
        return _liveOverview();
    }
  }

  Future<String> _factualOrOverview(String question) async {
    final q = question.toLowerCase();
    if (q.contains('राहु') || q.contains('यमगंड') || q.contains('गुलिक')) {
      return _factualForIntent(UmaCommand('सामान्य शुभ कार्य', question, intent: UmaIntent.rahu));
    }
    if (q.contains('चौघड़िया') || q.contains('choghadiya')) {
      return _factualForIntent(UmaCommand('सामान्य शुभ कार्य', question, intent: UmaIntent.choghadiya));
    }
    if (q.contains('दिशा') || q.contains('यात्रा')) {
      return _factualForIntent(UmaCommand('यात्रा', question, intent: UmaIntent.dishashool));
    }
    if (q.contains('सूर्य')) {
      return _factualForIntent(UmaCommand('सामान्य शुभ कार्य', question, intent: UmaIntent.sunriseSunset));
    }
    return _liveOverview();
  }

  String _advancedFollowUpReply(String q) {
    final a = lastActivity!;
    final lower = q.toLowerCase();
    if (lower.contains('क्यों') || lower.contains('kyu') || lower.contains('why')) {
      return 'आपने $a के संबंध में कारण पूछा है। पंचांग और होरा शास्त्र के अनुसार, इस काल में ग्रहों की स्थिति और नक्षत्र प्रभाव के आधार पर यह निर्णय लिया गया है।';
    }
    if (lower.contains('सुबह') || lower.contains('morning')) {
      return 'समझ गई। $a के लिए प्रातःकालीन बेला अधिक ऊर्जावान और शुभ मानी जाती है। मैं तदनुसार सर्वोत्तम प्रातःकालीन चौघड़िया विंडो प्राथमिकता में रख रही हूँ।';
    }
    if (lower.contains('कल') || lower.contains('tomorrow')) {
      return 'ठीक है, अब मैं $a के लिए कल के पंचांग और सूर्योदय गणना को संदर्भ मानकर चल रही हूँ।';
    }
    return 'मैंने आपके प्रश्न को पिछले प्रसंग "$a" के साथ जोड़ दिया है। आप बेझिझक समय, कारण या दिशा के बारे में पूछ सकती हैं।';
  }

  Future<void> voiceAsk() async {
    final q = await uma.listen();
    if (q == null || q.trim().isEmpty) return;
    input.text = q;
    await _safeAsk(q);
  }

  String level(UmaDecisionLevel x) => switch (x) {
    UmaDecisionLevel.excellent => '🟢 अति उत्तम (श्रेस्ठ मुहूर्त)',
    UmaDecisionLevel.recommended => '🟢 अनुकूल एवं शुभ',
    UmaDecisionLevel.caution => '🟡 मध्यम / सावधानी आवश्यक',
    UmaDecisionLevel.avoid => '🔴 इस समय टालना श्रेयस्कर है',
    UmaDecisionLevel.insufficientData => '⚪ अतिरिक्त जानकारी चाहिए',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('🤖 उमा — Advanced AI आचार्य सहायक'),
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
              widget.pageContext != null
                  ? 'उमा V12 पन्ना संदर्भ: ${widget.pageContext!}${widget.pageDescription == null ? '' : '\n${widget.pageDescription!}'}\n\n${_activeKundali == null ? 'अभी active Kundali नहीं है।' : 'Active Kundali: ${_activeKundali!.name} • ${_activeKundali!.lagnaRashi} लग्न • ${_activeKundali!.moonRashi} चंद्र • ${_activeKundali!.nakshatra} • दशा ${_activeKundali!.mahadasha}/${_activeKundali!.antardasha}'}'
                  : _activeKundali == null
                      ? 'उमा V12 Context: अभी active Kundali नहीं है। Saved profile खोलने पर UMA वास्तविक chart data पढ़ेगी।'
                      : 'उमा V12 Context: ${_activeKundali!.name} • ${_activeKundali!.lagnaRashi} लग्न • ${_activeKundali!.moonRashi} चंद्र • ${_activeKundali!.nakshatra} • वर्तमान दशा ${_activeKundali!.mahadasha}/${_activeKundali!.antardasha}',
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
                      const Text('उमा से संवाद करें',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
                      const SizedBox(height: 6),
                      const Text('मुहूर्त, यात्रा, कार्यसिद्धि या ज्योतिषीय संशय पूछें...', style: TextStyle(fontSize: 13, color: Colors.black54)),
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
                          ...['मेरा पूरा data बताओ', 'अभी कौन सी दशा है?', 'साढ़ेसाती चल रही है?', 'मेरे ग्रह कहाँ हैं?', 'KP cusp बताओ', 'Jaimini बताओ', 'मेरी saved कुंडलियाँ बताओ'].map((q) => ActionChip(
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
                          hintText: 'उदा: कल व्यापार की शुरुआत के लिए कौन सा समय सबसे अच्छा रहेगा?',
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
                              label: Text(isProcessing ? 'उमा सोच रही हैं...' : 'उमा से पूछें'),
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
                            Text(level(decision!.level),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(decision!.shortAnswer,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.4)),
                        const SizedBox(height: 14),
                        const Text('📜 ज्योतिषीय आधार (क्यों?):',
                            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
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
                        const Text('🔍 विशेष सावधानियां / जाँच:',
                            style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF7A3E00))),
                        const SizedBox(height: 6),
                        ...decision!.checks.map((x) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✓ ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              Expanded(child: Text(x, style: const TextStyle(height: 1.3))),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF3E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(decision!.action,
                              style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF5A3815))),
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
