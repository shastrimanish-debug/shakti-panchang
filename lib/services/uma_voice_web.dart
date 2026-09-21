import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'uma_voice_text.dart';

/// वेब: गूगल हिन्दी वाणी (भारतीय), अंग्रेज़ी वॉइस नहीं।
class UmaVoice {
  UmaVoice._();
  static final UmaVoice instance = UmaVoice._();

  web.HTMLAudioElement? _audio;

  Future<void> init() async {}

  Future<void> speak(String text) async {
    await stop();
    final spoken = UmaVoiceText.forSpeech(text);
    if (spoken.isEmpty) return;
    final parts = UmaVoiceText.chunks(spoken);
    for (final part in parts) {
      final ok = await _playGoogleHi(part);
      if (!ok) {
        await _speakBrowserHi(spoken);
        return;
      }
    }
  }

  Future<bool> _playGoogleHi(String text) async {
    try {
      final q = Uri.encodeComponent(text);
      final url =
          'https://translate.googleapis.com/translate_tts?ie=UTF-8&client=gtx&tl=hi&q=$q';
      final audio = web.HTMLAudioElement()
        ..src = url
        ..preload = 'auto';
      _audio = audio;
      final done = Completer<bool>();
      audio.onEnded.listen((_) {
        if (!done.isCompleted) done.complete(true);
      });
      audio.onError.listen((_) {
        if (!done.isCompleted) done.complete(false);
      });
      final p = audio.play();
      await p.toDart;
      return await done.future.timeout(const Duration(seconds: 20), onTimeout: () => true);
    } catch (_) {
      return false;
    }
  }

  Future<void> _speakBrowserHi(String text) async {
    try {
      final synth = web.window.speechSynthesis;
      synth.cancel();
      final voices = synth.getVoices().toDart;
      web.SpeechSynthesisVoice? hindi;
      for (final v in voices) {
        final lang = v.lang.toLowerCase();
        final name = v.name.toLowerCase();
        if (lang.startsWith('hi') || name.contains('hindi') || name.contains('lekha')) {
          if (!name.contains('english')) {
            hindi = v;
            if (name.contains('google') || name.contains('हिन्द')) break;
          }
        }
      }
      final u = web.SpeechSynthesisUtterance(text)
        ..lang = 'hi-IN'
        ..rate = 1
        ..pitch = 1
        ..volume = 1;
      if (hindi != null) u.voice = hindi;
      synth.speak(u);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      _audio?.pause();
      _audio = null;
      web.window.speechSynthesis.cancel();
    } catch (_) {}
  }

  static String forSpeech(String raw) => UmaVoiceText.forSpeech(raw);
}
