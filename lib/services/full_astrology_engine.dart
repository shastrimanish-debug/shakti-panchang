import 'dart:math' as math;
import '../models/kundali_model.dart';
import 'astrology_advanced_service.dart';
import 'kundali_calculator.dart';
import 'xalen_service.dart';
import 'tajik_varshaphal_engine.dart';

/// Production-oriented calculation facade. It uses the project's astronomical
/// engine for positions and derives the classical timing/significator layers.
class FullKpReading {
  const FullKpReading({required this.cusps, required this.significators, required this.rulingPlanets});
  final List<KpCuspResult> cusps;
  final Map<String, List<int>> significators;
  final List<String> rulingPlanets;
}

class FullAstrologyEngine {
  const FullAstrologyEngine();

  Future<FullKpReading> kp(KundaliData d) async {
    final cusps = await AstrologyAdvancedService.kpCusps(d);
    final sig = <String, List<int>>{};
    for (final p in d.planets) {
      final houses = <int>{};
      for (final c in cusps) {
        if (c.starLord == p.planet || c.subLord == p.planet) houses.add(c.house);
      }
      if (p.house >= 1 && p.house <= 12) houses.add(p.house);
      sig[p.planet] = houses.toList()..sort();
    }
    final ruling = <String>{};
    final moon = d.planets.firstWhere((p) => p.planet == 'चंद्र');
    final lagna = cusps.first;
    ruling.add(lagna.starLord);
    ruling.add(lagna.subLord);
    ruling.add(KundaliCalculator.nakLords[(moon.degree / (360 / 27)).floor() % 9]);
    ruling.add(d.mahadasha);
    ruling.add(d.antardasha);
    return FullKpReading(cusps: cusps, significators: sig, rulingPlanets: ruling.toList());
  }

  /// Yogini Dasha: 8-lord cycle with the standard 36-year total. Balance at
  /// birth is derived from the Moon's progress through its nakshatra.
  List<DashaPeriod> yoginiDasha(KundaliData d, {int cycles = 4}) {
    const lords = ['मंगला','पिंगला','धन्या','भ्रामरी','भद्रा','उल्का','सिद्धा','संकटा'];
    const years = [1,2,3,4,5,6,7,8];
    const nakToStart = [0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2,3,4,5,6,7,0,1,2];
    final moon = d.planets.firstWhere((p) => p.planet == 'चंद्र');
    final nak = (moon.degree / (360 / 27)).floor().clamp(0,26);
    final start = nakToStart[nak];
    final span = 360 / 27;
    final fractionUsed = (moon.degree % span) / span;
    final balanceYears = years[start] * (1 - fractionUsed);
    final result = <DashaPeriod>[];
    var cursor = d.birthDate;
    final total = 8 * cycles;
    for (var i=0;i<total;i++) {
      final idx=(start+i)%8;
      final y=i==0?balanceYears:years[idx].toDouble();
      final end=cursor.add(Duration(milliseconds:(y*365.2425*86400000).round()));
      result.add(DashaPeriod(planet: lords[idx], startDate: cursor, endDate: end, years: y));
      cursor=end;
    }
    return result;
  }

  /// Finds the approximate solar-return instant for a year by minimizing the
  /// angular distance between natal and return sidereal Sun longitude.
  Future<DateTime> solarReturn({required KundaliData d, required int year}) async {
    final birthTimeParts = d.birthTime.replaceAll('.', ':').split(':');
    final h=int.tryParse(birthTimeParts.first)??12;
    final m=birthTimeParts.length>1?int.tryParse(birthTimeParts[1])??0:0;
    final natalSun=d.planets.firstWhere((p)=>p.planet=='सूर्य').degree;
    var best=DateTime(year,d.birthDate.month,d.birthDate.day,h,m);
    var bestErr=360.0;
    // Search a ±3 day window at 30-minute resolution, then a local 1-minute
    // refinement. The astronomical engine supplies the actual Sun longitude.
    final center=DateTime(year,d.birthDate.month,d.birthDate.day,h,m);
    for(var i=-144;i<=144;i++) {
      final t=center.add(Duration(minutes:i*30));
      final sun=AstronomyEngineService().calculatePlanet(t,timezoneHours:d.timezoneHours,bodyId:0);
      final e=_angleDistance(sun.siderealDeg,natalSun);
      if(e<bestErr){bestErr=e;best=t;}
    }
    final coarse=best;
    for(var i=-30;i<=30;i++) {
      final t=coarse.add(Duration(minutes:i));
      final sun=AstronomyEngineService().calculatePlanet(t,timezoneHours:d.timezoneHours,bodyId:0);
      final e=_angleDistance(sun.siderealDeg,natalSun);
      if(e<bestErr){bestErr=e;best=t;}
    }
    return best;
  }

  Future<TajikSignal> varshaphal(KundaliData d, int year) async {
    final ret=await solarReturn(d:d,year:year);
    final x=AstronomyEngineService();
    final h=x.calculateHouses(ret,latitude:d.latitude,longitude:d.longitude,timezoneHours:d.timezoneHours);
    final asc=(h.ascendantDeg/30).floor()%12;
    final muntha=((KundaliCalculator.rashis.indexOf(d.lagnaRashi)+(year-d.birthDate.year))%12+12)%12;
    final indicators=<String>[];
    final planets=<PlanetPosition>[];
    for(final id in [0,1,2,3,4,5,6]){
      final p=x.calculatePlanet(ret,timezoneHours:d.timezoneHours,bodyId:id);
      final sign=(p.siderealDeg/30).floor()%12;
      final house=((sign-asc+12)%12)+1;
      planets.add(PlanetPosition(planet:['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि'][id],rashi:KundaliCalculator.rashis[sign],degree:p.siderealDeg,house:house,isRetrograde:p.retrograde,latitude:p.latitudeDeg,speed:p.speedDegDay));
    }
    for(final p in planets){ if([1,4,5].contains(p.house)) indicators.add('${p.planet} शुभ भाव संकेत: भाव ${p.house}'); if([6,8,12].contains(p.house)) indicators.add('${p.planet} चुनौती भाव संकेत: भाव ${p.house}'); }
    final annualLord=KundaliCalculator.rashis[asc];
    return TajikSignal(year:year,munthaHouse:muntha+1,annualAscendant:KundaliCalculator.rashis[asc],munthaLord:KundaliCalculator.rashis[muntha],annualLord:annualLord,indicators:indicators,timing:'Solar return: ${ret.toIso8601String()}');
  }

  double _angleDistance(double a,double b){final d=(a-b).abs()%360;return math.min(d,360-d);}
}
