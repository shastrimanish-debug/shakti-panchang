import 'package:flutter_tts/flutter_tts.dart';

class UmaService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('hi-IN');
    await _tts.setSpeechRate(0.46);
    await _tts.setPitch(1.02);
    await _tts.setVolume(1.0);
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
