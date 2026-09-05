import '../models/kundali_model.dart';
import 'kundali_analysis_service.dart';
import 'kundali_calculator.dart';
import 'xalen_service.dart';

class AshtakavargaReport {
  final Map<String, List<int>> bhinna;
  final List<int> sarva;
  const AshtakavargaReport({required this.bhinna, required this.sarva});
}

class VarshaphalReport {
  final int year;
  final int age;
  final DateTime solarReturn;
  final double returnAscendant;
  final String returnAscendantRashi;
  final String munthaRashi;
  final String munthaLord;
  final String varsheshCandidate;
  final List<PlanetPosition> planets;
  final List<String> highlights;
  const VarshaphalReport({required this.year,required this.age,required this.solarReturn,required this.returnAscendant,required this.returnAscendantRashi,required this.munthaRashi,required this.munthaLord,required this.varsheshCandidate,required this.planets,required this.highlights});
}

class RemedyReport {
  final String focusPlanet;
  final List<String> remedies;
  final List<String> avoid;
  const RemedyReport({required this.focusPlanet,required this.remedies,required this.avoid});
}

class AdvancedKundaliService {
  static const _signLords = KundaliAnalysisService.signLords;
  static const _planetIds = <String,int>{'सूर्य':0,'चंद्र':1,'मंगल':2,'बुध':3,'गुरु':4,'शुक्र':5,'शनि':6};
  static const _planetOrder = ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि'];

  // Classical Bhinna Ashtakavarga benefic-place matrix.
  // Rows are target planet; columns are contributors Sun, Moon, Mars, Mercury,
  // Jupiter, Venus, Saturn and Lagna. Values are houses counted from contributor.
  static const Map<String, List<List<int>>> _bav = {
    'सूर्य': [[1,2,4,7,8,9,10,11],[3,6,10,11],[1,2,4,7,8,9,10,11],[3,5,6,9,10,11,12],[5,6,9,11],[6,7,12],[1,2,4,7,8,9,10,11],[3,4,6,10,11,12]],
    'चंद्र': [[3,6,7,8,10,11],[1,3,6,7,10,11],[2,3,5,6,9,10,11],[1,3,4,5,7,8,10,11],[1,4,7,8,10,11,12],[3,4,5,7,9,10,11],[3,5,6,11],[3,6,10,11]],
    'मंगल': [[3,5,6,10,11],[3,6,11],[1,2,4,7,8,10,11],[3,5,6,11],[6,10,11,12],[6,8,11,12],[1,4,7,8,9,10,11],[1,3,6,10,11]],
    'बुध': [[1,3,5,6,9,10,11,12],[2,4,6,8,10,11],[1,2,4,7,8,9,10,11],[1,3,5,6,9,10,11,12],[6,8,11,12],[1,2,3,4,5,8,9,11],[1,2,4,7,8,9,10,11],[1,2,4,6,8,10,11]],
    'गुरु': [[1,2,3,4,7,8,9,10,11],[2,5,7,9,11],[1,2,4,7,8,10,11],[1,2,4,5,6,9,10,11],[1,2,3,4,7,8,10,11],[2,5,6,9,10,11],[3,5,6,12],[1,2,4,5,6,7,9,10,11]],
    'शुक्र': [[1,2,3,4,5,8,9,10,11],[1,2,3,4,5,8,9,11,12],[3,5,6,9,11,12],[3,5,6,9,11],[5,8,9,10,11],[1,2,3,4,5,8,9,10,11],[3,4,5,8,9,10,11],[1,2,3,4,5,8,9,11]],
    'शनि': [[1,2,4,7,8,10,11],[3,6,11],[3,5,6,10,11,12],[6,8,9,10,11,12],[5,6,11,12],[6,11,12],[3,5,6,11],[1,3,4,6,10,11]],
  };

