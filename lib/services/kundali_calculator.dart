import '../models/kundali_model.dart';
import 'xalen_service.dart';

class KundaliCalculator {
  static const rashis = ['मेष','वृषभ','मिथुन','कर्क','सिंह','कन्या','तुला','वृश्चिक','धनु','मकर','कुंभ','मीन'];
  static const nakshatras = ['अश्विनी','भरणी','कृत्तिका','रोहिणी','मृगशीर्ष','आर्द्रा','पुनर्वसु','पुष्य','आश्लेषा','मघा','पूर्वा फाल्गुनी','उत्तरा फाल्गुनी','हस्त','चित्रा','स्वाती','विशाखा','अनुराधा','ज्येष्ठा','मूल','पूर्वाषाढ़ा','उत्तराषाढ़ा','श्रवण','धनिष्ठा','शतभिषा','पूर्वाभाद्रपद','उत्तराभाद्रपद','रेवती'];
  static const nakLords = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
  static const dashaYears = {'केतु':7,'शुक्र':20,'सूर्य':6,'चंद्र':10,'मंगल':7,'राहु':18,'गुरु':16,'शनि':19,'बुध':17};
  static const gana = ['देव','मनुष्य','राक्षस','मनुष्य','देव','मनुष्य','देव','देव','राक्षस','राक्षस','मनुष्य','मनुष्य','देव','राक्षस','देव','राक्षस','देव','राक्षस','राक्षस','मनुष्य','मनुष्य','देव','राक्षस','राक्षस','मनुष्य','मनुष्य','देव'];
  static const yoni = ['अश्व','गज','मेढ़ा','सर्प','सर्प','श्वान','मार्जार','मेढ़ा','मार्जार','मूषक','मूषक','गौ','महिष','व्याघ्र','महिष','व्याघ्र','मृग','मृग','श्वान','वानर','नकुल','वानर','सिंह','अश्व','सिंह','गौ','गज'];
  static const nadi = ['आदि','मध्य','अन्त्य','अन्त्य','मध्य','आदि','आदि','मध्य','अन्त्य','अन्त्य','मध्य','आदि','आदि','मध्य','अन्त्य','अन्त्य','मध्य','आदि','आदि','मध्य','अन्त्य','अन्त्य','मध्य','आदि','आदि','मध्य','अन्त्य'];
  static const planetNames = ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','राहु','केतु'];
  static const AstronomyEnginePlanetIds = [0,1,2,3,4,5,6];
  static const dashaOrder = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];

  static Future<KundaliData> calculate({required String name, required DateTime birthDate, required String birthTime, required String birthPlace, required double latitude, required double longitude, double timezoneHours = 5.5}) async {
    final parsed = _parseBirthTime(birthTime);
    if (parsed == null) throw const FormatException('Invalid birth time. Use HH:MM, HH.MM or HHMM.');
    // Fix: explicitly cast tuple elements to int
    final dt = DateTime(birthDate.year, birthDate.month, birthDate.day, (parsed.$1).toInt(), (parsed.$2).toInt(), (parsed.$3).toInt());
    final x = AstronomyEngineService();
    final positions = <PlanetPosition>[];
    for (var i=0;i<AstronomyEnginePlanetIds.length;i++) {
      final p = x.calculatePlanet(dt, timezoneHours: timezoneHours, bodyId: AstronomyEnginePlanetIds[i]);
      final sid = _norm(p.siderealDeg);
      final rashiIndex = (sid/30).floor()%12;
      positions.add(PlanetPosition(planet: planetNames[i], rashi: rashis[rashiIndex], degree: sid, house: 0, isRetrograde: p.retrograde, latitude: p.latitudeDeg, speed: p.speedDegDay));
    }
    // The astronomical engine's True Node is Rahu. Ketu is exactly 180° opposite Rahu.
    final node = x.calculatePlanet(dt, timezoneHours: timezoneHours, bodyId: 8);
    final rahuDeg = _norm(node.siderealDeg);
    final ketuDeg = _norm(rahuDeg + 180.0);
    positions.add(PlanetPosition(planet:'राहु', rashi:rashis[(rahuDeg/30).floor()%12], degree:rahuDeg, house:0, isRetrograde:true, latitude: node.latitudeDeg, speed: node.speedDegDay));
    positions.add(PlanetPosition(planet:'केतु', rashi:rashis[(ketuDeg/30).floor()%12], degree:ketuDeg, house:0, isRetrograde:true, latitude: -node.latitudeDeg, speed: -node.speedDegDay));
    final h = x.calculateHouses(dt, latitude: latitude, longitude: longitude, timezoneHours: timezoneHours);
    final lagnaIndex = (h.ascendantDeg/30).floor()%12;
    for (var i=0;i<positions.length;i++) {
      final sign = (positions[i].degree/30).floor()%12;
      final house = ((sign-lagnaIndex+12)%12)+1;
      positions[i] = PlanetPosition(planet: positions[i].planet,rashi: positions[i].rashi,degree: positions[i].degree,house: house,isRetrograde: positions[i].isRetrograde, latitude: positions[i].latitude, speed: positions[i].speed);
    }
    final moon = positions.firstWhere((p)=>p.planet=='चंद्र');
    final nakIndex = (moon.degree/(360/27)).floor().clamp(0,26);
    final pada = ((moon.degree%(360/27))/(360/108)).floor()+1;
    final sun = positions.firstWhere((p)=>p.planet=='सूर्य');
    final dasha = _currentDasha(dt, moon.degree, nakIndex);
    return KundaliData(name:name,birthDate:birthDate,birthTime:birthTime,birthPlace:birthPlace,latitude:latitude,longitude:longitude,timezoneHours:timezoneHours,planets:positions,lagnaDegree:h.ascendantDeg,lagnaRashi:rashis[lagnaIndex],moonRashi:moon.rashi,sunRashi:sun.rashi,nakshatra:nakshatras[nakIndex],charan:'$pada',nadi:nadi[nakIndex],gana:gana[nakIndex],yoni:yoni[nakIndex],varna:_varna(moon.rashi),mahadasha:dasha.maha,antardasha:dasha.antar,dashaPeriods:dasha.periods,antarPeriods:dasha.antarPeriods,pratyantarPeriods:dasha.pratyantarPeriods);
  }

  static (int,int,int)? _parseBirthTime(String raw) {
    var value = raw.trim().toUpperCase().replaceAll(' ', '');
    if (value.isEmpty) return null;
    final pm = value.endsWith('PM');
    final am = value.endsWith('AM');
    if (pm || am) value = value.substring(0, value.length - 2);
    value = value.replaceAll('.', ':');
    int hour, minute, second = 0;
    if (value.contains(':')) {
      final p = value.split(':');
      if (p.length > 3) return null;
      hour = int.tryParse(p[0]) ?? -1;
      minute = int.tryParse(p.length > 1 ? p[1] : '0') ?? -1;
      second = int.tryParse(p.length > 2 ? p[2] : '0') ?? -1;
    } else if (RegExp(r'^\d{3,4}$').hasMatch(value)) {
      minute = int.parse(value.substring(value.length - 2));
      hour = int.parse(value.substring(0, value.length - 2));
    } else return null;
    if (am || pm) {
      if (hour < 1 || hour > 12) return null;
      if (pm && hour != 12) hour += 12;
      if (am && hour == 12) hour = 0;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59) return null;
    return (hour, minute, second);
  }

  static double _norm(double v) {
    final n = v % 360.0;
    return n < 0 ? n + 360.0 : n;
  }

  static String _varna(String rashi) { final i=rashis.indexOf(rashi); if ([0,4,8].contains(i)) return 'क्षत्रिय'; if ([1,5,9].contains(i)) return 'वैश्य'; if ([2,6,10].contains(i)) return 'शूद्र'; return 'ब्राह्मण'; }

  static ({String maha,String antar,List<DashaPeriod> periods,List<DashaSubPeriod> antarPeriods,List<DashaPratyantar> pratyantarPeriods}) _currentDasha(DateTime birth, double moonLon, int nakIndex) {
    final lord = nakLords[nakIndex % 9];
    final startIdx = dashaOrder.indexOf(lord);
    final nakSpan = 360.0 / 27.0;
    final withinNak = (moonLon % nakSpan) / nakSpan;
    final firstBalanceYears = dashaYears[lord]! * (1.0 - withinNak);
    final periods = <DashaPeriod>[];
    var cursor = birth;
    final now = DateTime.now();

    // Build the complete Vimshottari timeline through 120 years from birth.
    // This is the report/UI lifetime horizon; it is deliberately not limited to 10 years.
    final horizon = DateTime(birth.year + 120, birth.month, birth.day, birth.hour, birth.minute, birth.second);
    for (var i = 0; i < 81; i++) {
      final planet = dashaOrder[(startIdx + i) % 9];
      final years = i == 0 ? firstBalanceYears : dashaYears[planet]!.toDouble();
      final calculatedEnd = cursor.add(Duration(milliseconds: (years * 365.2425 * 86400000).round()));
      final end = calculatedEnd.isAfter(horizon) ? horizon : calculatedEnd;
      if (!end.isAfter(cursor)) break;
      final actualYears = end.difference(cursor).inMilliseconds / (365.2425 * 86400000);
      periods.add(DashaPeriod(planet: planet, startDate: cursor, endDate: end, years: actualYears));
      cursor = end;
      if (!cursor.isBefore(horizon)) break;
    }

    final antarPeriods = <DashaSubPeriod>[];
    final pratyantarPeriods = <DashaPratyantar>[];
    for (final maha in periods) {
      final mahaYears = dashaYears[maha.planet]!.toDouble();
      final mahaIndex = dashaOrder.indexOf(maha.planet);
      var antarCursor = maha.startDate;
      for (var j = 0; j < 9; j++) {
        final antar = dashaOrder[(mahaIndex + j) % 9];
        final antarYears = mahaYears * dashaYears[antar]! / 120.0;
        final antarEnd = j == 8 ? maha.endDate : antarCursor.add(Duration(milliseconds: (antarYears * 365.2425 * 86400000).round()));
        final ap = DashaSubPeriod(maha: maha.planet, antar: antar, startDate: antarCursor, endDate: antarEnd, years: antarYears);
        antarPeriods.add(ap);
        // Keep all sub-periods for the current mahadasha/antardasha available.
        final antarIndex = dashaOrder.indexOf(antar);
        final pratyantarYearsTotal = antarYears;
        var pratyCursor = antarCursor;
        for (var k = 0; k < 9; k++) {
          final praty = dashaOrder[(antarIndex + k) % 9];
          final pratyYears = pratyantarYearsTotal * dashaYears[praty]! / 120.0;
          final pratyEnd = k == 8 ? antarEnd : pratyCursor.add(Duration(milliseconds: (pratyYears * 365.2425 * 86400000).round()));
          pratyantarPeriods.add(DashaPratyantar(maha: maha.planet, antar: antar, pratyantar: praty, startDate: pratyCursor, endDate: pratyEnd, years: pratyYears));
          pratyCursor = pratyEnd;
        }
        antarCursor = antarEnd;
      }
    }

    final mahaPeriod = periods.firstWhere((p) => !now.isBefore(p.startDate) && now.isBefore(p.endDate), orElse: () => periods.last);
    final currentAntar = antarPeriods.firstWhere((p) => p.maha == mahaPeriod.planet && !now.isBefore(p.startDate) && now.isBefore(p.endDate), orElse: () => antarPeriods.firstWhere((p) => p.maha == mahaPeriod.planet));
    return (maha: mahaPeriod.planet, antar: currentAntar.antar, periods: periods, antarPeriods: antarPeriods, pratyantarPeriods: pratyantarPeriods);
  }
}
