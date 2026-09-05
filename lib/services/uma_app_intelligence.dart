import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';
import 'astrology_advanced_service.dart';
import 'kundali_analysis_service.dart';
import 'location_store.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// UMA's app-aware knowledge layer.
///
/// This is deliberately local and deterministic: UMA can explain the features
/// that exist in Shakti Panchang and, when a KundaliData object is available,
/// can answer from the actual calculated chart instead of generic astrology
/// text. It does not pretend to have access to unsaved UI fields or OS-level
/// notification internals.
class UmaAppIntelligence {
  const UmaAppIntelligence();

  static const List<String> moduleNames = <String>[
    'दैनिक पंचांग',
    'चौघड़िया',
    'राहु काल / यमगण्ड / गुलिक काल',
    'दिशाशूल और यात्रा',
    'शुभ समय / मुहूर्त',
    'सूर्योदय / सूर्यास्त',
    'त्योहार',
    'reminders',
    'कुंडली निर्माण',
    'D1–D60 वर्ग चार्ट',
    'ग्रह स्थिति और नक्षत्र',
    'भाव / भाव फल',
    'विम्शोत्तरी दशा',
    'योग और दोष',
    'गोचर',
    'साढ़ेसाती',
    'अष्टकवर्ग',
    'शड्बल',
    'भावबल',
    'अवस्था',
    'भाव चलित',
    'KP',
    'Jaimini',
    'Prashna',
    'Varshaphal',
    'Kundali Milan',
    'Lal Kitab',
    'व्यक्तिगत उपाय',
    'PDF रिपोर्ट',
  ];

  bool isSoftwareQuestion(String question) {
    final q = _normalize(question);
    return _has(q, ['software', 'app', 'feature', 'क्या क्या', 'ऐप में क्या', 'app me kya', 'modules', 'मॉड्यूल', 'उमा क्या जानती', 'what do you know', 'know about app', 'कुंडली कैसे', 'kundali kaise']);
  }

  String answerSoftware(String question) {
    final q = _normalize(question);
    if (_has(q, ['क्या क्या कर सकती', 'क्या कर सकते', 'features', 'feature', 'software', 'ऐप में क्या', 'app me kya', 'modules', 'मॉड्यूल'])) {
      return 'मैं Shakti Panchang के मुख्य मॉड्यूल समझा सकती हूँ: ${moduleNames.join(', ')}। '
          'कुंडली बनने के बाद मैं उसी जातक के ग्रह, भाव, नक्षत्र, दशा, योग-दोष, गोचर और उपलब्ध advanced reports को समझा सकती हूँ।';
    }
    if (_has(q, ['उमा क्या जानती', 'उमा को क्या पता', 'तुम क्या जानती', 'what do you know', 'know about app'])) {
      return 'अभी मेरा app-aware स्तर तीन हिस्सों में है: (1) Shakti Panchang के उपलब्ध modules की knowledge, '
          '(2) active KundaliData की वास्तविक गणना, और (3) saved Kundali profiles की सूची/मूल विवरण। '
          'Unsaved form fields और Android notification queue मेरे पास अपने-आप उपलब्ध नहीं होते।';
    }
    if (_has(q, ['कुंडली कैसे', 'kundali kaise', 'कुंडली बन', 'kundali module'])) {
      return 'कुंडली मॉड्यूल में नाम, जन्म तिथि, जन्म समय और जन्म स्थान दर्ज करके गणना की जाती है। '
          'इसके बाद D1–D60 charts, ग्रह, नक्षत्र, भाव, दशा और advanced analysis खोले जा सकते हैं।';
    }
    if (_has(q, ['pdf', 'पीडीएफ', 'रिपोर्ट'])) {
      return 'कुंडली से PDF रिपोर्ट बनाई जा सकती है। UMA रिपोर्ट में दिखने वाले calculated data को समझा सकती है; '
          'server-side PDF में D1–D60 के 60 chart slots और पूर्ण दशा tables रखे गए हैं।';
    }
    if (_has(q, ['मिलान', 'milan', 'compatibility'])) {
      return 'Kundali Milan मॉड्यूल में दो जन्म विवरण लेकर Ashtakoot/36 गुण आधारित मिलान किया जाता है। '
          'यदि दूसरा जन्म डेटा अभी दर्ज नहीं है तो मैं अनुमान से परिणाम नहीं बनाऊँगी।';
    }
    if (_has(q, ['kp', 'krishnamurti'])) {
      return 'KP मॉड्यूल में cusp, star lord, sub lord और उपलब्ध significator framework देखा जाता है। '
          'अंतिम KP फलित school-specific नियमों के अनुसार verify करना चाहिए।';
    }
    if (_has(q, ['jaimini', 'जैमिनी'])) {
      return 'Jaimini मॉड्यूल में उपलब्ध Chara Karaka और संबंधित framework को समझाया जा सकता है। '
          'जहाँ school-specific नियम आवश्यक हैं, वहाँ UMA उसे final universal rule की तरह प्रस्तुत नहीं करेगी।';
    }
    if (_has(q, ['lal kitab', 'लाल किताब'])) {
      return 'Lal Kitab module और उसके remedies उपलब्ध हैं। UMA इन्हें chart context के साथ समझा सकती है, '
          'लेकिन उपाय को चिकित्सकीय या कानूनी सलाह की तरह प्रस्तुत नहीं करेगी।';
    }
    if (_has(q, ['panchang', 'पंचांग', 'मुहूर्त', 'muhurat', 'यात्रा', 'travel'])) {
      return 'मैं पंचांग, शुभ समय, यात्रा, दिशाशूल, चौघड़िया, राहु काल और सूर्योदय/सूर्यास्त से जुड़े ऐप workflows समझा सकती हूँ। '
          'समय के प्रश्न में चुनी हुई तारीख और location को आधार मानना जरूरी है।';
    }
    return 'यह Shakti Panchang के app-aware ज्ञान का हिस्सा है। आप पूछ सकते हैं: “मैंने क्या data save किया है?”, '
        '“मेरी कुंडली में गुरु कहाँ है?”, “अभी कौन सी दशा है?”, “D9 क्या कहता है?”, “अष्टकवर्ग कितना है?” या '
        '“इस software में KP कैसे चलता है?”';
  }