  static AshtakavargaReport ashtakavarga(KundaliData d) {
    final positions = <String,int>{};
    for (final p in d.planets.where((p) => _planetOrder.contains(p.planet))) positions[p.planet] = KundaliCalculator.rashis.indexOf(p.rashi);
    final refs = <String?>[..._planetOrder, null];
    final asc = _ascSign(d);
    final out = <String,List<int>>{};
    for (final target in _planetOrder) {
      final rows = _bav[target]!;
      final totals = List<int>.filled(12, 0);
      for (var refIndex = 0; refIndex < 8; refIndex++) {
        final refSign = refs[refIndex] == null ? asc : positions[refs[refIndex]!]!;
        for (final house in rows[refIndex]) {
          final sign = (refSign + house - 1) % 12;
          totals[sign]++;
        }
      }
      out[target] = totals;
    }
    final sarva = List<int>.generate(12, (i) => out.values.fold<int>(0, (sum, row) => sum + row[i]));
    return AshtakavargaReport(bhinna: out, sarva: sarva);
  }

  static Future<VarshaphalReport> varshaphal(KundaliData d, {int? year}) async {
    final now = DateTime.now();
    final targetYear = year ?? now.year;
    final age = targetYear - d.birthDate.year;
    final natalSun = d.planets.firstWhere((p) => p.planet == 'सूर्य').degree;
    final approx = DateTime(targetYear, d.birthDate.month, d.birthDate.day, 12, 0, 0);
    final returnTime = await _solarReturn(approx, natalSun, d.timezoneHours);
    final x = AstronomyEngineService();
    final h = x.calculateHouses(returnTime, latitude: d.latitude, longitude: d.longitude, timezoneHours: d.timezoneHours);
    final asc = _norm(h.ascendantDeg);
    final ascSign = (asc / 30).floor() % 12;
    final munthaSign = (_ascSign(d) + (age % 12)) % 12;
    final munthaLord = _signLords[KundaliCalculator.rashis[munthaSign]]!;
    final returnPlanets = <PlanetPosition>[];
    for (final e in _planetIds.entries) {
      final p = x.calculatePlanet(returnTime, timezoneHours: d.timezoneHours, bodyId: e.value);
      final deg = _norm(p.siderealDeg);
      final sign = (deg / 30).floor() % 12;
      final house = ((sign - ascSign + 12) % 12) + 1;
      returnPlanets.add(PlanetPosition(planet:e.key,rashi:KundaliCalculator.rashis[sign],degree:deg,house:house,isRetrograde:p.retrograde,latitude:p.latitudeDeg,speed:p.speedDegDay));
    }
    final node = x.calculatePlanet(returnTime, timezoneHours: d.timezoneHours, bodyId: 8);
    final rahu = _norm(node.siderealDeg);
    final ketu = _norm(rahu + 180);
    returnPlanets.add(PlanetPosition(planet:'राहु',rashi:KundaliCalculator.rashis[(rahu/30).floor()%12],degree:rahu,house:((rahu/30).floor()%12-ascSign+12)%12+1,isRetrograde:true,latitude:node.latitudeDeg,speed:node.speedDegDay));
    returnPlanets.add(PlanetPosition(planet:'केतु',rashi:KundaliCalculator.rashis[(ketu/30).floor()%12],degree:ketu,house:((ketu/30).floor()%12-ascSign+12)%12+1,isRetrograde:true,latitude:-node.latitudeDeg,speed:-node.speedDegDay));
    final varshesh = _signLords[KundaliCalculator.rashis[ascSign]]!;
    final highlights = _varshaphalHighlights(d, returnPlanets, ascSign, munthaSign);
    return VarshaphalReport(year:targetYear,age:age,solarReturn:returnTime,returnAscendant:asc,returnAscendantRashi:KundaliCalculator.rashis[ascSign],munthaRashi:KundaliCalculator.rashis[munthaSign],munthaLord:munthaLord,varsheshCandidate:varshesh,planets:returnPlanets,highlights:highlights);
  }

