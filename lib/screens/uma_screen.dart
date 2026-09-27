import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/uma_decision.dart';
import '../models/kundali_model.dart';
import '../models/panchang_models.dart';
import '../services/uma_ai_service.dart';
import '../services/uma_vidvan_engine.dart';
import '../services/uma_app_intelligence.dart';
import '../services/uma_command_router.dart';
import '../services/location_store.dart';
import '../services/solar_service.dart';
import '../services/inauspicious_service.dart';
import '../services/choghadiya_service.dart';
import '../services/disha_service.dart';
import '../services/astronomical_panchang_service.dart';
import '../services/vedic_panchang_service.dart';
import '../services/kundali_calculator.dart';

import 'kundali_screen.dart';
import 'choghadiya_screen.dart';
import 'muhurat_screen.dart';
import 'yatra_screen.dart';
import 'panchang_detail_screen.dart';
import 'sade_sati_screen.dart';
import 'festivals_screen.dart';
import 'kundali_milan_screen.dart';

class _ChatMessage {
  final String role; // 'user' or 'uma'
  final String text;
  final DateTime timestamp;
  final String? action;
  final String? actionType;
  final List<String>? reasons;

  _ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.action,
    this.actionType,
    this.reasons,
  });
}

class UmaScreen extends StatefulWidget {
  final DateTime date;
  final KundaliData? kundali;
  final String? pageContext;
  final String? pageDescription;

  const UmaScreen({
    super.key,
    required this.date,
    this.kundali,
    this.pageContext,
    this.pageDescription,
  });

  @override
  State<UmaScreen> createState() => _UmaScreenState();
}

