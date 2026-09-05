import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/vedic_panchang.dart';
import '../models/panchang_boundaries.dart';
import 'uma_command_router.dart';

class UmaAiService {
  final FlutterTts tts = FlutterTts();
  final SpeechToText speech = SpeechToText();

  Future<void> init() async {
    await tts.setLanguage('hi-IN');
    await tts.setSpeechRate(0.46);
    await tts.setPitch(1.02);
    await tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await init();
    await tts.stop();
    await tts.speak(text);
  }

  Future<String?> listen() async {
    final ok = await speech.initialize();
    if (!ok) return null;
    
    // Yaha sahi parameter 'listenOptions' use kiya hai!
    await speech.listen(listenOptions: SpeechListenOptions(localeId: 'hi_IN'));
    
    await Future.delayed(const Duration(seconds: 6));
    await speech.stop();
    return speech.lastRecognizedWords.isEmpty ? null : speech.lastRecognizedWords;
  }

  Future<void> stop() => tts.stop();

  Future<void> speakPanchang(VedicPanchang p) async {
    await speak(
      'आज ${p.weekday} है। ${p.paksha}, ${p.tithi}, नक्षत्र ${p.nakshatra}, '
      'योग ${p.yoga} और करण ${p.karana} है। अयनांश ${p.ayanamsha} रखा गया है।'
    );
  }

  Future<void> speakBoundaries(DailyPanchangBoundaries b) async {
    await speak(
      'आज ${b.tithi.currentName} तिथि ${b.tithi.end.hour} बजकर ${b.tithi.end.minute} मिनट तक है। '
      'नक्षत्र ${b.nakshatra.currentName} ${b.nakshatra.end.hour} बजकर ${b.nakshatra.end.minute} मिनट तक है। '
      'योग ${b.yoga.currentName} और करण ${b.karana.currentName} है।'
    );
  }

  String contextualReply(String question, UmaCommand command) {
    final q = question.toLowerCase().trim();

    switch (command.intent) {
      case UmaIntent.rahu:
        return 'आप आज के राहु काल, यमगण्ड और गुलिक काल के बारे में पूछ रहे हैं। '
            'मैं इन्हें आज के स्थानीय सूर्य समय के आधार पर बताऊँगी।';
      case UmaIntent.choghadiya:
        return 'आप चौघड़िया पूछ रहे हैं। मैं दिन और रात के चौघड़िया अलग-अलग, '
            'शुरू और खत्म होने के समय के साथ बताऊँगी।';
      case UmaIntent.dishashool:
        return 'आप यात्रा की दिशा और दिशाशूल पूछ रहे हैं। पहले आज की वर्जित दिशा '
            'देखेंगे, फिर आपकी जाने वाली दिशा से मिलाकर बताएँगे कि यात्रा शुभ है या नहीं।';
      case UmaIntent.sunriseSunset:
        return 'आप सूर्योदय और सूर्यास्त का समय पूछ रहे हैं। ये स्थान और तारीख के '
            'अनुसार बदलते हैं, इसलिए मैं ऐप की चुनी हुई location और date का समय दूँगी।';
      case UmaIntent.panchang:
        return 'आप आज के पंचांग के बारे में पूछ रहे हैं। मैं वार, तिथि, पक्ष, '
            'नक्षत्र, योग और करण को साथ में समझाकर बताऊँगी।';
      case UmaIntent.explanation:
        return 'आप किसी पंचांग शब्द या नियम का अर्थ समझना चाहते हैं। '
            'उमा सिर्फ नाम नहीं बताएगी, बल्कि उसका मतलब और व्यवहार में उसका उपयोग भी समझाएगी।';
      case UmaIntent.activity:
        return 'मैंने आपके सवाल को “${command.activity}” से संबंधित समझा है। '
            'अब उसी काम के लिए उपलब्ध शुभ समय और जरूरी पंचांग जाँच देखेंगे।';
      case UmaIntent.help:
        if (q.length > 0) {
          return 'मैंने आपका सवाल पढ़ लिया है। उसमें अभी कोई स्पष्ट पंचांग विषय '
              'नहीं मिला। आप अपना सवाल जैसे मन में आता है वैसे ही पूछिए—उदाहरण के लिए '
              '“कल सुबह निकलना ठीक रहेगा?”, “गाड़ी कब खरीदूँ?”, “आज कौन सा समय अच्छा है?” '
              'या “दिशाशूल क्यों लगता है?”। मैं सवाल का आशय समझकर सही जानकारी तक ले जाऊँगी।';
        }
        return 'मैं उमा हूँ। आप मुझसे अपने शब्दों में सवाल पूछ सकते हैं।';
    }
  }

  String answerIntent(String q) {
    final command = const UmaCommandRouter().route(q);
    if (command == null) {
      return 'मैं उमा हूँ। अपना सवाल अपने शब्दों में पूछिए।';
    }
    return contextualReply(q, command);
  }
}
