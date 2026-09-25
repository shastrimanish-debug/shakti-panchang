import '../models/kundali_model.dart';
import 'kundali_calculator.dart';
import 'location_store.dart';

class GocharPlanetDetail {
  final String planet;
  final String symbol;
  final String rashi;
  final double longitude;
  final double degreeInRashi;
  final int houseFromLagna;
  final int houseFromMoon;
  final bool isRetrograde;
  final bool isCombust;
  final String dignity;
  final String statusText;
  final double speed;

  const GocharPlanetDetail({
    required this.planet,
    required this.symbol,
    required this.rashi,
    required this.longitude,
    required this.degreeInRashi,
    required this.houseFromLagna,
    required this.houseFromMoon,
    required this.isRetrograde,
    required this.isCombust,
    required this.dignity,
    required this.statusText,
    required this.speed,
  });
}

class TransitYoga {
  final String name;
  final List<String> planets;
  final String description;
  final String type;
  const TransitYoga({
    required this.name,
    required this.planets,
    required this.description,
    required this.type,
  });
}

class DailyGocharData {
  final DateTime date;
  final String place;
  final String lagnaRashi;
  final String moonRashi;
  final List<GocharPlanetDetail> planets;
  final List<TransitYoga> yogas;
  final double moonRemainingDegrees;
  final double moonHoursToNextSign;
  final String nextMoonRashi;

  const DailyGocharData({
    required this.date,
    required this.place,
    required this.lagnaRashi,
    required this.moonRashi,
    required this.planets,
    required this.yogas,
    required this.moonRemainingDegrees,
    required this.moonHoursToNextSign,
    required this.nextMoonRashi,
  });
}

/// Port of webapp `src/services/gochar.ts` using on-device KundaliCalculator.
class GocharService {
  static const rashis = KundaliCalculator.rashis;

  static const _symbols = {
    'सूर्य': '☀️',
    'चंद्र': '🌙',
    'मंगल': '♂️',
    'बुध': '☿️',
    'गुरु': '♃',
    'शुक्र': '♀️',
    'शनि': '♄',
    'राहु': '☊',
    'केतु': '☋',
  };

  static const _exalt = {
    'सूर्य': 0,
    'चंद्र': 1,
    'मंगल': 9,
    'बुध': 5,
    'गुरु': 3,
    'शुक्र': 11,
    'शनि': 6,
    'राहु': 1,
    'केतु': 7,
  };

  static const _debil = {
    'सूर्य': 6,
    'चंद्र': 7,
    'मंगल': 3,
    'बुध': 11,
    'गुरु': 9,
    'शुक्र': 5,
    'शनि': 0,
    'राहु': 7,
    'केतु': 1,
  };

  static const _own = {
    'सूर्य': [4],
    'चंद्र': [3],
    'मंगल': [0, 7],
    'बुध': [2, 5],
    'गुरु': [8, 11],
    'शुक्र': [1, 6],
    'शनि': [9, 10],
  };

  static const _combust = {
    'चंद्र': 12.0,
    'मंगल': 17.0,
    'बुध': 14.0,
    'गुरु': 11.0,
    'शुक्र': 10.0,
    'शनि': 15.0,
  };

