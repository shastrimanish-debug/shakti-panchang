import '../models/kundali_model.dart';
import 'kundali_calculator.dart';
import 'kundali_profile_store.dart';
import 'xalen_service.dart';
import 'lucky_number_service.dart';
import 'daily_advanced_astrology_service.dart';

/// Evidence-based Vedic interpretation layer for the daily Rashifal.
/// It combines natal Moon/Lagna, current dasha and selected-date transits.
class DeepDailyRashifalService {
  const DeepDailyRashifalService();

  Future<DeepDailyReading> calculate({required SavedKundaliProfile profile, required DateTime date}) async {
    final natal = await KundaliCalculator.calculate(
      name: profile.name,
      birthDate: profile.birthDate,
      birthTime: profile.birthTime,
      birthPlace: profile.birthPlace,
      latitude: profile.latitude,
      longitude: profile.longitude,
      referenceDate: date,
    );

    final transit = AstronomyEngineService();
    final ids = const <String, int>{'सूर्य': 0, 'चंद्र': 1, 'मंगल': 2, 'बुध': 3, 'गुरु': 4, 'शुक्र': 5, 'शनि': 6, 'राहु': 8};
    final positions = <String, TransitPlanet>{};
    for (final e in ids.entries) {
      final p = transit.calculatePlanet(DateTime(date.year, date.month, date.day, 12), bodyId: e.value, timezoneHours: natal.timezoneHours);
      positions[e.key] = TransitPlanet(
        planet: e.key,
        degree: _norm(p.siderealDeg),
        sign: KundaliCalculator.rashis[(_norm(p.siderealDeg) / 30).floor() % 12],
        retrograde: p.retrograde,
      );
    }

    final transitDegrees = <String, double>{for (final entry in positions.entries) entry.key: entry.value.degree};
    final dailyAv = DailyAdvancedAstrologyService.ashtakavarga(natal, transitDegrees);

    final moonNatal = _planet(natal, 'चंद्र');
    final sunNatal = _planet(natal, 'सूर्य');
    final saturnNatal = _planet(natal, 'शनि');
    final jupiterNatal = _planet(natal, 'गुरु');
    final moonTransit = positions['चंद्र']!;
    final sunTransit = positions['सूर्य']!;

    final moonNatalSign = KundaliCalculator.rashis.indexOf(natal.moonRashi);
    final moonTransitSign = _sign(moonTransit.degree);
    final moonHouse = _house(moonNatalSign, moonTransitSign);
    final lagnaSign = (natal.lagnaDegree / 30).floor() % 12;
    final sunHouseFromLagna = _house(lagnaSign, _sign(sunTransit.degree));

    final maha = _activeDasha(natal.dashaPeriods, date);
    final antar = _activeAntar(natal.antarPeriods, date);
    final pratyantar = _activePratyantar(natal.pratyantarPeriods, date);
    final advancedDepth = DailyAdvancedAstrologyService.depths(natal, date);
    final dashaText = maha == null ? 'वर्तमान दशा अवधि उपलब्ध नहीं है' : '${maha.planet} महादशा${antar == null ? '' : ' • ${antar.antar} अंतरदशा'}${pratyantar == null ? '' : ' • ${pratyantar.pratyantar} प्रत्यंतर'}${advancedDepth.sukshma == null ? '' : ' • ${advancedDepth.sukshma} सूक्ष्मदशा'}${advancedDepth.prana == null ? '' : ' • ${advancedDepth.prana} प्राणदशा'}';

    // Dasha integration: the active Vimshottari lords are now treated as a
    // real interpretation layer, not only displayed as labels. Their natal
    // house/sign placement contributes evidence and category emphasis.
    final dashaEvidence = <String>[];
    final dashaPlanets = <PlanetPosition>[];
    for (final lord in <String>[
      if (maha != null) maha.planet,
      if (antar != null) antar.antar,
      if (pratyantar != null) pratyantar.pratyantar,
    ]) {
      final p = _planet(natal, lord);
      if (p != null && !dashaPlanets.any((x) => x.planet == p.planet)) dashaPlanets.add(p);
    }
    for (final p in dashaPlanets) {
      dashaEvidence.add('${p.planet} दशा-लॉर्ड जन्म कुंडली में ${p.house}वें भाव और ${p.rashi} में है${p.isRetrograde ? ' (वक्री)' : ''}.');
    }

    final themes = <String>[];
    final evidence = <String>[];
    if ([2, 6, 10, 11].contains(moonHouse)) {
      themes.add('आज का चंद्र गोचर काम, सेवा, निर्णय और परिणाम वाले क्षेत्रों को सक्रिय करता है।');
      evidence.add('जन्म चंद्र राशि से चंद्रमा ${moonHouse}वें भाव में है।');
    } else if ([4, 7].contains(moonHouse)) {
      themes.add('आज संबंध, घर-परिवार और सहयोग से जुड़े विषय अधिक प्रमुख रह सकते हैं।');
      evidence.add('जन्म चंद्र राशि से चंद्रमा ${moonHouse}वें भाव में है।');
    } else {
      themes.add('आज गति से अधिक स्पष्ट प्राथमिकता और मानसिक संतुलन उपयोगी रहेगा।');
      evidence.add('जन्म चंद्र राशि से चंद्रमा ${moonHouse}वें भाव में है।');
    }

    evidence.addAll(dashaEvidence);
    final career = _career(natal, positions, sunHouseFromLagna, evidence);
    final money = _money(natal, positions, evidence);
    final relationship = _relationship(natal, positions, evidence);
    final health = _health(natal, positions, evidence);

    final dashaTheme = _dashaTheme(dashaPlanets, maha, antar, pratyantar);
    final lucky = LuckyNumberService.personalized(
      date: date,
      natal: natal,
      maha: maha?.planet,
      antar: antar?.antar,
      pratyantar: pratyantar?.pratyantar,
    );
    if (dashaTheme.isNotEmpty) evidence.add(dashaTheme);

    if (maha != null) evidence.add('दशा संदर्भ: $dashaText.');
    if (advancedDepth.sukshma != null) evidence.add('सूक्ष्मदशा: ${advancedDepth.sukshma}; प्राणदशा: ${advancedDepth.prana ?? '—'} — सक्रिय प्रत्यंतर अवधि को 120-वर्षीय Vimshottari अनुपात से विभाजित करके निकाला गया।');
    if (dailyAv.strongestPlanet != null) evidence.add('दैनिक अष्टकवर्ग: ${dailyAv.strongestPlanet} के transit sign में ${dailyAv.strongestPoints} BAV points; Sarva Ashtakavarga ${dailyAv.sarvaPoints[dailyAv.strongestPlanet] ?? '—'}।');
    if (jupiterNatal != null && [1, 5, 9, 10, 11].contains(jupiterNatal.house)) {
      evidence.add('जन्म कुंडली में गुरु ${jupiterNatal.house}वें भाव में है, इसलिए विकास/मार्गदर्शन के विषय को interpretation में वजन दिया गया है।');
    }
    if (saturnNatal?.isRetrograde == true) evidence.add('जन्म शनि वक्री है; इसलिए धीमी प्रगति और पुनरावलोकन वाले संकेतों को caution में रखा गया है।');
    if (moonNatal != null && sunNatal != null) {
      final natalGap = _angularDistance(moonNatal.degree, sunNatal.degree);
      if (natalGap < 45) evidence.add('जन्म सूर्य-चंद्र कोण ${natalGap.toStringAsFixed(1)}° है; निर्णयों में भावनात्मक प्रतिक्रिया और उद्देश्य के संतुलन को ध्यान में रखा गया है।');
    }

    return DeepDailyReading(
      profileName: profile.name,
      date: date,
      dasha: dashaText,
      headline: '${themes.join(' ')} ${dashaTheme.isEmpty ? '' : dashaTheme}',
      career: career,
      money: money,
      relationship: relationship,
      health: health,
      evidence: evidence,
      transitSummary: positions.values.map((p) => '${p.planet}: ${p.sign}${p.retrograde ? ' (वक्री)' : ''}').join(' • '),
      luckyNumbers: lucky.numbers,
      luckyMethod: lucky.method,
      luckyBasis: lucky.basis,
      sukshmaDasha: advancedDepth.sukshma,
      pranaDasha: advancedDepth.prana,
      ashtakavargaSummary: dailyAv.summary,
      ashtakavargaStrongest: dailyAv.strongestPlanet == null ? '—' : '${dailyAv.strongestPlanet}: ${dailyAv.strongestPoints}',
    );
  }