  Future<UmaProfileSnapshot> loadSavedContext({KundaliData? active}) async {
    final profiles = await _loadSavedProfiles();
    final locations = await LocationStore().all();
    return UmaProfileSnapshot(
      active: active,
      savedProfiles: profiles,
      savedLocations: locations,
    );
  }


  Future<List<Map<String, dynamic>>> _loadSavedProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    // V10 had two profile stores. Read both so older saved profiles remain visible.
    const keys = <String>['saved_kundali_profiles', 'shakti_saved_kundali_profiles_v1'];
    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final key in keys) {
      final raw = prefs.getStringList(key) ?? const <String>[];
      for (final value in raw) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is! Map<String, dynamic>) continue;
          final date = decoded['date'] ?? decoded['birthDate'] ?? '';
          final time = decoded['time'] ?? decoded['birthTime'] ?? '';
          final place = decoded['place'] ?? decoded['birthPlace'] ?? '';
          final name = decoded['name'] ?? 'अज्ञात';
          final marker = '$name|$date|$time|$place';
          if (seen.add(marker)) out.add(decoded);
        } catch (_) {
          // Ignore a corrupt historical profile instead of breaking UMA.
        }
      }
    }
    return out.reversed.toList(growable: false);
  }

  Future<String> answerData(String question, UmaProfileSnapshot context, {String? pageContext, String? pageDescription}) async {
    final q = _normalize(question);
    final d = context.active;

    if (_has(q, ['इस पेज', 'इस page', 'यह पेज', 'पूरी जानकारी', 'पूरा समझाओ', 'explain this page', 'page info']) && pageContext != null) {
      final detail = pageDescription ?? 'इस पेज की उपलब्ध जानकारी और संबंधित data।';
      if (d == null) {
        return 'आप अभी "$pageContext" पेज पर हैं। $detail अभी active calculated Kundali उपलब्ध नहीं है, इसलिए मैं generic page guidance दे सकती हूँ। पहले कुंडली की गणना करें या saved Kundali खोलें।';
      }
      final planets = d.planets.map((p) => '${p.planet} ${p.rashi} (${p.house} भाव)').join(', ');
      return 'आप अभी "$pageContext" पेज पर हैं। $detail Active जातक ${d.name} है; जन्म ${d.birthDate.day}-${d.birthDate.month}-${d.birthDate.year} ${d.birthTime}, स्थान ${d.birthPlace}। लग्न ${d.lagnaRashi}, चंद्र राशि ${d.moonRashi}, नक्षत्र ${d.nakshatra}। ग्रह स्थिति: $planets। वर्तमान दशा: ${_dashaShort(d)}। इस पेज के chart/result को समझने के लिए मैं इसी वास्तविक data को आधार मान रही हूँ।';
    }

    if (_has(q, ['कितनी कुंडली', 'कितने profile', 'profiles', 'saved', 'सेव', 'मैंने क्या data', 'क्या डेटा', 'what data'])) {
      return context.describeSavedData();
    }

    if (d == null) {
      return context.savedProfiles.isEmpty
          ? 'अभी कोई saved Kundali profile उपलब्ध नहीं है। पहले कुंडली बनाकर सेव करें; उसके बाद UMA उसी calculated chart से उत्तर दे सकेगी।'
          : 'आपकी ${context.savedProfiles.length} saved Kundali profile(s) उपलब्ध हैं। किसी profile को active chart के रूप में खोलकर पूछें, तब UMA वास्तविक ग्रह/भाव/दशा data से उत्तर देगी।';
    }

    if (_has(q, ['सभी data', 'पूरा data', 'पूरा विवरण', 'full data', 'all data', 'birth details', 'जन्म विवरण'])) {
      return _fullChartData(d, context);
    }
    if (_has(q, ['करियर', 'career', 'नौकरी', 'job', 'व्यापार', 'business'])) {
      final h6 = _housePlanets(d, 6);
      final h10 = _housePlanets(d, 10);
      final h7 = _housePlanets(d, 7);
      return 'करियर analysis में 6वाँ, 10वाँ और 7वाँ भाव देखा जाता है। 6वाँ: $h6; 10वाँ: $h10; 7वाँ: $h7। वर्तमान दशा ${_dashaShort(d)}। इसे अंतिम भविष्यवाणी नहीं, chart-based संकेत मानें।';
    }
    if (_has(q, ['धन', 'पैसा', 'finance', 'income', 'wealth', 'आर्थिक'])) {
      return 'धन analysis में 2रा, 9वाँ और 11वाँ भाव महत्वपूर्ण हैं। 2रा: ${_housePlanets(d, 2)}; 9वाँ: ${_housePlanets(d, 9)}; 11वाँ: ${_housePlanets(d, 11)}। वर्तमान दशा ${_dashaShort(d)}।';
    }
    if (_has(q, ['विवाह', 'शादी', 'marriage', 'जीवनसाथी', 'relationship'])) {
      return 'विवाह analysis में 7वाँ भाव, 7वें भाव के स्वामी, शुक्र/गुरु, D9 और दशा-गोचर साथ देखने चाहिए। 7वें भाव में ${_housePlanets(d, 7)} हैं; शुक्र ${_planetText(d, 'शुक्र')}; गुरु ${_planetText(d, 'गुरु')}; D9 chart भी उपलब्ध है।';
    }
    if (_has(q, ['शिक्षा', 'पढ़ाई', 'पढ़ाई', 'education', 'study', 'exam'])) {
      return 'शिक्षा analysis में 4था और 5वाँ भाव तथा बुध/गुरु की स्थिति देखी जाती है। 4था: ${_housePlanets(d, 4)}; 5वाँ: ${_housePlanets(d, 5)}; बुध ${_planetText(d, 'बुध')}।';
    }
    if (_has(q, ['स्वास्थ्य', 'सेहत', 'health', 'रोग', 'बीमारी'])) {
      return 'स्वास्थ्य के लिए लग्न, 6वाँ और संबंधित ग्रहों के संकेत देखे जा सकते हैं। लग्न ${d.lagnaRashi}; 1st house: ${_housePlanets(d, 1)}; 6th house: ${_housePlanets(d, 6)}। यह चिकित्सकीय निदान नहीं है।';
    }

    if (_has(q, ['नक्षत्र', 'nakshatra', 'पाद', 'चरण'])) {
      return 'जन्म नक्षत्र ${d.nakshatra}, चरण ${d.charan}, चंद्र राशि ${d.moonRashi}, नाड़ी ${d.nadi}, गण ${d.gana}, योनि ${d.yoni}, वर्ण ${d.varna} है।';
    }
    if (_has(q, ['दशा', 'dasha', 'महादशा', 'अंतरदशा', 'प्रत्यंतर', 'pratyantar'])) {
      return _dasha(d);
    }
    if (_has(q, ['योग', 'yoga'])) {
      return 'इस chart में उपलब्ध योग analysis: ${KundaliAnalysisService.yogas(d).join(' | ')}';
    }
    if (_has(q, ['दोष', 'dosha', 'मंगल दोष', 'कालसर्प', 'kemadruma'])) {
      return 'इस chart में उपलब्ध दोष analysis: ${KundaliAnalysisService.doshas(d).join(' | ')}';
    }
    if (_has(q, ['अष्टकवर्ग', 'ashtakavarga', 'bindu'])) {
      final av = AdvancedKundaliService.ashtakavarga(d);
      final total = av.sarva.fold<int>(0, (a, b) => a + b);
      return 'अष्टकवर्ग उपलब्ध है। Sarva Ashtakavarga के 12 राशि totals: ${av.sarva.join(', ')}। कुल bindu $total।';
    }
    if (_has(q, ['शड्बल', 'shadbala', 'planet strength', 'ग्रह बल'])) {
      final rows = AdvancedKundaliService.shadbala(d);
      final top = rows.take(3).map((x) => '${x['planet']}: ${x['total']}').join(', ');
      return 'UMA के project Shadbala engine में उपलब्ध top strength signals: $top। यह simplified project score है; classical Shadbala का अंतिम निर्णय केवल इस score से नहीं लेना चाहिए।';
    }
    if (_has(q, ['भावबल', 'bhava bala'])) {
      final av = AdvancedKundaliService.ashtakavarga(d);
      final rows = AdvancedKundaliService.bhavaBala(d, av);
      final top = rows.take(3).map((x) => '${x['house']} भाव: ${x['total']}').join(', ');
      return 'भावबल data उपलब्ध है। शुरुआती तीन calculated house-strength entries: $top।';
    }
    if (_has(q, ['अवस्था', 'avastha'])) {
      final rows = AdvancedKundaliService.avastha(d);
      return 'ग्रह अवस्था data: ${rows.map((x) => '${x['planet']}=${x['state']}').join(', ')}';
    }
    if (_has(q, ['भाव', 'house', 'bhav'])) {
      final houses = KundaliAnalysisService.houses(d);
      return houses.map((h) => '${h.house} भाव ${h.sign}, भावेश ${h.lord}, ग्रह: ${h.planets.isEmpty ? 'कोई नहीं' : h.planets.join(', ')}').join('\n');
    }
    if (_has(q, ['साढ़ेसाती', 'sade sati', 'ढैय्या'])) {
      try {
        final r = await AstrologyAdvancedService.sadeSati(d);
        return 'साढ़ेसाती/ढैय्या स्थिति: ${r.status}; phase: ${r.phase}; गोचर शनि: ${r.saturnSign}; जन्म चंद्र राशि: ${r.moonSign}। पारंपरिक सुझाव: ${r.remedies.join(', ')}।';
      } catch (e) {
        return 'साढ़ेसाती engine अभी गणना नहीं कर पाया: $e';
      }
    }
    if (_has(q, ['गोचर', 'transit', 'current transit', 'आज ग्रह'])) {
      try {
        final tr = await AstrologyAdvancedService.currentTransitPlanets(d);
        return 'वर्तमान गोचर: ${tr.map((p) => '${p.planet} ${p.rashi} ${p.degree.toStringAsFixed(2)}°${p.isRetrograde ? ' वक्री' : ''}').join(' | ')}';
      } catch (e) {
        return 'गोचर engine अभी गणना नहीं कर पाया: $e';
      }
    }
    if (_has(q, ['भाव चलित', 'bhava chalit'])) {
      try {
        final houses = await AstrologyAdvancedService.bhavaChalit(d);
        return houses.map((h) => '${h.house} भाव cusp ${h.cusp.toStringAsFixed(2)}°; ग्रह: ${h.planets.isEmpty ? 'कोई नहीं' : h.planets.join(', ')}').join('\n');
      } catch (e) {
        return 'भाव चलित calculation अभी उपलब्ध नहीं हो पाई: $e';
      }
    }
    if (_has(q, ['kp cusp', 'kp cusps', 'kp sub lord', 'sub lord', 'cusp'])) {
      try {
        final cusps = await AstrologyAdvancedService.kpCusps(d);
        return cusps.map((c) => '${c.house} भाव: ${c.sign} ${c.cusp.toStringAsFixed(2)}° • Star Lord ${c.starLord} • Sub Lord ${c.subLord}').join('\n');
      } catch (e) {
        return 'KP cusp calculation अभी उपलब्ध नहीं हो पाई: $e';
      }
    }
    if (_has(q, ['jaimini', 'जैमिनी', 'chara karaka', 'आत्मकारक'])) {
      final k = AstrologyAdvancedService.jaimini(d);
      return 'Jaimini Karaka: आत्मकारक ${k.atmakaraka}, अमात्यकारक ${k.amatyakaraka}, भ्रातृकारक ${k.bhratrikaraka}, मातृकारक ${k.matrikaraka}, पितृकारक ${k.pitrikaraka}, पुत्रकारक ${k.putrakaraka}, ज्ञातिकारक ${k.gnatikaraka}, दारकारक ${k.darakaraka}। Chara Dasha framework: ${AstrologyAdvancedService.charaDashaFramework(d).join(' → ')}। Exact Chara Dasha dates school-specific हैं।';
    }

    final planet = _findPlanet(q);
    if (planet != null) {
      final p = d.planets.firstWhere((x) => x.planet == planet);
      return '$planet ${p.rashi} राशि में ${p.degree.toStringAsFixed(2)}° पर, ${p.house} भाव में है${p.isRetrograde ? ' और वक्री है' : ''}। Latitude ${p.latitude.toStringAsFixed(2)}°, speed ${p.speed.toStringAsFixed(4)}°/day।';
    }

    if (_has(q, ['d1', 'd9', 'd60', 'वर्ग', 'varga', 'divisional'])) {
      return 'D1–D60 chart slots उपलब्ध हैं। 16 प्रमुख Parashari varga rules verified हैं; बाकी extended/generalized slots को UMA उसी label के साथ समझाएगी और उन्हें classical Shodashavarga के रूप में mislabel नहीं करेगी।';
    }

    return 'Active chart: ${d.name}। लग्न ${d.lagnaRashi}, चंद्र राशि ${d.moonRashi}, सूर्य राशि ${d.sunRashi}, नक्षत्र ${d.nakshatra}। वर्तमान दशा ${_dashaShort(d)}।';
  }

  String _fullChartData(KundaliData d, UmaProfileSnapshot context) {
    final planets = d.planets.map((p) => '${p.planet}: ${p.rashi} ${p.degree.toStringAsFixed(2)}°, भाव ${p.house}${p.isRetrograde ? ' वक्री' : ''}').join(' | ');
    return 'जातक: ${d.name}\nजन्म: ${d.birthDate.day}-${d.birthDate.month}-${d.birthDate.year} ${d.birthTime}\nस्थान: ${d.birthPlace} (${d.latitude.toStringAsFixed(4)}, ${d.longitude.toStringAsFixed(4)})\nलग्न: ${d.lagnaRashi}, ${d.lagnaDegree.toStringAsFixed(2)}°\nचंद्र: ${d.moonRashi}\nसूर्य: ${d.sunRashi}\nनक्षत्र: ${d.nakshatra}, चरण ${d.charan}\nनाड़ी/गण/योनि/वर्ण: ${d.nadi}/${d.gana}/${d.yoni}/${d.varna}\nवर्तमान दशा: ${_dashaShort(d)}\nग्रह: $planets\nSaved profiles: ${context.savedProfiles.length}।';
  }

  String _dasha(KundaliData d) {
    final now = DateTime.now();
    DashaPeriod? maha;
    DashaSubPeriod? antar;
    DashaPratyantar? praty;
    for (final x in d.dashaPeriods) {
      if (!now.isBefore(x.startDate) && now.isBefore(x.endDate)) { maha = x; break; }
    }
    for (final x in d.antarPeriods) {
      if (!now.isBefore(x.startDate) && now.isBefore(x.endDate)) { antar = x; break; }
    }
    for (final x in d.pratyantarPeriods) {
      if (!now.isBefore(x.startDate) && now.isBefore(x.endDate)) { praty = x; break; }
    }
    if (maha == null) return 'विम्शोत्तरी timeline उपलब्ध है, लेकिन current date के लिए active period नहीं मिला।';
    return 'अभी महादशा ${maha.planet} (${_date(maha.startDate)}–${_date(maha.endDate)}), अंतरदशा ${antar?.antar ?? '—'}${praty == null ? '' : ', प्रत्यंतर ${praty.pratyantar}'} चल रही है।';
  }

  String _dashaShort(KundaliData d) {
    final now = DateTime.now();
    final m = d.dashaPeriods.where((x) => !now.isBefore(x.startDate) && now.isBefore(x.endDate)).toList();
    final a = d.antarPeriods.where((x) => !now.isBefore(x.startDate) && now.isBefore(x.endDate)).toList();
    return '${m.isEmpty ? d.mahadasha : m.first.planet}/${a.isEmpty ? d.antardasha : a.first.antar}';
  }

  String _date(DateTime x) => '${x.day.toString().padLeft(2, '0')}-${x.month.toString().padLeft(2, '0')}-${x.year}';

  String? _findPlanet(String q) {
    const names = <String>['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','राहु','केतु'];
    const aliases = <String, String>{
      'sun': 'सूर्य', 'moon': 'चंद्र', 'mars': 'मंगल', 'mercury': 'बुध', 'jupiter': 'गुरु',
      'venus': 'शुक्र', 'saturn': 'शनि', 'rahu': 'राहु', 'ketu': 'केतु',
    };
    for (final x in names) { if (q.contains(x)) return x; }
    for (final x in aliases.entries) { if (q.contains(x.key)) return x.value; }
    return null;
  }

  String _housePlanets(KundaliData d, int house) {
    final values = d.planets.where((p) => p.house == house).map((p) => p.planet).toList();
    return values.isEmpty ? 'कोई प्रमुख ग्रह नहीं' : values.join(', ');
  }

  String _planetText(KundaliData d, String name) {
    final p = d.planets.firstWhere((x) => x.planet == name);
    return '${p.rashi}, भाव ${p.house}, ${p.degree.toStringAsFixed(2)}°${p.isRetrograde ? ', वक्री' : ''}';
  }

  String _normalize(String value) => value.toLowerCase().trim().replaceAll('क़', 'क').replaceAll('ड़', 'ड़');
  bool _has(String q, List<String> values) => values.any(q.contains);
}