  static Future<DateTime> _solarReturn(DateTime approx, double target, double tz) async {
    final x = AstronomyEngineService();
    DateTime best = approx;
    double bestErr = 999;
    for (var i = -96; i <= 96; i++) {
      final t = approx.add(Duration(hours:i));
      final sun = x.calculatePlanet(t, timezoneHours:tz, bodyId:0).siderealDeg;
      final err = _angularDistance(sun, target);
      if (err < bestErr) { bestErr = err; best = t; }
    }
    var left = best.subtract(const Duration(hours:2));
    var right = best.add(const Duration(hours:2));
    for (var i=0;i<30;i++) {
      final mid = left.add(Duration(microseconds: right.difference(left).inMicroseconds ~/ 2));
      final lErr = _signedAngle(x.calculatePlanet(left,timezoneHours:tz,bodyId:0).siderealDeg,target);
      final mErr = _signedAngle(x.calculatePlanet(mid,timezoneHours:tz,bodyId:0).siderealDeg,target);
      if ((lErr <= 0 && mErr >= 0) || (lErr >= 0 && mErr <= 0)) right = mid; else left = mid;
    }
    return left.add(Duration(microseconds: right.difference(left).inMicroseconds ~/ 2));
  }

  static RemedyReport remedies(KundaliData d) {
    final focus = d.antardasha.isNotEmpty ? d.antardasha : d.mahadasha;
    final p = focus;
    final remedies = <String>[];
    final avoid = <String>[];
    switch (p) {
      case 'सूर्य': remedies.addAll(['प्रातः सूर्य को जल अर्पित करें','आदित्य हृदय स्तोत्र या सूर्य मंत्र श्रद्धा से','पिता/वरिष्ठों का सम्मान और सेवा']); avoid.add('अहंकार और अनावश्यक टकराव से बचें'); break;
      case 'चंद्र': remedies.addAll(['सोमवार को जरूरतमंदों की सहायता','माता का सम्मान और सेवा','चंद्र मंत्र/ध्यान श्रद्धा से']); avoid.add('अत्यधिक भावनात्मक निर्णयों से बचें'); break;
      case 'मंगल': remedies.addAll(['मंगलवार को सेवा/दान','हनुमान चालीसा श्रद्धा से','क्रोध को अनुशासन और व्यायाम में बदलें']); avoid.add('क्रोध में निर्णय और विवाद से बचें'); break;
      case 'बुध': remedies.addAll(['बुधवार को शिक्षा सामग्री दान','गणेश/बुध मंत्र श्रद्धा से','लेन-देन में स्पष्ट लिखित रिकॉर्ड रखें']); avoid.add('जल्दबाजी में financial commitments से बचें'); break;
      case 'गुरु': remedies.addAll(['गुरुवार को ज्ञान/शिक्षा से जुड़ी सेवा','गुरु/शिक्षक का सम्मान','पीली वस्तुओं का दान परंपरा अनुसार']); avoid.add('अति-आत्मविश्वास और अनावश्यक विस्तार से बचें'); break;
      case 'शुक्र': remedies.addAll(['शुक्रवार को जरूरतमंदों की सहायता','दाम्पत्य/संबंधों में सम्मान','कला और स्वच्छता से जुड़ी सेवा']); avoid.add('फिजूलखर्ची और अतिभोग से बचें'); break;
      case 'शनि': remedies.addAll(['शनिवार को श्रमिक/जरूरतमंद की सेवा','हनुमान चालीसा या शनि मंत्र श्रद्धा से','अनुशासन, समयपालन और ईमानदारी']); avoid.add('अन्याय, आलस्य और गैर-जिम्मेदारी से बचें'); break;
      case 'राहु': remedies.addAll(['जरूरतमंदों को उपयोगी वस्तुओं का दान','ध्यान और डिजिटल/भौतिक अनुशासन','किसी भी risky निर्णय में due diligence']); avoid.add('अफवाह, नशा और बिना जांच के speculation से बचें'); break;
      case 'केतु': remedies.addAll(['आध्यात्मिक अध्ययन/ध्यान','कुत्तों/जरूरतमंद जीवों की सेवा','अनावश्यक attachment कम करने का अभ्यास']); avoid.add('अचानक बड़े निर्णयों से बचें'); break;
    }
    final doshas = KundaliAnalysisService.doshas(d);
    if (doshas.any((x)=>x.contains('मंगल दोष'))) remedies.add('मंगलिक संकेत के लिए विवाह-मिलान में दोनों कुंडलियों का संयुक्त विश्लेषण करें।');
    if (doshas.any((x)=>x.contains('कालसर्प'))) remedies.add('कालसर्प संबंधी उपाय किसी परंपरा-विशेषज्ञ से मिलकर ही चुनें; सामान्यतः दान/सेवा को प्राथमिकता दें।');
    remedies.add('रत्न या महंगे अनुष्ठान बिना पूर्ण ग्रहबल और योग्य विशेषज्ञ की सलाह के न लें।');
    return RemedyReport(focusPlanet:p,remedies:remedies,avoid:avoid);
  }

