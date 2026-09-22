import 'astronomical_panchang_service.dart';
import 'meeus_engine.dart';
import 'lucky_number_service.dart';

/// Calculation-driven daily Rashifal engine.
///
/// The reading is generated from the app's astronomical Panchang values for
/// the selected date/location (sidereal Sun, Moon, tithi, nakshatra, yoga,
/// plus the Meeus mean lunar node). It is intentionally deterministic: the
/// same date, location and rashi produce the same result.
class DailyRashifalEngine {
  static const rashis = <String>[
    'मेष','वृषभ','मिथुन','कर्क','सिंह','कन्या',
    'तुला','वृश्चिक','धनु','मकर','कुंभ','मीन',
  ];

  static const _weekdays = <int, String>{
    1: 'सोमवार', 2: 'मंगलवार', 3: 'बुधवार', 4: 'गुरुवार',
    5: 'शुक्रवार', 6: 'शनिवार', 7: 'रविवार',
  };

  final AstronomicalPanchangService _panchang = AstronomicalPanchangService();

  Future<DailyRashifalResult> calculate({
    required DateTime date,
    required int rashiIndex,
    required double latitude,
    required double longitude,
  }) async {
    if (rashiIndex < 0 || rashiIndex >= rashis.length) {
      throw ArgumentError.value(rashiIndex, 'rashiIndex');
    }

    final p = await _panchang.calculate(
      date: date,
      latitude: latitude,
      longitude: longitude,
    );

    final moonSign = _signIndex(p.lunarLongitude);
    final sunSign = _signIndex(p.solarLongitude);
    final nodeTropical = MeeusEngine.meanNodeTropical(p.localSunrise);
    final nodeSidereal = _norm(nodeTropical - p.ayanamsha);
    final nodeSign = _signIndex(nodeSidereal);

    // House-like distance from the selected Moon sign to today's transiting
    // Moon/Sun/node signs. This is a simple traditional rashi transit layer,
    // not a replacement for a complete natal-chart transit report.
    final moonHouse = _houseFrom(rashiIndex, moonSign);
    final sunHouse = _houseFrom(rashiIndex, sunSign);
    final nodeHouse = _houseFrom(rashiIndex, nodeSign);

    final theme = _theme(moonHouse, sunHouse, p.tithiNumber, p.yogaNumber);
    final career = _career(sunHouse, moonHouse, p.weekday);
    final money = _money(sunHouse, nodeHouse, p.tithiNumber);
    final love = _love(moonHouse, sunHouse);
    final health = _health(moonHouse, p.nakshatraNumber);
    final lucky = LuckyNumberService.daily(
      date: date,
      rashi: rashis[rashiIndex],
      transitMoonRashi: rashis[moonSign],
    );
    final colors = const ['लाल','सफेद','पीला','हरा','गुलाबी','नीला','गहरा लाल','भूरा','केसरिया'];

    return DailyRashifalResult(
      date: date,
      rashi: rashis[rashiIndex],
      weekday: _weekdays[date.weekday] ?? '',
      theme: theme,
      career: career,
      money: money,
      love: love,
      health: health,
      luckyNumber: lucky.primary,
      luckyNumbers: lucky.numbers,
      luckyColor: colors[lucky.primary - 1],
      luckyMethod: lucky.method,
      moonSign: rashis[moonSign],
      sunSign: rashis[sunSign],
      nodeSign: rashis[nodeSign],
      moonHouse: moonHouse,
      sunHouse: sunHouse,
      nodeHouse: nodeHouse,
      tithi: p.tithi,
      nakshatra: p.nakshatra,
      yoga: p.yoga,
      calculationEngine: p.engine,
    );
  }

  int _signIndex(double longitude) => (_norm(longitude) / 30.0).floor().clamp(0, 11);

  int _houseFrom(int natalRashi, int transitSign) => ((transitSign - natalRashi + 12) % 12) + 1;

