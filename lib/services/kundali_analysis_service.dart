import '../models/kundali_model.dart';
import 'xalen_service.dart';
import 'kundali_calculator.dart';

class KundaliAnalysisService {
  static const signLords = <String, String>{
    'मेष': 'मंगल', 'वृषभ': 'शुक्र', 'मिथुन': 'बुध', 'कर्क': 'चंद्र',
    'सिंह': 'सूर्य', 'कन्या': 'बुध', 'तुला': 'शुक्र', 'वृश्चिक': 'मंगल',
    'धनु': 'गुरु', 'मकर': 'शनि', 'कुंभ': 'शनि', 'मीन': 'गुरु',
  };

  static List<String> yogas(KundaliData d) {
    final out = <String>[];
    final by = <String, PlanetPosition>{for (final p in d.planets) p.planet: p};
    final sameHouse = (String a, String b) => by[a]!.house == by[b]!.house;
    final kendraFrom = (int a, int b) { final x = ((a - b) % 12 + 12) % 12 + 1; return [1, 4, 7, 10].contains(x); };

    if (sameHouse('सूर्य', 'बुध')) out.add('बुधादित्य योग — सूर्य और बुध एक ही भाव में');
    if (kendraFrom(by['गुरु']!.house, by['चंद्र']!.house)) out.add('गजकेसरी योग — गुरु चंद्र से केंद्र में');
    if (sameHouse('चंद्र', 'मंगल')) out.add('चंद्र-मंगल योग — चंद्र और मंगल युति');

    final asc = _ascSign(d);
    final houseLord = <int, String>{};
    for (var h = 1; h <= 12; h++) {
      final sign = KundaliCalculator.rashis[(asc + h - 1) % 12];
      houseLord[h] = signLords[sign]!;
    }
    final l5 = by[houseLord[5]!];
    final l9 = by[houseLord[9]!];
    final l10 = by[houseLord[10]!];
    final l1 = by[houseLord[1]!];
    if (l1 != null && l5 != null && l1.house == l5.house) out.add('राजयोग संकेत — लग्नेश और पंचमेश संबंध');
    if (l1 != null && l9 != null && l1.house == l9.house) out.add('धर्म-राजयोग संकेत — लग्नेश और नवमेश संबंध');
    if (l9 != null && l10 != null && l9.house == l10.house) out.add('धर्म-कर्माधिपति योग संकेत');
    if (out.isEmpty) out.add('प्रमुख सामान्य योग इस गणना में नहीं मिले।');
    return out;
  }

  static List<String> doshas(KundaliData d) {
    final by = <String, PlanetPosition>{for (final p in d.planets) p.planet: p};
    final out = <String>[];
    final marsHouse = by['मंगल']!.house;
    final moonHouse = by['चंद्र']!.house;
    if ([1, 4, 7, 8, 12].contains(marsHouse) || [1, 4, 7, 8, 12].contains(moonHouse)) {
      out.add('मंगल दोष संकेत — मंगल लग्न/चंद्र से 1, 4, 7, 8 या 12 भाव में है। परंपरा के अनुसार मिलान में अलग नियम लागू हो सकते हैं।');
    } else {
      out.add('मंगल दोष का सामान्य संकेत नहीं मिला।');
    }
    if (_isKaalSarp(d)) out.add('कालसर्प योग संकेत — सभी सात ग्रह राहु-केतु अक्ष के एक ओर हैं।');
    else out.add('कालसर्प योग का सामान्य संकेत नहीं मिला।');
    if (_isKemadruma(d)) out.add('केमद्रुम योग संकेत — चंद्र से 2 और 12 भाव में कोई ग्रह नहीं।');
    return out;
  }

  static List<HouseInfo> houses(KundaliData d) {
    final asc = _ascSign(d);
    final byHouse = <int, List<String>>{for (var i = 1; i <= 12; i++) i: []};
    for (final p in d.planets) byHouse[p.house]!.add(p.planet);
    return List.generate(12, (i) {
      final h = i + 1;
      final sign = KundaliCalculator.rashis[(asc + i) % 12];
      return HouseInfo(house: h, sign: sign, lord: signLords[sign]!, planets: byHouse[h]!);
    });
  }

  static Future<List<TransitPosition>> currentTransits(KundaliData d) async {
    final x = AstronomyEngineService();
    final now = DateTime.now();
    final natalAsc = _ascSign(d);
    final ids = <String, int>{'सूर्य':0,'चंद्र':1,'मंगल':2,'बुध':3,'गुरु':4,'शुक्र':5,'शनि':6};
    final out = <TransitPosition>[];
    for (final e in ids.entries) {
      final p = x.calculatePlanet(now, timezoneHours: 5.5, bodyId: e.value);
      final deg = _norm(p.siderealDeg);
      final sign = (deg / 30).floor() % 12;
      final house = ((sign - natalAsc + 12) % 12) + 1;
      out.add(TransitPosition(planet: e.key, rashi: KundaliCalculator.rashis[sign], degree: deg, house: house, retrograde: p.retrograde));
    }
    final node = x.calculatePlanet(now, timezoneHours: 5.5, bodyId: 8);
    final rahu = _norm(node.siderealDeg);
    final ketu = _norm(rahu + 180);
    out.add(TransitPosition(planet: 'राहु', rashi: KundaliCalculator.rashis[(rahu / 30).floor() % 12], degree: rahu, house: (((rahu / 30).floor() % 12 - natalAsc + 12) % 12) + 1, retrograde: true));
    out.add(TransitPosition(planet: 'केतु', rashi: KundaliCalculator.rashis[(ketu / 30).floor() % 12], degree: ketu, house: (((ketu / 30).floor() % 12 - natalAsc + 12) % 12) + 1, retrograde: true));
    return out;
  }

  static int _ascSign(KundaliData d) => (d.lagnaDegree / 30).floor() % 12;

  static bool _isKaalSarp(KundaliData d) {
    final rahu = d.planets.firstWhere((p) => p.planet == 'राहु').degree;
    final ketu = _norm(rahu + 180);
    final visible = d.planets.where((p) => !{'राहु','केतु'}.contains(p.planet)).map((p) => _between(rahu: rahu, ketu: ketu, value: p.degree)).toList();
    return visible.every((x) => x) || visible.every((x) => !x);
  }

  static bool _between({required double rahu, required double ketu, required double value}) {
    final span = _norm(ketu - rahu);
    final v = _norm(value - rahu);
    return v <= span;
  }

  static bool _isKemadruma(KundaliData d) {
    final moon = d.planets.firstWhere((p) => p.planet == 'चंद्र');
    final has2 = d.planets.any((p) => p.planet != 'चंद्र' && p.house == ((moon.house) % 12) + 1);
    final has12 = d.planets.any((p) => p.planet != 'चंद्र' && p.house == ((moon.house - 2 + 12) % 12) + 1);
    return !has2 && !has12;
  }

  static double _norm(double v) { final n = v % 360; return n < 0 ? n + 360 : n; }
}

class HouseInfo {
  final int house;
  final String sign;
  final String lord;
  final List<String> planets;
  HouseInfo({required this.house, required this.sign, required this.lord, required this.planets});
}

class TransitPosition {
  final String planet;
  final String rashi;
  final double degree;
  final int house;
  final bool retrograde;
  TransitPosition({required this.planet, required this.rashi, required this.degree, required this.house, required this.retrograde});
}