  static List<Map<String,dynamic>> shadbala(KundaliData d) {
    const natural = {'सूर्य':60.0,'चंद्र':51.43,'मंगल':17.14,'बुध':25.71,'गुरु':34.29,'शुक्र':42.86,'शनि':8.57};
    const own = {'सूर्य':['सिंह'],'चंद्र':['कर्क'],'मंगल':['मेष','वृश्चिक'],'बुध':['मिथुन','कन्या'],'गुरु':['धनु','मीन'],'शुक्र':['वृषभ','तुला'],'शनि':['मकर','कुंभ']};
    final out=<Map<String,dynamic>>[];
    for(final p in d.planets.where((p)=>_planetOrder.contains(p.planet))){
      final dignity = own[p.planet]!.contains(p.rashi) ? 60.0 : 30.0;
      final dig = _digBala(p.planet,p.house);
      final chesta = p.isRetrograde ? 60.0 : (30.0 + (p.speed.abs()*8).clamp(0,30));
      final kala = _dayNightBala(p.planet,d.birthTime);
      final drik = _aspectScore(p,d);
      final sthana = dignity;
      final total = (sthana+dig+chesta+kala+drik+(natural[p.planet] ?? 30.0))/6;
      out.add({'planet':p.planet,'sthana':sthana,'dig':dig,'kala':kala,'chesta':chesta,'drik':drik,'naisargika':natural[p.planet] ?? 30.0,'total':total.clamp(0,60.0)});
    }
    return out;
  }

  static List<Map<String,dynamic>> bhavaBala(KundaliData d, AshtakavargaReport av) {
    final houses=KundaliAnalysisService.houses(d);
    return houses.map((h){
      final sign=KundaliCalculator.rashis.indexOf(h.sign);
      final points=av.sarva[sign];
      final occupants=h.planets.length*8;
      final kendra=[1,4,7,10].contains(h.house)?8:0;
      return {'house':h.house,'sign':h.sign,'lord':h.lord,'occupants':h.planets,'ashtakavarga':points,'score':(40+points+occupants+kendra).clamp(0,100)};
    }).toList();
  }

  static List<Map<String,String>> avastha(KundaliData d) {
    return d.planets.map((p){
      final part=p.degree%30;
      final baladi=part<6?'बाल':part<12?'कुमार':part<18?'युवा':part<24?'वृद्ध':'मृत';
      final jagrad=p.isRetrograde?'स्वप्न':(p.speed.abs()<0.1?'सुषुप्त':'जाग्रत');
      final deepta=p.isRetrograde?'विकला':(_isOwn(p)?'स्वस्थ': 'सामान्य');
      return {'planet':p.planet,'baladi':baladi,'jagrad':jagrad,'deeptadi':deepta,'status':p.isRetrograde?'वक्री':'मार्गी'};
    }).toList();
  }

  static List<String> lifeAnalysis(KundaliData d,String area){
    final h=KundaliAnalysisService.houses(d); final by={for(final p in d.planets)p.planet:p};
    final out=<String>[];
    int target; String varga;
    if(area=='विवाह'){target=7;varga='D9';} else if(area=='करियर'){target=10;varga='D10';} else if(area=='धन'){target=2;varga='D2';} else {target=6;varga='D30';}
    final th=h[target-1]; out.add('$target भाव: ${th.sign} • भावेश ${th.lord} • स्थित ग्रह: ${th.planets.isEmpty?'कोई नहीं':th.planets.join(', ')}');
    final lord=by[th.lord]; if(lord!=null) out.add('भावेश ${th.lord} ${lord.house} भाव में ${lord.rashi} में स्थित है।');
    if(area=='विवाह'){ final v=by['शुक्र']; final j=by['गुरु']; if(v!=null) out.add('शुक्र: ${v.rashi}, ${v.house} भाव${v.isRetrograde?' • वक्री':''}.'); if(j!=null) out.add('गुरु: ${j.rashi}, ${j.house} भाव${j.isRetrograde?' • वक्री':''}.'); }
    if(area=='करियर'){ final s=by['शनि']; final m=by['बुध']; if(s!=null) out.add('शनि: ${s.rashi}, ${s.house} भाव; कर्म/अनुशासन संकेत।'); if(m!=null) out.add('बुध: ${m.rashi}, ${m.house} भाव; व्यापार/बुद्धि संकेत।'); }
    if(area=='धन'){ final j=by['गुरु']; final v=by['शुक्र']; if(j!=null) out.add('गुरु: ${j.rashi}, ${j.house} भाव; विस्तार/ज्ञान आधारित धन संकेत।'); if(v!=null) out.add('शुक्र: ${v.rashi}, ${v.house} भाव; सुविधा/सौंदर्य/संबंध आधारित धन संकेत।'); }
    out.add('वर्तमान दशा: ${d.mahadasha}/${d.antardasha}; timing को $varga और दशा के साथ संयुक्त रूप से पढ़ें।');
    out.addAll(KundaliAnalysisService.yogas(d).take(3));
    return out;
  }

