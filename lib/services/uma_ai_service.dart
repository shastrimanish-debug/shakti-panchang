import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import '../models/vedic_panchang.dart';
import '../models/panchang_boundaries.dart';
import '../models/kundali_model.dart';
import 'uma_command_router.dart';
import 'uma_voice.dart';
import 'uma_vidvan_engine.dart';

class UmaAiService {
  final SpeechToText speech = SpeechToText();
  final UmaVoice _voice = UmaVoice.instance;
  final UmaVidvanEngine _engine = const UmaVidvanEngine();

  Future<void> init() => _voice.init();
  Future<void> speak(String text) => _voice.speak(text);

  Future<String?> listen() async {
    final ok = await speech.initialize();
    if (!ok) return null;
    await speech.listen(listenOptions: SpeechListenOptions(localeId: 'hi_IN'));
    await Future.delayed(const Duration(seconds: 5));
    await speech.stop();
    return speech.lastRecognizedWords.isEmpty ? null : speech.lastRecognizedWords;
  }

  Future<void> stop() => _voice.stop();

  Future<void> speakPanchang(VedicPanchang p) async {
    await speak(
      'आज ${p.weekday} है। ${p.paksha} ${p.tithi}, नक्षत्र ${p.nakshatra}, '
      'योग ${p.yoga}, करण ${p.karana}।',
    );
  }

  Future<void> speakBoundaries(DailyPanchangBoundaries b) async {
    await speak(
      'तिथि ${b.tithi.currentName} ${b.tithi.end.hour} बजकर ${b.tithi.end.minute} तक। '
      'नक्षत्र ${b.nakshatra.currentName} ${b.nakshatra.end.hour} बजकर ${b.nakshatra.end.minute} तक।',
    );
  }

  /// Unified Intelligent Query Handler for Uma
  /// Attempts Gemini AI call if API key exists, otherwise seamlessly
  /// executes deep local Vedic engine.
  Future<UmaVidvanReply> queryUma({
    required String question,
    KundaliData? kundali,
    UmaPanchangSnap? panchang,
    String? pageContext,
    String? geminiApiKey,
  }) async {
    final cleanQ = question.trim();
    if (cleanQ.isEmpty) {
      return const UmaVidvanReply(text: UmaVidvanEngine.greeting);
    }

    // Try online Gemini API if key is present
    if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
      try {
        final onlineReply = await _callGemini(
          query: cleanQ,
          apiKey: geminiApiKey,
          kundali: kundali,
          panchang: panchang,
        );
        if (onlineReply != null && onlineReply.isNotEmpty) {
          final actionType = _inferActionType(cleanQ);
          return UmaVidvanReply(
            text: onlineReply,
            action: _actionLabel(actionType),
            actionType: actionType,
            reasons: const ['काशी-उज्जैन परंपरा Gemini दैवज्ञ ज्ञानपीठ'],
            checks: const ['अचूक वैदिक व ज्योतिषीय नियमों पर आधारित'],
          );
        }
      } catch (_) {
        // Fallback gracefully to offline engine
      }
    }

