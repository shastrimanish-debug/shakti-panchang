import '../models/kundali_model.dart';
import 'kundali_calculator.dart';
import 'xalen_service.dart';

class BhavaChalitHouse {
  final int house;
  final double cusp;
  final double nextCusp;
  final List<String> planets;
  const BhavaChalitHouse({required this.house, required this.cusp, required this.nextCusp, required this.planets});
}

class SadeSatiResult {
  final String status;
  final String phase;
  final String saturnSign;
  final String moonSign;
  final List<String> remedies;
  const SadeSatiResult({required this.status, required this.phase, required this.saturnSign, required this.moonSign, required this.remedies});
}

class KpCuspResult {
  final int house;
  final double cusp;
  final String sign;
  final String starLord;
  final String subLord;
  const KpCuspResult({required this.house, required this.cusp, required this.sign, required this.starLord, required this.subLord});
}

class JaiminiKarakas {
  final String atmakaraka;
  final String amatyakaraka;
  final String bhratrikaraka;
  final String matrikaraka;
  final String pitrikaraka;
  final String putrakaraka;
  final String gnatikaraka;
  final String darakaraka;
  const JaiminiKarakas({required this.atmakaraka, required this.amatyakaraka, required this.bhratrikaraka, required this.matrikaraka, required this.pitrikaraka, required this.putrakaraka, required this.gnatikaraka, required this.darakaraka});
}