  static List<String> _varshaphalHighlights(KundaliData d,List<PlanetPosition> ps,int asc,int muntha){
    final out=<String>[]; final by={for(final p in ps)p.planet:p};
    final ascLord=_signLords[KundaliCalculator.rashis[asc]]!; out.add('वर्ष लग्न ${KundaliCalculator.rashis[asc]} • वर्षेश candidate $ascLord');
    out.add('मुन्था ${KundaliCalculator.rashis[muntha]} • मुन्थेश ${_signLords[KundaliCalculator.rashis[muntha]]}');
    for(final h in [1,7,10,11]){final p=ps.where((x)=>x.house==h).map((x)=>x.planet).toList(); if(p.isNotEmpty) out.add('$h भाव में ${p.join(', ')}: वर्ष के प्रमुख life-area activation का संकेत।');}
    final j=by['गुरु']; if(j!=null) out.add('वर्षफल गुरु: ${j.rashi} • भाव ${j.house}.');
    final s=by['शनि']; if(s!=null) out.add('वर्षफल शनि: ${s.rashi} • भाव ${s.house}${s.isRetrograde?' • वक्री':''}.');
    return out;
  }

  static double _digBala(String planet,int house){
    final ideal={'सूर्य':10,'मंगल':10,'चंद्र':4,'शुक्र':4,'बुध':1,'गुरु':1,'शनि':7}[planet]!;
    final dist=((house-ideal+12)%12); final closeness=dist>6?12-dist:dist; return (60-closeness*10).clamp(0,60).toDouble();
  }
  static double _dayNightBala(String planet,String time){final hour=int.tryParse(time.split(':').first)??12; final day=hour>=6&&hour<18; final daytime={'सूर्य','गुरु','शुक्र'}.contains(planet); return day==daytime?60:30;}
  static double _aspectScore(PlanetPosition p,KundaliData d){var score=30.0; for(final q in d.planets.where((x)=>x.planet!=p.planet)){final diff=((q.house-p.house+12)%12)+1; if([7].contains(diff))score+=5; if(p.planet=='गुरु'&&[5,9].contains(diff))score+=5; if(p.planet=='मंगल'&&[4,8].contains(diff))score+=5; if(p.planet=='शनि'&&[3,10].contains(diff))score+=5;} return score.clamp(0,60);}
  static bool _isOwn(PlanetPosition p){const own={'सूर्य':['सिंह'],'चंद्र':['कर्क'],'मंगल':['मेष','वृश्चिक'],'बुध':['मिथुन','कन्या'],'गुरु':['धनु','मीन'],'शुक्र':['वृषभ','तुला'],'शनि':['मकर','कुंभ']}; return own[p.planet]?.contains(p.rashi)??false;}
  static int _ascSign(KundaliData d)=>((d.lagnaDegree/30).floor())%12;
  static double _norm(double v){final n=v%360;return n<0?n+360:n;}
  static double _angularDistance(double a,double b){final d=(a-b).abs()%360;return d>180?360-d:d;}
  static double _signedAngle(double a,double b){var d=_norm(a-b);if(d>180)d-=360;return d;}
}
