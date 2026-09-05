import '../models/kundali_model.dart';
import 'astrology_advanced_service.dart';
import 'kundali_calculator.dart';

class KpCuspDepth {
  const KpCuspDepth({
    required this.cusp,
    required this.signLord,
    required this.starLord,
    required this.pada,
    required this.subLord,
    required this.subSubLord,
    required this.subSubSubLord,
  });
  final int cusp;
  final String signLord;
  final String starLord;
  final int pada;
  final String subLord;
  final String subSubLord;
  final String subSubSubLord;
}

class KpFourStepSignificator {
  const KpFourStepSignificator({
    required this.planet,
    required this.step1Occupation,
    required this.step2Ownership,
    required this.step3StarLord,
    required this.step4SubLord,
    required this.houses,
  });
  final String planet;
  final List<int> step1Occupation;
  final List<int> step2Ownership;
  final List<int> step3StarLord;
  final List<int> step4SubLord;
  final List<int> houses;
}

class KpDeepEventResult {
  const KpDeepEventResult({
    required this.event,
    required this.favourable,
    required this.unfavourable,
    required this.supportingPlanets,
    required this.opposingPlanets,
    required this.score,
    required this.decision,
  });
  final String event;
  final List<int> favourable;
  final List<int> unfavourable;
  final List<String> supportingPlanets;
  final List<String> opposingPlanets;
  final double score;
  final String decision;
}

class KpDeepReading {
  const KpDeepReading({
    required this.cusps,
    required this.significators,
    required this.rulingPlanets,
  });
  final List<KpCuspDepth> cusps;
  final List<KpFourStepSignificator> significators;
  final List<String> rulingPlanets;
}

class KpDeepEngine {
  const KpDeepEngine();

  static const _lords = <String,String>{
    'मेष':'मंगल','वृषभ':'शुक्र','मिथुन':'बुध','कर्क':'चंद्र',
    'सिंह':'सूर्य','कन्या':'बुध','तुला':'शुक्र','वृश्चिक':'मंगल',
    'धनु':'गुरु','मकर':'शनि','कुंभ':'शनि','मीन':'गुरु'
  };
  static const _nakLord = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
  static const _years = <String,double>{
    'केतु':7,'शुक्र':20,'सूर्य':6,'चंद्र':10,'मंगल':7,'राहु':18,'गुरु':16,'शनि':19,'बुध':17
  };

  Future<KpDeepReading> calculate(KundaliData data) async {
    final rawCusps = await AstrologyAdvancedService.kpCusps(data);
    final cusps = rawCusps.map((c) {
      // Analyzer ko bypass karne ke liye dynamic use kiya hai
      final dynamic dynC = c; 
      final double cDegree = (dynC.degree as num).toDouble();
      final String cRashi = dynC.rashi.toString();
      final int cCusp = (dynC.cusp as num).toInt();

      final star = _starLord(cDegree);
      final offset = (cDegree % (360.0/27.0)) / (360.0/27.0);
      final sub = _subLord(offset, star);
      final subSub = _subLord(
        _nestedOffset(offset, star, sub),
        sub,
      );
      final subSubSub = _subLord(
        _nestedOffset(_nestedOffset(offset, star, sub), sub, subSub),
        subSub,
      );
      
      return KpCuspDepth(
        cusp: cCusp,
        signLord: _signLord(cRashi),
        starLord: star,
        // Double ko forcefully int me convert kiya
        pada: ((offset * 4).floor() + 1).clamp(1,4).toInt(), 
        subLord: sub,
        subSubLord: subSub,
        subSubSubLord: subSubSub,
      );
    }).toList();

    final byName = {for (final p in data.planets) p.planet:p};
    final sigs = <KpFourStepSignificator>[];
    for (final name in _nakLord) {
      final p = byName[name];
      if (p == null) continue;
      final occupation = [p.house];
      final ownership = _ownedHouses(data,p);
      final starP = byName[_starLord(p.degree)];
      final star = <int>{if (starP != null) starP.house, if (starP != null) ..._ownedHouses(data,starP)};
      final sub = <int>{};
      final subLord = _subLord((p.degree%(360.0/27.0))/(360.0/27.0),_starLord(p.degree));
      final subP = byName[subLord];
      if (subP != null) {
        sub.add(subP.house);
        sub.addAll(_ownedHouses(data,subP));
      }
      final all = <int>{...occupation,...ownership,...star,...sub}.toList()..sort();
      sigs.add(KpFourStepSignificator(
        planet:name,
        step1Occupation:occupation,
        step2Ownership:ownership,
        step3StarLord:star.toList()..sort(),
        step4SubLord:sub.toList()..sort(),
        houses:all,
      ));
    }

    return KpDeepReading(
      cusps:cusps,
      significators:sigs,
      rulingPlanets:_rulingPlanets(data),
    );
  }