  String _theme(int moonHouse, int sunHouse, int tithi, int yoga) {
    if (moonHouse == 10 || sunHouse == 10) return 'काम और लक्ष्य पर ध्यान देने का दिन है।';
    if (moonHouse == 7 || sunHouse == 7) return 'साझेदारी, बातचीत और रिश्तों को प्राथमिकता दें।';
    if (moonHouse == 2 || moonHouse == 11) return 'धन, परिवार और लाभ से जुड़े मामलों पर ध्यान रहेगा।';
    if (tithi % 3 == 0) return 'योजना बनाकर धीरे-धीरे आगे बढ़ना आज अधिक उपयोगी रहेगा।';
    if (yoga % 4 == 0) return 'अधूरे काम व्यवस्थित करके आगे बढ़ने का अच्छा अवसर है।';
    return 'आज प्राथमिकताएँ स्पष्ट रखकर संतुलित तरीके से आगे बढ़ें।';
  }

  String _career(int sunHouse, int moonHouse, int weekday) {
    if (sunHouse == 10 || moonHouse == 10) return 'काम में visibility और जिम्मेदारी बढ़ सकती है। महत्वपूर्ण काम पहले पूरा करें।';
    if (sunHouse == 6 || moonHouse == 6) return 'प्रतिस्पर्धा और pending work पर focus रखें। छोटे विवादों को बढ़ने न दें।';
    if (sunHouse == 11 || moonHouse == 11) return 'नेटवर्किंग और पुराने contacts से उपयोगी अवसर मिल सकते हैं।';
    if (weekday == 3) return 'Communication, documents और negotiations को व्यवस्थित रखना लाभदायक रहेगा।';
    return 'एक समय में एक प्राथमिकता लेकर काम करें और जल्दबाजी में commitment न करें।';
  }

  String _money(int sunHouse, int nodeHouse, int tithi) {
    if (sunHouse == 2 || sunHouse == 11) return 'आय और collections पर ध्यान देने का दिन है। जरूरी भुगतान और savings को व्यवस्थित करें।';
    if (nodeHouse == 8) return 'अचानक खर्च या पुराने financial obligations सामने आ सकते हैं। बड़े निर्णय में अतिरिक्त जाँच करें।';
    if (tithi % 2 == 0) return 'खर्च की समीक्षा करें और गैर-जरूरी खरीद को टालना उपयोगी रहेगा।';
    return 'Cash-flow पर नजर रखें और आज किसी भी बड़े financial commitment को समझकर ही करें।';
  }

  String _love(int moonHouse, int sunHouse) {
    if (moonHouse == 7 || sunHouse == 7) return 'साथी या परिवार के साथ खुलकर बात करने से गलतफहमी कम हो सकती है।';
    if (moonHouse == 4) return 'घर-परिवार का समय भावनात्मक रूप से सहायक रहेगा।';
    if (moonHouse == 12) return 'थोड़ा personal space लेना और शांत बातचीत करना बेहतर रहेगा।';
    return 'अपनी बात स्पष्ट रखें और सामने वाले की बात बीच में काटे बिना सुनें।';
  }

  String _health(int moonHouse, int nakshatra) {
    if (moonHouse == 6 || moonHouse == 12) return 'आराम, पानी और नियमित भोजन पर विशेष ध्यान दें। तनाव को अनदेखा न करें।';
    if (nakshatra % 5 == 0) return 'आज routine बनाए रखना और पर्याप्त नींद लेना उपयोगी रहेगा।';
    return 'सामान्य routine बनाए रखें, पर्याप्त पानी लें और लंबे समय तक लगातार काम करने से बचें।';
  }

  double _norm(double value) {
    final v = value % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}

class DailyRashifalResult {
  final DateTime date;
  final String rashi;
  final String weekday;
  final String theme;
  final String career;
  final String money;
  final String love;
  final String health;
  final int luckyNumber;
  final List<int> luckyNumbers;
  final String luckyColor;
  final String luckyMethod;
  final String moonSign;
  final String sunSign;
  final String nodeSign;
  final int moonHouse;
  final int sunHouse;
  final int nodeHouse;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String calculationEngine;

  const DailyRashifalResult({
    required this.date,
    required this.rashi,
    required this.weekday,
    required this.theme,
    required this.career,
    required this.money,
    required this.love,
    required this.health,
    required this.luckyNumber,
    required this.luckyNumbers,
    required this.luckyColor,
    required this.luckyMethod,
    required this.moonSign,
    required this.sunSign,
    required this.nodeSign,
    required this.moonHouse,
    required this.sunHouse,
    required this.nodeHouse,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.calculationEngine,
  });
}
