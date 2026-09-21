import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'uma_voice_text.dart';

/// फ़ोन: गूगल हिन्दी ऑडियो, फेल हो तो सिर्फ़ hi-IN इंजन। अंग्रेज़ी वॉइस बंद।
class UmaVoice {
  UmaVoice._();
  static final UmaVoice instance = UmaVoice._();

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
    await _prepareHindiTts();
  }

  Future<void> _prepareHindiTts() async {
    if (_ttsReady) return;
    await _tts.awaitSpeakCompletion(false);
    try {
      await _tts.setEngine('com.google.android.tts');
    } catch (_) {}
    await _tts.setLanguage('hi-IN');
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    final ios = defaultTargetPlatform == TargetPlatform.iOS;
    await _tts.setSpeechRate(ios ? 0.47 : 0.48);
    await _lockHindiVoice();
    _ttsReady = true;
  }

  Future<void> _lockHindiVoice() async {
    try {
      final raw = await _tts.getVoices;
      if (raw is! List) return;
      Map<String, String>? best;
      var bestScore = -999;
      for (final item in raw) {
        if (item is! Map) continue;
        final name = '${item['name'] ?? ''}';
        final locale = '${item['locale'] ?? item['lang'] ?? ''}';
        final n = name.toLowerCase();
        final l = locale.toLowerCase().replaceAll('_', '-');
        if (l.startsWith('en') ||
            n.contains('english') ||
            n.contains('samantha') ||
            n.contains('zira') ||
            n.contains('british') ||
            n.contains('american')) {
          continue;
        }
        final hindi = l.startsWith('hi') ||
            n.contains('hindi') ||
            n.contains('हिन्द') ||
            n.contains('lekha') ||
            n.contains('kanya') ||
            n.contains('hi-in');
        if (!hindi) continue;
        var s = 0;
        if (n.contains('lekha') || n.contains('kanya')) s += 80;
        if (n.contains('hindi') || n.contains('हिन्द')) s += 70;
        if (n.contains('hie')) s += 40;
        if (n.contains('google')) s += 20;
        if (n.contains('male') || n.contains('ravi')) s -= 40;
        if (s > bestScore) {
          bestScore = s;
          best = {'name': name, 'locale': locale};
        }
      }
      if (best != null) {
        await _tts.setVoice({'name': best['name']!, 'locale': best['locale']!});
      }
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    await stop();
    final spoken = UmaVoiceText.forSpeech(text);
    if (spoken.isEmpty) return;
    final ok = await _speakIndianHindi(spoken);
    if (!ok) {
      await _prepareHindiTts();
      await _tts.setLanguage('hi-IN');
      await _tts.speak(spoken);
    }
  }

  Future<bool> _speakIndianHindi(String spoken) async {
    try {
      for (final part in UmaVoiceText.chunks(spoken)) {
        final url =
            'https://translate.googleapis.com/translate_tts?ie=UTF-8&client=tw-ob&tl=hi&q=${Uri.encodeComponent(part)}';
        await _player.stop();
        await _player.play(UrlSource(url));
        await _player.onPlayerComplete.first.timeout(
          Duration(seconds: 8 + part.length ~/ 8),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  static String forSpeech(String raw) => UmaVoiceText.forSpeech(raw);
}