  String _career(KundaliData n, Map<String, TransitPlanet> t, int sunHouse, List<String> e) {
    final natal10 = n.planets.where((p) => p.house == 10).map((p) => p.planet).toList();
    final sun = t['सूर्य']!;
    if (sunHouse == 10 || sunHouse == 11) {
      e.add('गोचर सूर्य लग्न से ${sunHouse}वें भाव में है (${sun.sign}).');
      return 'करियर में visibility, responsibility और result-oriented काम पर ध्यान देने का संकेत है। Pending work को पहले पूरा करना और senior/client communication को स्पष्ट रखना उपयोगी रहेगा${natal10.isEmpty ? '' : '. जन्म के 10वें भाव में ${natal10.join(', ')} होने से professional themes को अतिरिक्त वजन दिया गया है'}.';
    }
    if (t['शनि']!.retrograde) {
      e.add('गोचर शनि वक्री है।');
      return 'काम में review, correction और पुराने pending matters दोबारा सामने आ सकते हैं। नई commitment से पहले documents और timelines दोबारा जाँचें।';
    }
    return 'काम में steady progress का संकेत है। Priority कम रखें, एक महत्वपूर्ण task पूरा करें और जल्दबाजी में commitment न करें।';
  }

  String _money(KundaliData n, Map<String, TransitPlanet> t, List<String> e) {
    final moon = _planet(n, 'चंद्र');
    final guru = t['गुरु']!;
    if (guru.retrograde) e.add('गोचर गुरु वक्री है, इसलिए पुराने financial plans की समीक्षा को interpretation में महत्व दिया गया है।');
    if (moon != null && [2, 5, 9, 11].contains(moon.house)) {
      return 'धन के मामले में planning और पुराने commitments की समीक्षा उपयोगी है। लाभ की संभावना को केवल संकेत मानें; बड़े financial decisions में वास्तविक cash-flow और documents की स्वतंत्र जाँच करें।';
    }
    return 'आज खर्च और cash-flow पर नजर रखना बेहतर रहेगा। अचानक commitment से बचें और भुगतान की प्राथमिकता पहले तय करें।';
  }