class AstrologyAdvancedService {
  static const _dashaOrder = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
  static const _dashaYears = {'केतु':7,'शुक्र':20,'सूर्य':6,'चंद्र':10,'मंगल':7,'राहु':18,'गुरु':16,'शनि':19,'बुध':17};
  static const _nakLords = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];

  static Future<List<BhavaChalitHouse>> bhavaChalit(KundaliData d) async {
    final parsed = _parseTime(d.birthTime);
    if (parsed == null) throw const FormatException('Invalid birth time');
    final dt = DateTime(d.birthDate.year, d.birthDate.month, d.birthDate.day, parsed.$1, parsed.$2, parsed.$3);
    final h = AstronomyEngineService().calculateHouses(dt, latitude: d.latitude, longitude: d.longitude, timezoneHours: 5.5);
    final result = <BhavaChalitHouse>[];
    for (var i = 0; i < 12; i++) {
      final cusp = _norm(h.cusps[i]);
      final next = _norm(h.cusps[(i + 1) % 12]);
      final planets = d.planets.where((p) => _inArc(_norm(p.degree), cusp, next)).map((p) => p.planet).toList();
      result.add(BhavaChalitHouse(house: i + 1, cusp: cusp, nextCusp: next, planets: planets));
    }
    return result;
  }

  static Future<SadeSatiResult> sadeSati(KundaliData d) async {
    final transits = await currentTransitPlanets(d);
    final saturn = transits.firstWhere((p) => p.planet == 'शनि');
    final moonSign = KundaliCalculator.rashis.indexOf(d.moonRashi);
    final saturnSign = KundaliCalculator.rashis.indexOf(saturn.rashi);
    final distance = (saturnSign - moonSign + 12) % 12;
    String status = 'साढ़ेसाती नहीं';
    String phase = '—';
    if (distance == 11) { status = 'साढ़ेसाती चल रही है'; phase = 'उदय / Rising phase'; }
    if (distance == 0) { status = 'साढ़ेसाती चल रही है'; phase = 'मध्य / Peak phase'; }
    if (distance == 1) { status = 'साढ़ेसाती चल रही है'; phase = 'अस्त / Setting phase'; }
    if (distance == 3) { status = 'ढैय्या का संकेत'; phase = 'चतुर्थ शनि / 4th from Moon'; }
    if (distance == 7) { status = 'ढैय्या का संकेत'; phase = 'अष्टम शनि / 8th from Moon'; }
    return SadeSatiResult(status: status, phase: phase, saturnSign: saturn.rashi, moonSign: d.moonRashi, remedies: const ['शनिवार को सेवा/दान', 'हनुमान चालीसा या शनि मंत्र श्रद्धा से', 'अनुशासन, ईमानदारी और जरूरतमंदों की सहायता', 'रत्न या विशेष अनुष्ठान विशेषज्ञ सलाह से ही']);
  }

  static Future<List<KpCuspResult>> kpCusps(KundaliData d) async {
    final parsed = _parseTime(d.birthTime);
    if (parsed == null) throw const FormatException('Invalid birth time');
    final dt = DateTime(d.birthDate.year, d.birthDate.month, d.birthDate.day, parsed.$1, parsed.$2, parsed.$3);
    final h = AstronomyEngineService().calculateHouses(dt, latitude: d.latitude, longitude: d.longitude, timezoneHours: 5.5);
    return List.generate(12, (i) {
      final deg = _norm(h.cusps[i]);
      final star = _nakshatraLord(deg);
      final sub = _subLord(deg, star);
      return KpCuspResult(house: i + 1, cusp: deg, sign: KundaliCalculator.rashis[(deg / 30).floor() % 12], starLord: star, subLord: sub);
    });
  }

  static JaiminiKarakas jaimini(KundaliData d) {
    final seven = d.planets.where((p) => const ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि'].contains(p.planet)).toList();
    seven.sort((a,b) => (b.degree % 30).compareTo(a.degree % 30));
    final names = seven.map((p) => p.planet).toList();
    while (names.length < 7) names.add('—');
    return JaiminiKarakas(atmakaraka:names[0], amatyakaraka:names[1], bhratrikaraka:names[2], matrikaraka:names[3], pitrikaraka:names[4], putrakaraka:names[5], gnatikaraka:names[6], darakaraka:'राहु/केतु — परंपरा अनुसार');
  }

  static List<String> charaDashaFramework(KundaliData d) {
    final asc = KundaliCalculator.rashis.indexOf(d.lagnaRashi);
    return List.generate(12, (i) => KundaliCalculator.rashis[(asc + i) % 12]);
  }

  static Future<List<PlanetPosition>> currentTransitPlanets(KundaliData d) async {
    final now = DateTime.now();
    final x = AstronomyEngineService();
    final ids = <int>[0,1,2,3,4,5,6];
    final names = ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि'];
    final list = <PlanetPosition>[];
    for (var i=0;i<ids.length;i++) {
      final p = x.calculatePlanet(now, timezoneHours: 5.5, bodyId: ids[i]);
      final deg = _norm(p.siderealDeg);
      final sign = (deg/30).floor()%12;
      final house = ((sign - _ascSign(d) + 12) % 12) + 1;
      list.add(PlanetPosition(planet:names[i],rashi:KundaliCalculator.rashis[sign],degree:deg,house:house,isRetrograde:p.retrograde,latitude:p.latitudeDeg,speed:p.speedDegDay));
    }
    final node = x.calculatePlanet(now, timezoneHours: 5.5, bodyId: 8);
    final rahu = _norm(node.siderealDeg);
    final ketu = _norm(rahu + 180);
    final rahuSign = (rahu / 30).floor() % 12;
    final ketuSign = (ketu / 30).floor() % 12;
    list.add(PlanetPosition(planet:'राहु',rashi:KundaliCalculator.rashis[rahuSign],degree:rahu,house:((rahuSign - _ascSign(d) + 12) % 12) + 1,isRetrograde:true,latitude:node.latitudeDeg,speed:node.speedDegDay));
    list.add(PlanetPosition(planet:'केतु',rashi:KundaliCalculator.rashis[ketuSign],degree:ketu,house:((ketuSign - _ascSign(d) + 12) % 12) + 1,isRetrograde:true,latitude:-node.latitudeDeg,speed:-node.speedDegDay));
    return list;
  }

  static int _ascSign(KundaliData d) {
    final index = KundaliCalculator.rashis.indexOf(d.lagnaRashi);
    if (index < 0) return 0;
    if (index > 11) return 11;
    return index;
  }

  static String _nakshatraLord(double deg) => _nakLords[((deg / (360/27)).floor()) % 9];
  static String _subLord(double deg, String starLord) {
    final starIndex = _dashaOrder.indexOf(starLord);
    final span = 360/27;
    final offset = (deg % span) / span;
    var cumulative = 0.0;
    for (var i=0;i<9;i++) {
      final planet = _dashaOrder[(starIndex+i)%9];
      final fraction = _dashaYears[planet]! / 120.0;
      cumulative += fraction;
      if (offset <= cumulative) return planet;
    }
    return _dashaOrder[(starIndex+8)%9];
  }
  static bool _inArc(double value,double start,double end) => start <= end ? value >= start && value < end : value >= start || value < end;
  static double _norm(double v) { final n=v%360; return n<0?n+360:n; }
  static (int,int,int)? _parseTime(String raw) {
    var v=raw.trim().replaceAll(' ','').replaceAll('.',':');
    if(v.isEmpty)return null;
    final parts=v.split(':');
    int h,m,s=0;
    if(parts.length>=2){h=int.tryParse(parts[0])??-1;m=int.tryParse(parts[1])??-1;s=parts.length>2?int.tryParse(parts[2])??-1:0;} else {return null;}
    if(h<0||h>23||m<0||m>59||s<0||s>59)return null;
    return (h,m,s);
  }
}