    // 100% Offline Deep Vedic Engine
    return _engine.answer(
      query: cleanQ,
      kundali: kundali,
      panchang: panchang,
      pageContext: pageContext,
    );
  }

  Future<String?> _callGemini({
    required String query,
    required String apiKey,
    KundaliData? kundali,
    UmaPanchangSnap? panchang,
  }) async {
    final models = ['gemini-2.5-flash', 'gemini-2.0-flash', 'gemini-1.5-flash'];
    final kundaliInfo = kundali != null
        ? 'जातक: ${kundali.name}, लग्न: ${kundali.lagnaRashi}, चंद्र राशि: ${kundali.moonRashi}, नक्षत्र: ${kundali.nakshatra}, महादशा: ${kundali.mahadasha}, अंतर्दशा: ${kundali.antardasha}'
        : 'कोई कुंडली अभी लोड नहीं है।';
    final panchangInfo = panchang != null
        ? 'स्थान: ${panchang.place}, वार: ${panchang.weekday}, तिथि: ${panchang.paksha} ${panchang.tithi}, नक्षत्र: ${panchang.nakshatra}, राहुकाल: ${panchang.rahuKaal}'
        : 'पंचांग डेटा सामान्य है।';

    const systemInstruction =
        'आप उमा (UMA) हैं — शक्ति सनातन वैदिक पंचांग की काशी-उज्जैन परंपरा से दीक्षित विदुषी दैवज्ञ व ज्योतिषाचार्य। '
        'उत्तर में आदरणीय, गंभीर, स्नेहमयी व विद्वान शैली रखें। मंगलाचरण (॥ श्री गणेशाय नमः ॥) से आरंभ करें, '
        'प्रामाणिक संस्कृत श्लोक व सरल हिन्दी भावार्थ दें, कुंडली व पंचांग का सूक्ष्म विश्लेषण करें, '
        'तथा सकारात्मक सात्विक उपाय बताएं। कभी भय न फैलाएं।';

    final prompt =
        'यजमान का प्रश्न: "$query"\n\n'
        '[कुंडली संदर्भ]: $kundaliInfo\n'
        '[पंचांग संदर्भ]: $panchangInfo\n\n'
        'कृपया शास्त्रीय वैदिक फलादेश, श्लोक व सात्विक उपाय प्रदान करें।';

    for (final model in models) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );
        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [{'text': prompt}]
                  }
                ],
                'systemInstruction': {
                  'parts': [{'text': systemInstruction}]
                },
              }),
            )
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final parts = candidates.first['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.first['text'] as String?;
              if (text != null && text.trim().isNotEmpty) {
                return text.trim();
              }
            }
          }
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  String? _inferActionType(String query) {
    final q = query.toLowerCase();
    if (q.contains('कुंडली') || q.contains('दशा') || q.contains('लग्न') || q.contains('kundali')) {
      return 'open_kundali';
    }
    if (q.contains('चौघड़िया') || q.contains('choghadiya')) {
      return 'open_choghadiya';
    }
    if (q.contains('मुहूर्त') || q.contains('राहु')) {
      return 'open_muhurat';
    }
    if (q.contains('यात्रा') || q.contains('दिशाशूल') || q.contains('travel')) {
      return 'open_yatra';
    }
    if (q.contains('मिलान') || q.contains('विवाह') || q.contains('शादी')) {
      return 'open_milan';
    }
    if (q.contains('साढ़ेसाती') || q.contains('शनि')) {
      return 'open_sadesati';
    }
    if (q.contains('त्योहार') || q.contains('व्रत') || q.contains('एकादशी')) {
      return 'open_festivals';
    }
    return 'open_panchang';
  }

  String _actionLabel(String? actionType) => switch (actionType) {
        'open_kundali' => 'सम्पूर्ण कुंडली चक्र विस्तार से देखें',
        'open_choghadiya' => 'चौघड़िया तालिका देखें',
        'open_muhurat' => 'शुभ मुहूर्त व काल देखें',
        'open_yatra' => 'यात्रा व दिशाशूल कैलकुलेटर',
        'open_milan' => 'कुंडली मिलान (३६ गुण)',
        'open_sadesati' => 'शनि साढ़े साती चक्र',
        'open_festivals' => 'व्रत व त्योहार सूची',
        _ => 'दैनिक पंचांग देखें',
      };

  String buildConsultationReport({
    required String question,
    required String answer,
    KundaliData? kundali,
    UmaPanchangSnap? panchang,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    final name = kundali?.name ?? 'जातक';
    return '॥ श्री गणेशाय नमः ॥\n'
        '🕉️ शक्ति सनातन पंचांग — उमा AI दैवज्ञ परामर्श रिपोर्ट\n'
        'तारीख: $dateStr | स्थान: ${panchang?.place ?? 'उज्जैन'}\n'
        '--------------------------------------------\n'
        'यजमान: $name\n'
        '${kundali != null ? 'लग्न: ${kundali.lagnaRashi} | राशि: ${kundali.moonRashi} | दशा: ${kundali.mahadasha}\n' : ''}'
        'प्रश्न: $question\n\n'
        'परामर्श व शास्त्रीय फलादेश:\n'
        '$answer\n'
        '--------------------------------------------\n'
        '॥ शुभम् भवतु • आपका कल्याण हो ॥\n'
        'शक्ति पंचांग (Shakti Panchang)';
  }

  String contextualReply(String question, UmaCommand command) {
    switch (command.intent) {
      case UmaIntent.rahu:
        return 'राहुकाल पूछ रहे हो। आज का समय अभी निकालती हूँ — उसमें नया काम मत लगाना।';
      case UmaIntent.choghadiya:
        return 'चौघड़िया देखती हूँ। अमृत, शुभ और लाभ में काम अच्छा लगता है।';
      case UmaIntent.dishashool:
        return 'दिशाशूल देखती हूँ। जिस दिशा में शूल हो, उधर से नई यात्रा मत निकालना।';
      case UmaIntent.sunriseSunset:
        return 'सूर्योदय-सूर्यास्त तुम्हारे चुने शहर के हिसाब से बताती हूँ।';
      case UmaIntent.panchang:
        return 'आज का पंचांग खोलती हूँ — तिथि, नक्षत्र, योग, करण सब।';
      case UmaIntent.explanation:
        return 'सीधी भाषा में समझाती हूँ। पूछो, उलझाऊँगी नहीं।';
      case UmaIntent.activity:
        return '${command.activity} के लिए शुभ बेला देखती हूँ।';
      case UmaIntent.help:
        return 'नमस्ते, मैं उमा हूँ। राहुकाल, चौघड़िया, कुंडली, यात्रा — जो पूछना हो बोलिए।';
      case UmaIntent.dasha:
        return 'दशा देखती हूँ — कुंडली बनी हो तो अभी की महादशा बताऊँगी।';
      case UmaIntent.sadesati:
        return 'साढ़ेसाती शनि से जुड़ी है। कुंडली हो तो बताती हूँ, नहीं तो पहले जन्म पत्रिका बनाओ।';
      case UmaIntent.graha:
        return 'ग्रह-भाव कुंडली से पढ़ती हूँ।';
      case UmaIntent.kp:
        return 'के.पी. कस्प कुंडली मॉड्यूल में खुलता है।';
      case UmaIntent.jaimini:
        return 'जैमिनी कारक कुंडली से बताती हूँ।';
      case UmaIntent.festivals:
        return 'आज और आगे के त्योहार बताती हूँ।';
      case UmaIntent.kundali:
        return 'कुंडली अध्याय खोलो, जन्म विवरण भरो — फिर ग्रह और दशा बताऊँगी।';
      case UmaIntent.saved:
        return 'सेव कुंडलियाँ देखती हूँ।';
      case UmaIntent.page:
        return 'इस पन्ने की बात बताती हूँ।';
    }
  }

  String answerIntent(String q) {
    final command = const UmaCommandRouter().route(q);
    return contextualReply(q, command);
  }
}