  static Future<DailyGocharData> calculate({
    DateTime? when,
    String? natalMoon,
  }) async {
    final date = when ?? DateTime.now();
    final loc = await LocationStore().selected();
    final lat = loc?.latitude ?? 23.1765;
    final lon = loc?.longitude ?? 75.7885;
    final place = loc?.name ?? 'उज्जैन';
    final time =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final chart = await KundaliCalculator.calculate(
      name: 'गोचर',
      birthDate: date,
      birthTime: time,
      birthPlace: place,
      latitude: lat,
      longitude: lon,
      timezoneHours: 5.5,
    );

    final sun = chart.planets.firstWhere((p) => p.planet == 'सूर्य');
    final moon = chart.planets.firstWhere((p) => p.planet == 'चंद्र');
    final lagnaIdx = rashis.indexOf(chart.lagnaRashi);
    final moonIdx = rashis.contains(natalMoon)
        ? rashis.indexOf(natalMoon!)
        : rashis.indexOf(chart.moonRashi);

    final details = chart.planets.map((p) {
      final rashiIdx = rashis.indexOf(p.rashi);
      final lon360 = p.degree % 360;
      final inSign = lon360 % 30;
      var diff = (p.degree - sun.degree).abs() % 360;
      if (diff > 180) diff = 360 - diff;
      final combustLimit = _combust[p.planet];
      final combust = combustLimit != null && diff <= combustLimit;
      String dignity = 'सम';
      if (_exalt[p.planet] == rashiIdx) {
        dignity = 'उच्च';
      } else if (_debil[p.planet] == rashiIdx) {
        dignity = 'नीच';
      } else if (_own[p.planet]?.contains(rashiIdx) == true) {
        dignity = 'स्वराशि';
      }
      var status = p.isRetrograde ? 'वक्री' : 'मार्गी';
      if (combust) status += ' • अस्त';
      return GocharPlanetDetail(
        planet: p.planet,
        symbol: _symbols[p.planet] ?? '🪐',
        rashi: p.rashi,
        longitude: lon360,
        degreeInRashi: inSign,
        houseFromLagna: ((rashiIdx - lagnaIdx + 12) % 12) + 1,
        houseFromMoon: ((rashiIdx - moonIdx + 12) % 12) + 1,
        isRetrograde: p.isRetrograde,
        isCombust: combust,
        dignity: dignity,
        statusText: status,
        speed: p.speed,
      );
    }).toList();

    return DailyGocharData(
      date: date,
      place: place,
      lagnaRashi: chart.lagnaRashi,
      moonRashi: natalMoon ?? chart.moonRashi,
      planets: details,
      yogas: _yogas(details),
      moonRemainingDegrees: (30 - (moon.degree % 30)).clamp(0, 30),
      moonHoursToNextSign: (((30 - (moon.degree % 30)).clamp(0, 30)) /
              (moon.speed.abs() < 5 ? 13.176 : moon.speed.abs())) *
          24,
      nextMoonRashi: rashis[(rashis.indexOf(chart.moonRashi) + 1) % 12],
    );
  }

  static List<TransitYoga> _yogas(List<GocharPlanetDetail> planets) {
    GocharPlanetDetail? of(String n) {
      for (final p in planets) {
        if (p.planet == n) return p;
      }
      return null;
    }

    final yogas = <TransitYoga>[];
    final sun = of('सूर्य');
    final moon = of('चंद्र');
    final mercury = of('बुध');
    final jupiter = of('गुरु');
    final mars = of('मंगल');
    final venus = of('शुक्र');
    final saturn = of('शनि');

    if (sun != null && mercury != null && sun.rashi == mercury.rashi) {
      yogas.add(TransitYoga(
        name: 'बुधादित्य राजयोग',
        planets: const ['सूर्य', 'बुध'],
        description: '${sun.rashi} में सूर्य-बुध युति — बुद्धि, वाणी और प्रतिष्ठा।',
        type: 'auspicious',
      ));
    }
    if (moon != null && jupiter != null) {
      final h = ((rashis.indexOf(moon.rashi) - rashis.indexOf(jupiter.rashi) + 12) % 12) + 1;
      if ([1, 4, 7, 10].contains(h)) {
        yogas.add(TransitYoga(
          name: 'गजकेसरी महायोग',
          planets: const ['चंद्र', 'गुरु'],
          description: 'चंद्र से गुरु $hवें भाव (केंद्र) में — ज्ञान और सिद्धि।',
          type: 'auspicious',
        ));
      }
    }
    if (saturn != null &&
        [0, 6, 9, 10].contains(rashis.indexOf(saturn.rashi)) &&
        [1, 4, 7, 10].contains(saturn.houseFromLagna)) {
      yogas.add(const TransitYoga(
        name: 'शश पंचमहापुरुष योग',
        planets: ['शनि'],
        description: 'शनि स्व/उच्च राशि के केंद्र में — अधिकार और धैर्य।',
        type: 'auspicious',
      ));
    }
    if (moon != null && mars != null && moon.rashi == mars.rashi) {
      yogas.add(TransitYoga(
        name: 'चंद्र-मंगल महालक्ष्मी योग',
        planets: const ['चंद्र', 'मंगल'],
        description: '${moon.rashi} में चंद्र-मंगल युति — धन और पराक्रम।',
        type: 'auspicious',
      ));
    }
    if (jupiter != null && venus != null && jupiter.rashi == venus.rashi) {
      yogas.add(TransitYoga(
        name: 'गुरु-शुक्र युति',
        planets: const ['गुरु', 'शुक्र'],
        description: '${jupiter.rashi} में दो शुभ ग्रहों की युति — मांगलिक कार्य।',
        type: 'auspicious',
      ));
    }
    return yogas;
  }
}
