import '../models/kundali_model.dart';
import 'kp_deep_engine.dart';
import 'kundali_calculator.dart';
import 'xalen_service.dart';

class KpTimingWindow {
  const KpTimingWindow({required this.start, required this.end, required this.score, required this.reasons});
  final DateTime start;
  final DateTime end;
  final double score;
  final List<String> reasons;
}

class KpEventTimingEngine {
  const KpEventTimingEngine();

  Future<List<KpTimingWindow>> findWindows({
    required KundaliData chart,
    required KpDeepReading reading,
    required List<int> favourableHouses,
    required DateTime from,
    required DateTime to,
    int maxWindows = 12,
  }) async {
    if (to.isBefore(from)) throw ArgumentError('to must not be before from');
    final days = to.difference(from).inDays + 1;
    final rows = <_DayScore>[];
    for (var i = 0; i < days; i++) {
      final day = DateTime(from.year, from.month, from.day).add(Duration(days: i));
      final score = await _scoreDay(chart, reading, favourableHouses, day);
      if (score.score >= 2.5) rows.add(score);
    }
    if (rows.isEmpty) return const [];
    final grouped = <KpTimingWindow>[];
    var start = rows.first.date;
    var prev = rows.first.date;
    var scoreSum = rows.first.score;
    var count = 1;
    var reasons = <String>{...rows.first.reasons};
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.date.difference(prev).inDays == 1) {
        prev = row.date; scoreSum += row.score; count++; reasons.addAll(row.reasons);
      } else {
        grouped.add(KpTimingWindow(start: start, end: prev, score: scoreSum/count, reasons: reasons.take(8).toList()));
        start = prev = row.date; scoreSum = row.score; count = 1; reasons = <String>{...row.reasons};
      }
    }
    grouped.add(KpTimingWindow(start: start, end: prev, score: scoreSum/count, reasons: reasons.take(8).toList()));
    grouped.sort((a,b) => b.score.compareTo(a.score));
    return grouped.take(maxWindows).toList(growable:false);
  }

  Future<_DayScore> _scoreDay(KundaliData chart, KpDeepReading reading, List<int> fav, DateTime day) async {
    final activeMaha = chart.dashaPeriods.where((p) => !day.isBefore(p.startDate) && day.isBefore(p.endDate)).toList();
    final activeAntar = chart.antarPeriods.where((p) => !day.isBefore(p.startDate) && day.isBefore(p.endDate)).toList();
    final activePraty = chart.pratyantarPeriods.where((p) => !day.isBefore(p.startDate) && day.isBefore(p.endDate)).toList();
    if (activeMaha.isEmpty) return _DayScore(day,0,const []);
    final maha = activeMaha.first.planet;
    final antar = activeAntar.firstWhere((p)=>p.maha==maha, orElse:()=>activeAntar.first).antar;
    final praty = activePraty.firstWhere((p)=>p.maha==maha && p.antar==antar, orElse:()=>activePraty.first).pratyantar;
    final lordSet = {maha, antar, praty};
    var score = 0.0;
    final reasons = <String>[];
    for (final s in reading.significators) {
      if (!lordSet.contains(s.planet)) continue;
      final hits = s.houses.where(fav.contains).length;
      if (hits > 0) { score += hits * (s.planet == praty ? 2.0 : 1.5); reasons.add('${s.planet} dasha significates ${hits} favourable house(s)'); }
    }
    final noon = DateTime(day.year,day.month,day.day,12);
    final transitIds = <int>[0,1,2,3,4,5,6,8];
    for (var i=0;i<transitIds.length;i++) {
      final p = await _planetAt(chart,noon,transitIds[i]);
      final transitHouse = ((KundaliCalculator.rashis.indexOf(p.rashi) - KundaliCalculator.rashis.indexOf(chart.lagnaRashi) + 12)%12)+1;
      if (fav.contains(transitHouse)) { score += p.planet == 'चंद्र' ? 1.2 : 0.6; reasons.add('${p.planet} transit activates house $transitHouse'); }
      final star = _starLord(p.degree);
      final sub = _subLord(p.degree);
      if (lordSet.contains(star)) { score += 1.0; reasons.add('${p.planet} transits the star of $star'); }
      if (lordSet.contains(sub)) { score += 1.5; reasons.add('${p.planet} transits the sub of $sub'); }
    }
    return _DayScore(day,score,reasons);
  }

  Future<PlanetPosition> _planetAt(KundaliData chart, DateTime local, int id) async {
    final x = AstronomyEngineService().calculatePlanet(local, timezoneHours: chart.timezoneHours, bodyId: id);
    final deg = x.siderealDeg;
    final idx = (deg/30).floor()%12;
    return PlanetPosition(planet: const ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','राहु','केतु'][id==8?7:id], rashi: KundaliCalculator.rashis[idx], degree: deg, house: 0, isRetrograde: x.retrograde, latitude: x.latitudeDeg, speed: x.speedDegDay);
  }

  String _starLord(double degree) => const ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'][(degree/(360/27)).floor()%9];
  String _subLord(double degree) {
    const order=['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
    const years={'केतु':7.0,'शुक्र':20.0,'सूर्य':6.0,'चंद्र':10.0,'मंगल':7.0,'राहु':18.0,'गुरु':16.0,'शनि':19.0,'बुध':17.0};
    final star=order[(degree/(360/27)).floor()%9]; final start=order.indexOf(star); final offset=(degree%(360/27))/(360/27); var sum=0.0;
    for(var i=0;i<9;i++){final l=order[(start+i)%9]; sum+=years[l]!/120; if(offset<=sum)return l;}
    return order[(start+8)%9];
  }
}

class _DayScore {
  const _DayScore(this.date,this.score,this.reasons);
  final DateTime date; final double score; final List<String> reasons;
}
