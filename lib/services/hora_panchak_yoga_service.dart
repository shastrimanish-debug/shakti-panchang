// lib/services/hora_panchak_yoga_service.dart
// Shakti Panchang - Advanced Vedic Engine (Hora, Panchak, Bhadra & Yogas)

class SpecialYogaResult {
  final String id;
  final String name;
  final String nameEnglish;
  final String description;
  final String nature; // 'auspicious' | 'inauspicious' | 'mixed'
  final String timings;

  const SpecialYogaResult({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.description,
    required this.nature,
    required this.timings,
  });
}

class PanchakDetail {
  final bool isActive;
  final String typeNameHindi;
  final String typeNameEnglish;
  final String nature; // 'inauspicious' | 'auspicious' | 'neutral'
  final String description;
  final List<String> prohibitedActions;

  const PanchakDetail({
    required this.isActive,
    required this.typeNameHindi,
    required this.typeNameEnglish,
    required this.nature,
    required this.description,
    required this.prohibitedActions,
  });
}

class BhadraDetail {
  final bool isActive;
  final String vas; // 'स्वर्ग' | 'पाताल' | 'मृत्युलोक'
  final String nature; // 'varjya' | 'auspicious'
  final String description;
  final String timings;

  const BhadraDetail({
    required this.isActive,
    required this.vas,
    required this.nature,
    required this.description,
    required this.timings,
  });
}

class HoraSlot {
  final int hourNumber; // 1 to 24
  final String planet;
  final String symbol;
  final DateTime start;
  final DateTime end;
  final bool isDay;
  final bool isActive;
  final String nature;
  final String description;

  const HoraSlot({
    required this.hourNumber,
    required this.planet,
    required this.symbol,
    required this.start,
    required this.end,
    required this.isDay,
    required this.isActive,
    required this.nature,
    required this.description,
  });
}

class HoraPanchakYogaService {
  static bool _hasName(String source, String needle) {
    final a = source.replaceAll(' ', '').replaceAll('ाढ़ा', 'ाढा');
    final b = needle.replaceAll(' ', '').replaceAll('ाढ़ा', 'ाढा');
    return a.contains(b);
  }

  static bool _hasAny(String source, List<String> needles) =>
      needles.any((n) => _hasName(source, n));

  static const List<String> _chaldeanOrder = [
    'सूर्य',
    'शुक्र',
    'बुध',
    'चन्द्र',
    'शनि',
    'बृहस्पति',
    'मंगल',
  ];

  static const Map<String, String> _planetSymbols = {
    'सूर्य': '☀️',
    'शुक्र': '✨',
    'बुध': '🟢',
    'चन्द्र': '🌙',
    'शनि': '⚪',
    'बृहस्पति': '🌟',
    'मंगल': '🔴',
  };

  static const Map<String, String> _horaNature = {
    'सूर्य': 'madhyam',
    'शुक्र': 'shubh',
    'बुध': 'shubh',
    'चन्द्र': 'shubh',
    'शनि': 'ashubh',
    'बृहस्पति': 'shubh',
    'मंगल': 'madhyam',
  };

  static const Map<String, String> _horaDescription = {
    'सूर्य': 'प्रशासनिक कार्य, उच्चाधिकारी संपर्क, मान-सम्मान व औषधि निर्माण।',
    'शुक्र': 'नवीन वस्त्र, आभूषण क्रय, विवाह वार्ता, कला, संगीत व सुख-सुविधा।',
    'बुध': 'व्यापार, खाता बही, शिक्षा, संचार, लेखन व नवीन व्यापार अनुबंध।',
    'चन्द्र': 'जलीय कार्य, यात्रा, गृह प्रवेश, माता की सेवा व नवीन वस्त्र।',
    'शनि': 'भूमि, भवन, लोहा, मशीनरी, तेल व कृषि से जुड़े कार्य।',
    'बृहस्पति': 'धार्मिक अनुष्ठान, विद्यारंभ, पूजा-पाठ, निवेश व गुरु दर्शन।',
    'मंगल': 'साहसिक कार्य, कोर्ट-कचहरी, सेना, शस्त्र, भू-सम्पत्ति व खेल।',
  };