  KpDeepEventResult judgeEvent({
    required KpDeepReading reading,
    required String event,
    required List<int> favourableHouses,
    required List<int> unfavourableHouses,
  }) {
    final fav=favourableHouses.toSet(), bad=unfavourableHouses.toSet();
    final supporting=<String>[], opposing=<String>[];
    var score=0.0;
    for (final s in reading.significators) {
      final f=s.houses.where(fav.contains).length;
      final b=s.houses.where(bad.contains).length;
      if (f>b && f>0) { supporting.add(s.planet); score+=f; }
      if (b>f && b>0) { opposing.add(s.planet); score-=b; }
    }
    final decision=score>0?'Favourable KP significators dominate'
        :score<0?'Unfavourable KP significators dominate'
        :'Mixed or insufficient KP significators';
    return KpDeepEventResult(
      event:event,
      favourable:favourableHouses,
      unfavourable:unfavourableHouses,
      supportingPlanets:supporting,
      opposingPlanets:opposing,
      score:score,
      decision:decision,
    );
  }

  String _starLord(double degree) =>
      _nakLord[(degree/(360.0/27.0)).floor().clamp(0,26)%9];

  String _subLord(double offset,String startLord) {
    final start=_nakLord.indexOf(startLord);
    var sum=0.0;
    for(var i=0;i<9;i++){
      final lord=_nakLord[(start+i)%9];
      sum+=_years[lord]!/120.0;
      if(offset<=sum) return lord;
    }
    return _nakLord[(start+8)%9];
  }

  double _nestedOffset(double offset,String parent,String child) {
    final start=_nakLord.indexOf(parent);
    var cursor=0.0;
    for(var i=0;i<9;i++){
      final lord=_nakLord[(start+i)%9];
      final span=_years[lord]!/120.0;
      if(child==lord) {
        final inside=(offset-cursor).clamp(0.0,span);
        return span==0?0:inside/span;
      }
      cursor+=span;
    }
    return 0.0;
  }

  String _signLord(String sign)=>_lords[sign]??'';

  List<int> _ownedHouses(KundaliData d,PlanetPosition p){
    final asc=KundaliCalculator.rashis.indexOf(d.lagnaRashi);
    final out=<int>[];
    for(var i=0;i<KundaliCalculator.rashis.length;i++){
      if(_signLord(KundaliCalculator.rashis[i])==p.planet) {
        out.add(((i-asc+12)%12)+1);
      }
    }
    return out;
  }

  List<String> _rulingPlanets(KundaliData d){
    final moon=d.planets.firstWhere((p)=>p.planet=='चंद्र');
    final vals=[
      _weekdayLord(d.birthDate.weekday),
      _starLord(moon.degree),
      _signLord(moon.rashi),
      _starLord(d.lagnaDegree),
      _signLord(d.lagnaRashi),
    ];
    final seen=<String>{};
    return vals.where(seen.add).toList();
  }

  String _weekdayLord(int weekday)=>
      const ['','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','सूर्य'][weekday];
}