class _UmaScreenState extends State<UmaScreen> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final UmaAiService _uma = UmaAiService();
  final UmaAppIntelligence _appIntelligence = const UmaAppIntelligence();
  final UmaCommandRouter _router = const UmaCommandRouter();

  KundaliData? _activeKundali;
  UmaProfileSnapshot? _appContext;
  bool _loadingAppContext = true;
  bool _isProcessing = false;
  bool _isListening = false;
  String? _currentlySpeakingText;

  final List<_ChatMessage> _messages = [];

  static const List<String> _quickTopics = [
    'सम्पूर्ण कुंडली फलादेश',
    'करियर व आजीविका',
    'विवाह व मांगलिक विचार',
    'धन व आर्थिक योग',
    'शनि साढ़े साती विचार',
    'रोग व स्वास्थ्य उपाय',
    'आज का राहुकाल',
    'आज का चौघड़िया',
    'यात्रा व दिशाशूल',
    'आज का पंचांग',
    'आने वाले त्योहार',
  ];

  @override
  void initState() {
    super.initState();
    _activeKundali = widget.kundali;
    _initUma();
  }

  Future<void> _initUma() async {
    try {
      await _uma.init();
      var snapshot = await _appIntelligence.loadSavedContext(active: _activeKundali);
      if (_activeKundali == null && snapshot.savedProfiles.isNotEmpty) {
        final p = snapshot.savedProfiles.first;
        final rawDate = (p['date'] ?? p['birthDate'] ?? '').toString();
        final dateParts = rawDate.contains('T')
            ? rawDate.substring(0, 10).split('-')
            : rawDate.split('-');
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
          snapshot = await _appIntelligence.loadSavedContext(active: _activeKundali);
        }
      }
      _appContext = snapshot;
    } catch (_) {
      // safe fallback
    }

    if (!mounted) return;
    setState(() => _loadingAppContext = false);

    // Initial greeting or page context question
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.pageContext != null) {
        _safeAsk('इस पन्ने की जानकारी');
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              role: 'uma',
              text: UmaVidvanEngine.greeting,
              timestamp: DateTime.now(),
              action: 'कुंडली, करियर, विवाह, धन या आज का चौघड़िया पूछें।',
              actionType: 'open_kundali',
              reasons: const ['काशी-उज्जैन परंपरा की विदुषी ज्योतिषाचार्य'],
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scrollController.dispose();
    _uma.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _safeAsk([String? question]) async {
    final q = (question ?? _input.text).trim();
    if (q.isEmpty || _isProcessing) return;

    _input.clear();
    setState(() {
      _isProcessing = true;
      _messages.add(
        _ChatMessage(
          role: 'user',
          text: q,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();

    try {
      final snap = await _buildPanchangSnap();
      final reply = await _uma.queryUma(
        question: q,
        kundali: _activeKundali,
        panchang: snap,
        pageContext: widget.pageContext,
      );

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _messages.add(
          _ChatMessage(
            role: 'uma',
            text: reply.text,
            timestamp: DateTime.now(),
            action: reply.action,
            actionType: reply.actionType,
            reasons: reply.reasons,
          ),
        );
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _messages.add(
          _ChatMessage(
            role: 'uma',
            text: '॥ श्री गणेशाय नमः ॥\nगणना में तकनीकी अड़चन आई। कृपया एक बार पुनः पूछें।',
            timestamp: DateTime.now(),
            action: 'पुनः प्रयास करें',
          ),
        );
      });
      _scrollToBottom();
    }
  }

  Future<void> _voiceAsk() async {
    if (_isListening) {
      await _uma.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    final text = await _uma.listen();
    if (!mounted) return;
    setState(() => _isListening = false);

    if (text != null && text.trim().isNotEmpty) {
      _safeAsk(text.trim());
    }
  }

  Future<void> _toggleSpeak(String text) async {
    if (_currentlySpeakingText == text) {
      await _uma.stop();
      if (mounted) setState(() => _currentlySpeakingText = null);
    } else {
      await _uma.stop();
      if (mounted) setState(() => _currentlySpeakingText = text);
      await _uma.speak(text);
      if (mounted) setState(() => _currentlySpeakingText = null);
    }
  }

  Future<void> _shareConsultation() async {
    if (_messages.isEmpty) return;
    final lastUmaMsg = _messages.lastWhere(
      (m) => m.role == 'uma',
      orElse: () => _messages.first,
    );
    final lastUserMsg = _messages.lastWhere(
      (m) => m.role == 'user',
      orElse: () => _messages.first,
    );

    final snap = await _buildPanchangSnap();
    final report = _uma.buildConsultationReport(
      question: lastUserMsg.text,
      answer: lastUmaMsg.text,
      kundali: _activeKundali,
      panchang: snap,
    );

    await Share.share(
      report,
      subject: 'शक्ति पंचांग - उमा AI वैदिक परामर्श',
    );
  }

  Future<void> _handleAction(String? actionType) async {
    if (actionType == null) return;
    final now = widget.date;
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final place = loc?.name ?? 'उज्जैन';

    if (!mounted) return;

    switch (actionType) {
      case 'open_kundali':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const KundaliScreen()));
        break;
      case 'open_choghadiya':
        final solar = SolarService.forDate(date: now, latitude: lat, longitude: lon);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChoghadiyaScreen(
              date: now,
              solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise),
            ),
          ),
        );
        break;
      case 'open_muhurat':
        final solar = SolarService.forDate(date: now, latitude: lat, longitude: lon);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MuhuratScreen(
              date: now,
              solar: SolarTimes(sunrise: solar.sunrise, sunset: solar.sunset, nextSunrise: solar.nextSunrise),
            ),
          ),
        );
        break;
      case 'open_yatra':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YatraScreen(date: now, fromLat: lat, fromLon: lon, fromName: place),
          ),
        );
        break;
      case 'open_panchang':
        final realData = await AstronomicalPanchangService().calculate(date: now, latitude: lat, longitude: lon);
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PanchangDetailScreen(
              date: now,
              data: realData,
              lat: lat,
              lon: lon,
              place: place,
            ),
          ),
        );
        break;
      case 'open_sadesati':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SadeSatiScreen()));
        break;
      case 'open_festivals':
        Navigator.push(context, MaterialPageRoute(builder: (_) => FestivalsScreen(date: now)));
        break;
      case 'open_milan':
        if (_activeKundali != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KundaliMilanScreen(first: _activeKundali!),
            ),
          );
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const KundaliScreen()));
        }
        break;
    }
  }

  String _hm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<UmaPanchangSnap> _buildPanchangSnap() async {
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final place = loc?.name ?? 'उज्जैन';
    final solar = SolarService.forDate(date: widget.date, latitude: lat, longitude: lon);

    String paksha = '—', tithi = '—', nak = '—', yoga = '—', karana = '—', weekday = '—';
    try {
      final p = await VedicPanchangService().calculate(date: widget.date, latitude: lat, longitude: lon);
      weekday = p.weekday;
      paksha = p.paksha;
      tithi = p.tithi;
      nak = p.nakshatra;
      yoga = p.yoga;
      karana = p.karana;
    } catch (_) {
      weekday = const ['सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'][widget.date.weekday - 1];
    }

    final windows = InauspiciousService.daytime(solar.sunrise, solar.sunset, widget.date.weekday);
    String win(String title) {
      for (final w in windows) {
        if (w.title == title) return '${_hm(w.start)} से ${_hm(w.end)}';
      }
      return '—';
    }

    final day = ChoghadiyaService.day(solar, widget.date.weekday);
    final good = day.where((c) => c.nature == ChoghadiyaNature.auspicious).toList();
    final now = DateTime.now();
    String current = '';
    for (final c in day) {
      if (!now.isBefore(c.start) && now.isBefore(c.end)) {
        current = 'वर्तमान चौघड़िया: ${c.name} (${_hm(c.start)}–${_hm(c.end)})';
        break;
      }
    }

    final brahmaStart = solar.sunrise.subtract(const Duration(minutes: 96));
    final brahmaEnd = solar.sunrise.subtract(const Duration(minutes: 48));

    return UmaPanchangSnap(
      place: place,
      weekday: weekday,
      paksha: paksha,
      tithi: tithi,
      nakshatra: nak,
      yoga: yoga,
      karana: karana,
      sunrise: _hm(solar.sunrise),
      sunset: _hm(solar.sunset),
      rahuKaal: win('राहु काल'),
      yamaganda: win('यमगण्ड'),
      gulika: win('गुलिक काल'),
      shubhChoghadiya: good.isEmpty
          ? 'शुभ चौघड़िया'
          : good.map((c) => '${c.name} ${_hm(c.start)}–${_hm(c.end)}').join(', '),
      currentChoghadiya: current,
      dishaShool: DishaService.avoided(widget.date),
      brahmaMuhurat: '${_hm(brahmaStart)} से ${_hm(brahmaEnd)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF120B06) : const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C3A21),
        foregroundColor: const Color(0xFFFAF2E4),
        elevation: 1,
        title: Column(
          children: const [
            Text(
              'उमा — विदुषी ज्योतिषाचार्य',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            Text(
              'ॐ काशी-उज्जैन परंपरा • सनातन दैवज्ञ',
              style: TextStyle(fontSize: 10, color: Color(0xFFFFD88A), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'परामर्श साझा करें',
            onPressed: _shareConsultation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'नई बातचीत शुरू करें',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    role: 'uma',
                    text: UmaVidvanEngine.greeting,
                    timestamp: DateTime.now(),
                    action: 'कोई भी प्रश्न पूछें।',
                    actionType: 'open_kundali',
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Top Active Kundali Strip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF241913) : const Color(0xFFFFF9EE),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFB56A00).withValues(alpha: 0.25),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin, size: 16, color: Color(0xFFB56A00)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _activeKundali == null
                          ? 'सक्रिय जन्म पत्रिका: कोई नहीं (सामान्य फलादेश)'
                          : '${_activeKundali!.name} • लग्न: ${_activeKundali!.lagnaRashi} • चंद्र: ${_activeKundali!.moonRashi} • दशा: ${_activeKundali!.mahadasha}/${_activeKundali!.antardasha}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFFFD88A) : const Color(0xFF5C3A21),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_activeKundali == null)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const KundaliScreen()),
                      ),
                      child: const Text('बनाएँ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB56A00))),
                    ),
                ],
              ),
            ),

            // Chat Messages Stream
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg.role == 'user') {
                    return _buildUserBubble(msg, isDark);
                  } else {
                    return _buildUmaBubble(msg, isDark);
                  }
                },
              ),
            ),

            // Processing Indicator
            if (_isProcessing)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB56A00)),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'उमा शास्त्रीय गणना कर रही हैं…',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB56A00), fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),

            // Quick Topic Horizontal Chips
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickTopics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final topic = _quickTopics[i];
                  return ActionChip(
                    label: Text(topic, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: isDark ? const Color(0xFF2C1E16) : const Color(0xFFFFF9EE),
                    side: BorderSide(
                      color: const Color(0xFFB56A00).withValues(alpha: 0.35),
                    ),
                    onPressed: _isProcessing ? null : () => _safeAsk(topic),
                  );
                },
              ),
            ),

            // Input Bar with Safe Area
            Container(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E140E) : Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xFFEADBCC).withValues(alpha: 0.6)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Mic Voice Button
                  IconButton(
                    onPressed: _isProcessing ? null : _voiceAsk,
                    style: IconButton.styleFrom(
                      backgroundColor: _isListening
                          ? Colors.red
                          : (isDark ? const Color(0xFF332014) : const Color(0xFFFBF0DD)),
                      foregroundColor: _isListening ? Colors.white : const Color(0xFF8C4A00),
                    ),
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none_rounded),
                    tooltip: 'बोलकर पूछें',
                  ),
                  const SizedBox(width: 6),

                  // Text Field
                  Expanded(
                    child: TextField(
                      controller: _input,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (val) => _safeAsk(val),
                      decoration: InputDecoration(
                        hintText: 'पूछें: करियर, विवाह, धन, आज का राहुकाल…',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2B1D14) : const Color(0xFFFAF7F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: const Color(0xFFEADBCC)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide(color: const Color(0xFFEADBCC)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(color: Color(0xFFB56A00), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Send Button
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF5C3A21),
                      foregroundColor: const Color(0xFFFAF2E4),
                    ),
                    onPressed: _isProcessing ? null : () => _safeAsk(),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    tooltip: 'भेजें',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(_ChatMessage msg, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF5C3A21),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: const TextStyle(
            color: Color(0xFFFFF9EE),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildUmaBubble(_ChatMessage msg, bool isDark) {
    final isSpeaking = _currentlySpeakingText == msg.text;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF221710) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: const Color(0xFFEADBCC),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE69A33), Color(0xFFB56A00)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('ॐ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'उमा (UMA)',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isDark ? const Color(0xFFFFD88A) : const Color(0xFF5C3A21),
                        ),
                      ),
                      const Text(
                        'विदुषी ज्योतिषाचार्य',
                        style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                // Audio Speak/Stop Button
                IconButton(
                  icon: Icon(isSpeaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded, size: 20),
                  color: isSpeaking ? Colors.red : const Color(0xFFB56A00),
                  tooltip: isSpeaking ? 'रोकें' : 'सुनें',
                  onPressed: () => _toggleSpeak(msg.text),
                ),
                // Copy Button
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  color: Colors.grey,
                  tooltip: 'कॉपी करें',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('परामर्श क्लिपबोर्ड पर कॉपी हो गया'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 16),

            // Astrological Text with High Readability
            SelectableText(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFFAF2E4) : const Color(0xFF2C180C),
              ),
            ),

            // Reasons / Basis Chips
            if (msg.reasons != null && msg.reasons!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.reasons!.map((r) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF0DD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEADBCC)),
                  ),
                  child: Text(
                    r,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5C3A21)),
                  ),
                )).toList(),
              ),
            ],

            // Interactive Action Button (e.g. Open Kundali, Choghadiya, etc.)
            if (msg.action != null && msg.action!.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF4DF),
                    foregroundColor: const Color(0xFF5C3A21),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFB56A00), width: 1.2),
                    ),
                  ),
                  onPressed: () => _handleAction(msg.actionType),
                  icon: Icon(_actionIcon(msg.actionType), size: 18, color: const Color(0xFF8C4A00)),
                  label: Text(
                    msg.action!,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _actionIcon(String? type) => switch (type) {
        'open_kundali' => Icons.auto_awesome_rounded,
        'open_choghadiya' => Icons.access_time_filled_rounded,
        'open_muhurat' => Icons.timer_rounded,
        'open_yatra' => Icons.explore_rounded,
        'open_panchang' => Icons.calendar_month_rounded,
        'open_milan' => Icons.favorite_rounded,
        'open_sadesati' => Icons.nights_stay_rounded,
        'open_festivals' => Icons.festival_rounded,
        _ => Icons.arrow_forward_rounded,
      };
}
