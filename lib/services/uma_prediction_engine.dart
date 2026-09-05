import '../models/kundali_model.dart';
import 'kundali_analysis_service.dart';

class UmaPrediction {
  const UmaPrediction({required this.area, required this.headline, required this.why, required this.period, required this.strength, required this.caution, required this.guidance});
  final String area;
  final String headline;
  final String why;
  final String period;
  final String strength;
  final String caution;
  final String guidance;

  Map<String, String> toMap() => {'area': area, 'headline': headline, 'why': why, 'period': period, 'strength': strength, 'caution': caution, 'guidance': guidance};
}

/// UMA's structured interpretation layer. It consumes normalized chart data and
/// never exposes the underlying astronomical provider to the user.
class UmaPredictionEngine {
  const UmaPredictionEngine();

  List<UmaPrediction> all(KundaliData d) => [
        createFor(d, 'करियर', 10, 'D10', 'काम, पेशा और प्रतिष्ठा', 'शनि और बुध के संकेतों को साथ पढ़ें।'),
        createFor(d, 'धन', 2, 'D2', 'धन, संचय और आय', 'गुरु/शुक्र तथा 11वें भाव के लाभ संकेतों को भी साथ देखें।'),
        createFor(d, 'विवाह', 7, 'D9', 'विवाह और साझेदारी', 'शुक्र, गुरु, सप्तम भाव और नवांश को संयुक्त रूप से देखें।'),
        createFor(d, 'शिक्षा', 5, 'D24', 'शिक्षा, बुद्धि और अध्ययन', 'बुध तथा 4थे/5वें भाव के संकेत महत्वपूर्ण हैं।'),
        createFor(d, 'व्यवसाय', 7, 'D10', 'व्यवसाय, साझेदारी और ग्राहक', '7वें तथा 10वें भाव के संकेतों को साथ रखें।'),
        createFor(d, 'संपत्ति', 4, 'D4', 'घर, भूमि और संपत्ति', '4थे भाव, उसके स्वामी और D4 संकेतों को साथ देखें।'),
        createFor(d, 'विदेश यात्रा', 12, 'D12', 'विदेश, दूर यात्रा और स्थान परिवर्तन', '12वें, 9वें भाव और राहु/केतु के संकेतों को साथ देखें।'),
        createFor(d, 'संतान', 5, 'D7', 'संतान और पारिवारिक विस्तार', '5वें भाव, गुरु और D7 को संयुक्त रूप से देखें।'),
        createFor(d, 'स्वास्थ्य संकेत', 6, 'D30', 'स्वास्थ्य और दैनिक अनुशासन', 'लग्न, 6वां भाव और वर्तमान दशा को साथ देखें।'),
      ];

  UmaPrediction createFor(KundaliData d, String area, int houseNumber, String varga, String subject, String extraWhy) {
    final houses = KundaliAnalysisService.houses(d);
    final h = houses[houseNumber - 1];
    final occupant = h.planets.isEmpty ? 'इस भाव में कोई ग्रह नहीं है' : '${h.planets.join(', ')} स्थित हैं';
    PlanetPosition? lord;
    for (final p in d.planets) { if (p.planet == h.lord) { lord = p; break; } }
    final lordText = lord == null ? 'भावेश की स्थिति उपलब्ध नहीं है' : 'भावेश ${h.lord} ${lord.house}वें भाव में ${lord.rashi} में है${lord.isRetrograde ? ' और वक्री है' : ''}।';
    final score = _score(h, lord);
    final strength = score >= 70 ? 'मजबूत संकेत' : score >= 50 ? 'मध्यम संकेत' : 'मिश्रित संकेत';
    final period = _period(d);
    final headline = score >= 70
        ? '$subject में सकारात्मक संभावनाएँ दिखाई देती हैं।'
        : score >= 50
            ? '$subject में अवसर और सावधानी दोनों के संकेत हैं।'
            : '$subject में धैर्य, योजना और सावधानी अधिक उपयोगी रहेगी।';
    return UmaPrediction(
      area: area,
      headline: headline,
      why: '$houseNumberवां भाव ${h.sign} राशि में है; $occupant। $lordText $extraWhy',
      period: period,
      strength: strength,
      caution: _caution(area),
      guidance: _guidance(area, varga),
    );
  }

  String _period(KundaliData d) {
    final now = DateTime.now();
    DashaPeriod? maha;
    for (final x in d.dashaPeriods) { if (!now.isBefore(x.startDate) && now.isBefore(x.endDate)) { maha = x; break; } }
    DashaSubPeriod? antar;
    for (final x in d.antarPeriods) { if (!now.isBefore(x.startDate) && now.isBefore(x.endDate)) { antar = x; break; } }
    if (maha != null && antar != null) return '${maha.planet} महादशा • ${antar.antar} अंतरदशा (${_date(maha.startDate)}–${_date(maha.endDate)})';
    if (maha != null) return '${maha.planet} महादशा (${_date(maha.startDate)}–${_date(maha.endDate)})';
    return 'वर्तमान दशा के संदर्भ में';
  }

  String _date(DateTime d) => '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

  double _score(HouseInfo h, PlanetPosition? lord) {
    var score = 50.0;
    if ([1, 4, 5, 7, 9, 10, 11].contains(h.house)) score += 10;
    score += (h.planets.length * 4).clamp(0, 16);
    if (lord != null && [1, 4, 5, 7, 9, 10, 11].contains(lord.house)) score += 12;
    if (lord?.isRetrograde == true) score -= 5;
    return score.clamp(0, 100);
  }

  String _caution(String area) {
    if (area.contains('स्वास्थ्य')) return 'यह चिकित्सकीय निदान नहीं है; स्वास्थ्य समस्या में योग्य डॉक्टर की सलाह लें।';
    if (area.contains('धन')) return 'निवेश या ऋण का निर्णय केवल ज्योतिषीय संकेत पर न लें।';
    if (area.contains('विवाह')) return 'किसी एक योग/दोष से विवाह का अंतिम निर्णय न लें।';
    return 'फलादेश को संकेत मानें; वास्तविक परिस्थितियों, प्रयास और निर्णय को प्राथमिकता दें।';
  }

  String _guidance(String area, String varga) => '$varga संकेतों के साथ वर्तमान दशा/गोचर मिलाकर देखें। $area में चरणबद्ध योजना बनाएं, महत्वपूर्ण निर्णयों की स्वतंत्र पुष्टि करें।';

  UmaPrediction create({required String area, required String headline, required String why, required String period, required String strength, String caution = 'ज्योतिषीय संकेतों को मार्गदर्शन के रूप में लें।', String guidance = 'व्यावहारिक परिस्थितियों के साथ मिलाकर निर्णय लें।'}) => UmaPrediction(area: area, headline: headline, why: why, period: period, strength: strength, caution: caution, guidance: guidance);

  Map<String, String> normalize(Map<String, dynamic> raw) => {
        'area': '${raw['area'] ?? 'सामान्य'}',
        'headline': '${raw['headline'] ?? 'विश्लेषण उपलब्ध है।'}',
        'why': '${raw['why'] ?? 'कुंडली के उपलब्ध संकेतों के आधार पर।'}',
        'period': '${raw['period'] ?? 'समय-निर्भर'}',
        'strength': '${raw['strength'] ?? 'मध्यम'}',
        'caution': '${raw['caution'] ?? 'ज्योतिषीय संकेतों को मार्गदर्शन के रूप में लें।'}',
        'guidance': '${raw['guidance'] ?? 'व्यावहारिक योजना बनाकर आगे बढ़ें।'}',
      };
}
