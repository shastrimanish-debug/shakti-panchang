import 'package:speech_to_text/speech_to_text.dart';
import '../models/vedic_panchang.dart';
import '../models/panchang_boundaries.dart';
import 'uma_command_router.dart';
import 'uma_voice.dart';

class UmaAiService {
  final SpeechToText speech = SpeechToText();
  final UmaVoice _voice = UmaVoice.instance;

  Future<void> init() => _voice.init();

  Future<void> speak(String text) => _voice.speak(text);

  Future<String?> listen() async {
    final ok = await speech.initialize();
    if (!ok) return null;
    await speech.listen(listenOptions: SpeechListenOptions(localeId: 'hi_IN'));
    await Future.delayed(const Duration(seconds: 6));
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