  static List<HoraSlot> calculate24Horas({
    required DateTime sunrise,
    required DateTime sunset,
    required DateTime nextSunrise,
    required int weekdayNumber,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final dayRulers = {
      7: 'सूर्य',
      1: 'चन्द्र',
      2: 'मंगल',
      3: 'बुध',
      4: 'बृहस्पति',
      5: 'शुक्र',
      6: 'शनि',
    };
    final firstRuler = dayRulers[weekdayNumber] ?? 'सूर्य';
    final startIndex = _chaldeanOrder.indexOf(firstRuler);
    final dayDurationMs = sunset.difference(sunrise).inMilliseconds;
    final nightDurationMs = nextSunrise.difference(sunset).inMilliseconds;
    final daySlotMs = (dayDurationMs / 12).round();
    final nightSlotMs = (nightDurationMs / 12).round();
    final List<HoraSlot> horas = [];
    for (int i = 0; i < 12; i++) {
      final pIndex = (startIndex + i) % 7;
      final planet = _chaldeanOrder[pIndex];
      final slotStart = sunrise.add(Duration(milliseconds: i * daySlotMs));
      final slotEnd = (i == 11) ? sunset : sunrise.add(Duration(milliseconds: (i + 1) * daySlotMs));
      final isActive = now.isAfter(slotStart) && now.isBefore(slotEnd);
      horas.add(HoraSlot(
        hourNumber: i + 1,
        planet: planet,
        symbol: _planetSymbols[planet] ?? '⭐',
        start: slotStart,
        end: slotEnd,
        isDay: true,
        isActive: isActive,
        nature: _horaNature[planet] ?? 'shubh',
        description: _horaDescription[planet] ?? '',
      ));
    }
    for (int i = 0; i < 12; i++) {
      final pIndex = (startIndex + 12 + i) % 7;
      final planet = _chaldeanOrder[pIndex];
      final slotStart = sunset.add(Duration(milliseconds: i * nightSlotMs));
      final slotEnd = (i == 11) ? nextSunrise : sunset.add(Duration(milliseconds: (i + 1) * nightSlotMs));
      final isActive = now.isAfter(slotStart) && now.isBefore(slotEnd);
      horas.add(HoraSlot(
        hourNumber: i + 13,
        planet: planet,
        symbol: _planetSymbols[planet] ?? '⭐',
        start: slotStart,
        end: slotEnd,
        isDay: false,
        isActive: isActive,
        nature: _horaNature[planet] ?? 'shubh',
        description: _horaDescription[planet] ?? '',
      ));
    }
    return horas;
  }

  static PanchakDetail calculatePanchak({
    required String nakshatra,
    required int weekdayNumber,
  }) {
    final panchakNakshatras = [
      'धनिष्ठा',
      'शतभिषा',
      'पूर्व भाद्रपद',
      'पूर्वाभाद्रपद',
      'उत्तर भाद्रपद',
      'उत्तराभाद्रपद',
      'रेवती',
    ];
    final isPanchakActive = _hasAny(nakshatra, panchakNakshatras);
    if (!isPanchakActive) {
      return const PanchakDetail(
        isActive: false,
        typeNameHindi: 'पञ्चक मुक्त',
        typeNameEnglish: 'No Panchak',
        nature: 'auspicious',
        description: 'आज पञ्चक का कोई दुष्प्रभाव नहीं है। सर्वकार्य शुभ हैं।',
        prohibitedActions: [],
      );
    }
    switch (weekdayNumber) {
      case 7:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'रोग पञ्चक (रविवार)',
          typeNameEnglish: 'Roga Panchak',
          nature: 'inauspicious',
          description: 'शारीरिक कष्ट, रोग व अस्वस्थता का योग बनता है।',
          prohibitedActions: ['दक्षिण दिशा यात्रा', 'छत ढालना', 'नया पलंग बनवाना'],
        );
      case 1:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'राज पञ्चक (सोमवार)',
          typeNameEnglish: 'Raja Panchak',
          nature: 'auspicious',
          description: 'सरकारी व प्रशासनिक कार्यों, संपत्ति खरीद व पद प्राप्ति हेतु शुभ।',
          prohibitedActions: ['छत ढालना', 'दाह संस्कार में विशेष विधान'],
        );
      case 2:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'अग्नि पञ्चक (मंगलवार)',
          typeNameEnglish: 'Agni Panchak',
          nature: 'inauspicious',
          description: 'अग्नि भय व विवाद की संभावना रहती है। औजार व निर्माण में सावधानी बरतें।',
          prohibitedActions: ['अग्नि प्रज्वलन कार्य', 'छत ढालना', 'भवन निर्माण आरंभ'],
        );
      case 5:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'चोर पञ्चक (शुक्रवार)',
          typeNameEnglish: 'Chora Panchak',
          nature: 'inauspicious',
          description: 'धन हानि व चोरी का भय रहता है। बड़ा लेन-देन सोच-समझकर करें।',
          prohibitedActions: ['व्यापार में बड़ा जोखिम', 'यात्रा', 'महंगे आभूषण क्रय'],
        );
      case 6:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'मृत्यु पञ्चक (शनिवार)',
          typeNameEnglish: 'Mrityu Panchak',
          nature: 'inauspicious',
          description: 'सर्वाधिक कष्टकारी पञ्चक। विवाद, दुर्घटना व जोखिम भरे कार्यों से बचें।',
          prohibitedActions: ['दक्षिण दिशा यात्रा', 'छत ढालना', 'गृह निर्माण', 'घास/लकड़ी संग्रह'],
        );
      default:
        return const PanchakDetail(
          isActive: true,
          typeNameHindi: 'सामान्य पञ्चक',
          typeNameEnglish: 'Normal Panchak',
          nature: 'neutral',
          description: 'मध्यम पञ्चक। पञ्चक के ५ प्रमुख निषेधों का पालन करें।',
          prohibitedActions: ['दक्षिण दिशा यात्रा', 'छत ढालना', 'खाट/पलंग बुनना', 'घास-लकड़ी संग्रह'],
        );
    }
  }

  static BhadraDetail calculateBhadra({
    required String karana,
    required String lunarRashi,
    required DateTime sunrise,
    required DateTime sunset,
  }) {
    final isBhadra = karana.contains('विष्टि');
    if (!isBhadra) {
      return const BhadraDetail(
        isActive: false,
        vas: 'भद्रा मुक्त',
        nature: 'auspicious',
        description: 'आज विष्टि (भद्रा) करण नहीं है। सभी शुभ कार्य सम्पन्न किए जा सकते हैं।',
        timings: 'कोई भद्रा नहीं',
      );
    }
    String vas = 'स्वर्गलोक';
    String nature = 'auspicious';
    String desc = 'भद्रा स्वर्ग में वास कर रही है। पृथ्वीवासियों के लिए शुभ फलदायी है।';
    if (_hasAny(lunarRashi, ['कर्क', 'सिंह', 'कुंभ', 'मीन'])) {
      vas = 'मृत्युलोक (भूलोक)';
      nature = 'varjya';
      desc = 'भद्रा पृथ्वी पर विद्यमान है। विवाह, मुंडन, गृहप्रवेश, रक्षाबंधन पूर्णतः वर्जित हैं।';
    } else if (_hasAny(lunarRashi, ['कन्या', 'तुला', 'धनु', 'मकर'])) {
      vas = 'पाताल लोक';
      nature = 'auspicious';
      desc = 'भद्रा पाताल लोक में वास करती है। भूलोक पर इसका कोई अशुभ प्रभाव नहीं पड़ता।';
    }
    return BhadraDetail(
      isActive: true,
      vas: vas,
      nature: nature,
      description: desc,
      timings: 'विष्टि करण सक्रिय रहने तक',
    );
  }

  static List<SpecialYogaResult> calculateSpecialYogas({
    required String nakshatra,
    required int weekdayNumber,
    required String tithi,
  }) {
    final List<SpecialYogaResult> yogas = [];
    final Map<int, List<String>> siddhiMap = {
      7: ['हस्त', 'मूल', 'उत्तराफाल्गुनी', 'उत्तराषाढ़ा', 'उत्तराभाद्रपद', 'पुष्य', 'अश्विनी'],
      1: ['श्रवण', 'रोहिणी', 'मृगशिरा', 'पुष्य', 'अनुराधा'],
      2: ['अश्विनी', 'उत्तराभाद्रपद', 'कृत्तिका', 'आश्लेषा'],
      3: ['रोहिणी', 'अनुराधा', 'हस्त', 'कृत्तिका', 'मृगशिरा'],
      4: ['रेवती', 'अनुराधा', 'अश्विनी', 'पुनर्वसु', 'पुष्य'],
      5: ['रेवती', 'अनुराधा', 'अश्विनी', 'पुनर्वसु', 'रोहिणी'],
      6: ['रोहिणी', 'स्वाती', 'श्रवण'],
    };
    final allowedSarvartha = siddhiMap[weekdayNumber] ?? [];
    if (_hasAny(nakshatra, allowedSarvartha)) {
      yogas.add(const SpecialYogaResult(
        id: 'sarvartha_siddhi',
        name: 'सर्वार्थ सिद्धि योग',
        nameEnglish: 'Sarvartha Siddhi Yoga',
        description: 'समस्त मनोरथों को पूर्ण करने वाला महाशुभ योग। नवीन व्यवसाय, गृह क्रय, अनुबंध व यात्रा हेतु अत्यंत प्रशस्त।',
        nature: 'auspicious',
        timings: 'नक्षत्र समाप्ति तक',
      ));
    }
    bool isAmritSiddhi = false;
    if (weekdayNumber == 7 && _hasName(nakshatra, 'हस्त')) isAmritSiddhi = true;
    if (weekdayNumber == 1 && (_hasName(nakshatra, 'मृगशिरा') || _hasName(nakshatra, 'मृगशीर्ष'))) isAmritSiddhi = true;
    if (weekdayNumber == 2 && _hasName(nakshatra, 'अश्विनी')) isAmritSiddhi = true;
    if (weekdayNumber == 3 && _hasName(nakshatra, 'अनुराधा')) isAmritSiddhi = true;
    if (weekdayNumber == 4 && _hasName(nakshatra, 'पुष्य')) isAmritSiddhi = true;
    if (weekdayNumber == 5 && _hasName(nakshatra, 'रेवती')) isAmritSiddhi = true;
    if (weekdayNumber == 6 && _hasName(nakshatra, 'रोहिणी')) isAmritSiddhi = true;
    if (isAmritSiddhi) {
      yogas.add(const SpecialYogaResult(
        id: 'amrit_siddhi',
        name: 'अमृत सिद्धि योग',
        nameEnglish: 'Amrit Siddhi Yoga',
        description: 'अमृततुल्य सिद्धिदायक योग। इस योग में किए गए कार्य दीर्घकालिक लाभ और अक्षय सिद्धि प्रदान करते हैं।',
        nature: 'auspicious',
        timings: 'नक्षत्र समाप्ति तक',
      ));
    }
    final isBhadraTithi = tithi.contains('द्वितीया') || tithi.contains('सप्तमी') || tithi.contains('द्वादशी');
    final isSpecialDay = weekdayNumber == 7 || weekdayNumber == 2 || weekdayNumber == 6;
    if (isBhadraTithi && isSpecialDay) {
      if (_hasAny(nakshatra, ['कृतिका', 'कृत्तिका', 'पुनर्वसु', 'विशाखा', 'उत्तराफाल्गुनी', 'उत्तरा फाल्गुनी', 'उत्तराषाढ़ा', 'उत्तराभाद्रपद'])) {
        yogas.add(const SpecialYogaResult(
          id: 'tripushkar',
          name: 'त्रिपुष्कर योग',
          nameEnglish: 'Tripushkar Yoga',
          description: 'इस योग में किया गया कोई भी शुभ कार्य तीन गुना फल देता है। हानि व ऋण अदायगी से बचें क्योंकि परिणाम ३ बार दोहराते हैं।',
          nature: 'mixed',
          timings: 'तिथि व नक्षत्र संयोग तक',
        ));
      } else if (_hasAny(nakshatra, ['मृगशिरा', 'मृगशीर्ष', 'चित्रा', 'धनिष्ठा'])) {
        yogas.add(const SpecialYogaResult(
          id: 'dwipushkar',
          name: 'द्विपुष्कर योग',
          nameEnglish: 'Dwipushkar Yoga',
          description: 'इस योग में किए गए कार्य का फल दोहरा होता है। संपत्ति क्रय व मांगलिक कार्य शुभ, परंतु ऋण लेना वर्जित।',
          nature: 'mixed',
          timings: 'तिथि व नक्षत्र संयोग तक',
        ));
      }
    }
    return yogas;
  }
}