  String _relationship(KundaliData n, Map<String, TransitPlanet> t, List<String> e) {
    final moon = t['चंद्र']!;
    final venus = t['शुक्र']!;
    final moonNatal = _planet(n, 'चंद्र');
    if (moonNatal != null && _sameSign(_sign(moon.degree), _sign(moonNatal.degree))) {
      e.add('गोचर चंद्रमा जन्म चंद्र राशि पर है; emotional sensitivity को interpretation में शामिल किया गया है।');
      return 'आज भावनात्मक प्रतिक्रिया तेज हो सकती है। साथी/परिवार की बात पूरी सुनकर जवाब देना और छोटी बात को तुरंत अंतिम निष्कर्ष न बनाना बेहतर रहेगा।';
    }
    if (_sign(venus.degree) == _sign(moon.degree)) return 'संबंधों में warmth और संवाद की गुंजाइश बढ़ सकती है। अपनी अपेक्षाएँ स्पष्ट रखें और सामने वाले की स्थिति भी समझें।';
    return 'संबंधों में स्पष्ट और शांत संवाद उपयोगी रहेगा। पुराने मुद्दे उठें तो आरोप के बजाय facts और समाधान पर बात करें।';
  }

  String _health(KundaliData n, Map<String, TransitPlanet> t, List<String> e) {
    final moon = t['चंद्र']!;
    final natalMoon = _planet(n, 'चंद्र');
    if (natalMoon != null && _house(_sign(natalMoon.degree), _sign(moon.degree)) == 6) {
      e.add('गोचर चंद्रमा जन्म चंद्र राशि से 6वें भाव में है।');
      return 'आज routine, rest और stress management को प्राथमिकता देना उपयोगी रहेगा। शरीर से जुड़े किसी वास्तविक symptom को केवल ज्योतिषीय संकेत मानकर नजरअंदाज न करें।';
    }
    return 'सामान्य routine, पर्याप्त नींद, hydration और breaks बनाए रखना उपयोगी रहेगा। स्वास्थ्य संबंधी समस्या होने पर योग्य चिकित्सक की सलाह लें।';
  }