class UmaProfileSnapshot {
  const UmaProfileSnapshot({
    required this.active,
    required this.savedProfiles,
    required this.savedLocations,
  });

  final KundaliData? active;
  final List<Map<String, dynamic>> savedProfiles;
  final List<SavedLocation> savedLocations;

  String describeSavedData() {
    if (savedProfiles.isEmpty) {
      return 'अभी कोई saved Kundali profile नहीं है। Saved locations: ${savedLocations.isEmpty ? 'कोई नहीं' : savedLocations.map((x) => x.name).join(', ')}।';
    }
    final names = savedProfiles.map((p) {
      final birth = p['date'] ?? p['birthDate'] ?? 'जन्म तिथि नहीं';
      final time = p['time'] ?? p['birthTime'] ?? 'समय नहीं';
      final place = p['place'] ?? p['birthPlace'] ?? 'स्थान नहीं';
      return '${p['name'] ?? 'अज्ञात'} — $birth • $time • $place';
    }).join(' | ');
    return 'अभी ${savedProfiles.length} saved Kundali profiles हैं: $names। Saved locations: ${savedLocations.isEmpty ? 'कोई नहीं' : savedLocations.map((x) => '${x.name} (${x.latitude.toStringAsFixed(3)}, ${x.longitude.toStringAsFixed(3)})').join(' | ')}।';
  }}
