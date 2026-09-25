import '../models/kundali_model.dart';

/// Live panchang snapshot so Uma can speak today's numbers without
/// depending on Gemini / a remote server.
class UmaPanchangSnap {
  final String place;
  final String weekday;
  final String paksha;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String sunrise;
  final String sunset;
  final String rahuKaal;
  final String yamaganda;
  final String gulika;
  final String shubhChoghadiya;
  final String currentChoghadiya;
  final String dishaShool;
  final String brahmaMuhurat;

  const UmaPanchangSnap({
    required this.place,
    required this.weekday,
    required this.paksha,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.shubhChoghadiya,
    required this.currentChoghadiya,
    required this.dishaShool,
    required this.brahmaMuhurat,
  });
}

class UmaVidvanReply {
  final String text;
  final String action;
  final List<String> reasons;
  final List<String> checks;

  const UmaVidvanReply({
    required this.text,
    this.action = 'विवाह, करियर, धन, स्वास्थ्य, साढ़ेसाती, दशा या आज का पंचांग पूछ सकते हैं।',
    this.reasons = const ['काशी-उज्जैन परंपरा का स्थानीय विद्वान् इंजन'],
    this.checks = const ['यह मार्गदर्शन शास्त्रीय संकेत है, भय नहीं।'],
  });
}
