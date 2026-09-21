import 'uma_voice.dart';

class UmaService {
  Future<void> init() => UmaVoice.instance.init();
  Future<void> speak(String text) => UmaVoice.instance.speak(text);
  Future<void> stop() => UmaVoice.instance.stop();
}