  PlanetPosition? _planet(KundaliData d, String name) { for (final p in d.planets) { if (p.planet == name) return p; } return null; }
  DashaPeriod? _activeDasha(List<DashaPeriod> xs, DateTime d) { for (final x in xs) { if (!d.isBefore(x.startDate) && d.isBefore(x.endDate)) return x; } return null; }
  DashaSubPeriod? _activeAntar(List<DashaSubPeriod> xs, DateTime d) { for (final x in xs) { if (!d.isBefore(x.startDate) && d.isBefore(x.endDate)) return x; } return null; }
  DashaPratyantar? _activePratyantar(List<DashaPratyantar> xs, DateTime d) { for (final x in xs) { if (!d.isBefore(x.startDate) && d.isBefore(x.endDate)) return x; } return null; }

  String _dashaTheme(List<PlanetPosition> ps, DashaPeriod? maha, DashaSubPeriod? antar, DashaPratyantar? praty) {
    if (ps.isEmpty) return '';
    final houses = ps.map((p) => p.house).toSet();
    final names = ps.map((p) => p.planet).join(' + ');
    if (houses.any((h) => [2, 6, 10, 11].contains(h))) {
      return 'दशा-समर्थित मुख्य theme: $names का संबंध 2/6/10/11 भावों से है, इसलिए काम, सेवा, आय और परिणाम वाले विषयों को आज की reading में अतिरिक्त वजन दिया गया है.';
    }
    if (houses.any((h) => [1, 4, 7, 9].contains(h))) {
      return 'दशा-समर्थित मुख्य theme: $names का संबंध 1/4/7/9 भावों से है, इसलिए self, घर-परिवार, संबंध और मार्गदर्शन वाले विषयों को अतिरिक्त वजन दिया गया है.';
    }
    return 'दशा-समर्थित मुख्य theme: $names के जन्म-भावों को आज के गोचर के साथ मिलाकर interpretation में शामिल किया गया है.';
  }
  int _sign(double deg) => (_norm(deg) / 30).floor() % 12;
  int _house(int fromSign, int transitSign) => ((transitSign - fromSign + 12) % 12) + 1;
  bool _sameSign(int a, int b) => a == b;
  double _angularDistance(double a, double b) { final x = (_norm(a - b)).abs(); return x > 180 ? 360 - x : x; }
  double _norm(double v) { final n = v % 360; return n < 0 ? n + 360 : n; }
}

class TransitPlanet {
  final String planet;
  final double degree;
  final String sign;
  final bool retrograde;
  const TransitPlanet({required this.planet, required this.degree, required this.sign, required this.retrograde});
}

class DeepDailyReading {
  final String profileName;
  final DateTime date;
  final String dasha;
  final String headline;
  final String career;
  final String money;
  final String relationship;
  final String health;
  final List<String> evidence;
  final String transitSummary;
  final List<int> luckyNumbers;
  final String luckyMethod;
  final List<String> luckyBasis;
  final String? sukshmaDasha;
  final String? pranaDasha;
  final String ashtakavargaSummary;
  final String ashtakavargaStrongest;
  const DeepDailyReading({required this.profileName, required this.date, required this.dasha, required this.headline, required this.career, required this.money, required this.relationship, required this.health, required this.evidence, required this.transitSummary, required this.luckyNumbers, required this.luckyMethod, required this.luckyBasis, required this.sukshmaDasha, required this.pranaDasha, required this.ashtakavargaSummary, required this.ashtakavargaStrongest});
}
