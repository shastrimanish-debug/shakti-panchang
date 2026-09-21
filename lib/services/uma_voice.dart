import 'package:flutter_tts/flutter_tts.dart';

/// उमा की वाणी — युवा, स्त्री, मंदिर-मार्गदर्शक। धीमी राजनीतिक TTS नहीं।
class UmaVoice {
  UmaVoice._();
  static final UmaVoice instance = UmaVoice._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await _tts.awaitSpeakCompletion(false);
    await _tts.setLanguage('hi-IN');
    await _tts.setVolume(1.0);
    // Android: 0.5 ≈ सामान्य। 0.45 सोनीया-स्टाइल धीमी थी।
    await _tts.setSpeechRate(0.54);
    await _tts.setPitch(1.22);
    await _pickYoungHindiFemale();
    _ready = true;
  }

  Future<void> _pickYoungHindiFemale() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;
      final voices = raw
          .whereType<Map>()
          .map((v) => {
                'name': '${v['name'] ?? ''}',
                'locale': '${v['locale'] ?? ''}'.toLowerCase(),
              })
          .where((v) => v['locale']!.startsWith('hi'))
          .toList();
      if (voices.isEmpty) return;

      int score(Map<String, String> v) {
        final n = v['name']!.toLowerCase();
        var s = 0;
        if (n.contains('female') || n.contains('fem')) s += 50;
        if (n.contains('hie') || n.contains('hfc') || n.contains('hic')) s += 30;
        if (n.contains('inid') || n.contains('india')) s += 10;
        if (n.contains('local')) s += 8;
        if (n.contains('network')) s += 4;
        if (n.contains('male') || n.contains('hid')) s -= 40;
        return s;
      }

      voices.sort((a, b) => score(b).compareTo(score(a)));
      final best = voices.first;
      await _tts.setVoice({'name': best['name']!, 'locale': 'hi-IN'});
    } catch (_) {
      // default hi-IN engine voice
    }
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    final spoken = forSpeech(text);
    if (spoken.isEmpty) return;
    await _tts.speak(spoken);
  }

  Future<void> stop() => _tts.stop();

  /// बोलने लायक छोटा, सरल हिन्दी। लंबा शास्त्र-व्याख्यान नहीं।
  static String forSpeech(String raw) {
    var t = raw
        .replaceAll(RegExp(r'[*#`_]'), '')
        .replaceAll('\n', '। ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('मैंने आपका सवाल पढ़ लिया है।', '')
        .replaceAll('मैंने आपके सवाल को', 'तुम पूछ रहे हो')
        .replaceAll('बताऊँगी', 'बताती हूँ')
        .replaceAll('समझाएगी', 'समझाती हूँ')
        .replaceAll('देखेंगे', 'देखो')
        .replaceAll('Shakti Panchang', 'शक्ति पंचांग')
        .replaceAll('UMA', 'उमा')
        .replaceAll('software', 'ऐप')
        .trim();
    if (t.length > 360) {
      final cut = t.substring(0, 360);
      final last = cut.lastIndexOf('।');
      t = (last > 80 ? cut.substring(0, last + 1) : cut) + ' बाकी स्क्रीन पर पढ़ लो।';
    }
    return t;
  }
}
