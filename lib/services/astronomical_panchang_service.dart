import '../models/astronomical_panchang.dart';
import 'solar_service.dart';
import 'xalen_service.dart';

/// Primary Panchang calculation service.
///
/// The primary Sun/Moon astronomical engine is used for precise sidereal calculations. Sunrise/sunset are
/// supplied by the local solar-time service because the current native
/// ABI exposes planetary longitudes, not rise/set events.
/// Swiss Ephemeris remains available only in the separate diagnostic/raw
/// comparison screens; it is not used for the Panchang's core tithi,
/// nakshatra, yoga or karana values here.
class AstronomicalPanchangService {
  static const _tithiNames = [
    'प्रतिपदा','द्वितीया','तृतीया','चतुर्थी','पंचमी','षष्ठी','सप्तमी',
    'अष्टमी','नवमी','दशमी','एकादशी','द्वादशी','त्रयोदशी','चतुर्दशी','पूर्णिमा'
  ];
  static const _nakshatras = [
    'अश्विनी','भरणी','कृत्तिका','रोहिणी','मृगशीर्ष','आर्द्रा','पुनर्वसु',
    'पुष्य','आश्लेषा','मघा','पूर्वा फाल्गुनी','उत्तरा फाल्गुनी','हस्त',
    'चित्रा','स्वाती','विशाखा','अनुराधा','ज्येष्ठा','मूल','पूर्वाषाढ़ा',
    'उत्तराषाढ़ा','श्रवण','धनिष्ठा','शतभिषा','पूर्वाभाद्रपद',
    'उत्तराभाद्रपद','रेवती'
  ];
  static const _yogas = [
    'विष्कम्भ','प्रीति','आयुष्मान','सौभाग्य','शोभन','अतिगण्ड','सुकर्मा',
    'धृति','शूल','गण्ड','वृद्धि','ध्रुव','व्याघात','हर्षण','वज्र','सिद्धि',
    'व्यतीपात','वरीयान','परिघ','शिव','सिद्ध','साध्य','शुभ','शुक्ल',
    'ब्रह्म','इन्द्र','वैधृति'
  ];
  static const _movingKaranas = [
    'बव','बालव','कौलव','तैतिल','गर','वणिज','विष्टि (भद्रा)'
  ];

  final AstronomyEngineService _astronomyEngine = AstronomyEngineService();

  Future<AstronomicalPanchang> calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final solar = SolarService.forDate(
      date: date,
      latitude: latitude,
      longitude: longitude,
    );

    // Panchang's sunrise state is calculated by the astronomical engine at the local sunrise.
    final x = _astronomyEngine.calculate(solar.sunrise);
    final sunLon = _norm(x.sunSiderealDeg);
    final moonLon = _norm(x.moonSiderealDeg);

    final diff = _norm(moonLon - sunLon);
    final tithiNumber = (diff / 12.0).floor() + 1;
    final tithiInPaksha = ((tithiNumber - 1) % 15) + 1;
    final paksha = tithiNumber <= 15 ? 'शुक्ल पक्ष' : 'कृष्ण पक्ष';
    final tithi = tithiInPaksha == 15
        ? (paksha == 'शुक्ल पक्ष' ? 'पूर्णिमा' : 'अमावस्या')
        : _tithiNames[tithiInPaksha - 1];
    final tithiProgress = (diff % 12.0) / 12.0;

    final nakSize = 360.0 / 27.0;
    final nakIndex = (moonLon / nakSize).floor().clamp(0, 26);
    final nakStart = nakIndex * nakSize;
    final nakProgress = _norm(moonLon - nakStart) / nakSize;

    final yogaValue = _norm(sunLon + moonLon);
    final yogaIndex = (yogaValue / nakSize).floor().clamp(0, 26);

    final karanaNumber = (diff / 6.0).floor() + 1;
    final karana = _karanaName(karanaNumber);

    final rashiIndex = (sunLon / 30.0).floor().clamp(0, 11);
    const rashis = [
      'मेष','वृषभ','मिथुन','कर्क','सिंह','कन्या',
      'तुला','वृश्चिक','धनु','मकर','कुंभ','मीन'
    ];

    return AstronomicalPanchang(
      localSunrise: solar.sunrise,
      localSunset: solar.sunset,
      nextLocalSunrise: solar.nextSunrise,
      tithi: tithi,
      tithiNumber: tithiNumber,
      paksha: paksha,
      tithiProgress: tithiProgress,
      nakshatra: _nakshatras[nakIndex],
      nakshatraNumber: nakIndex + 1,
      nakshatraProgress: nakProgress,
      yoga: _yogas[yogaIndex],
      yogaNumber: yogaIndex + 1,
      karana: karana,
      karanaNumber: karanaNumber,
      solarRashi: rashis[rashiIndex],
      solarLongitude: sunLon,
      lunarLongitude: moonLon,
      ayanamsha: x.ayanamsaDeg,
      ayanamshaName: 'लाहिरी',
      engine: 'सटीक खगोलीय गणना',
      precisionNote:
          'मुख्य पंचांग गणना सटीक खगोलीय engine से की गई है। '
          'तिथि, नक्षत्र, योग, करण और सूर्य राशि Sun/Moon sidereal longitudes '
          'से निकाले गए हैं। Sunrise/sunset local solar-time service से हैं। '
          'Swiss Ephemeris केवल अलग diagnostic/comparison screen में उपलब्ध है।',
    );
  }

  String _karanaName(int n) {
    if (n == 1) return 'किंस्तुघ्न';
    if (n >= 2 && n <= 57) return _movingKaranas[(n - 2) % 7];
    return const {
      58: 'शकुनि',
      59: 'चतुष्पद',
      60: 'नाग',
    }[n] ?? 'किंस्तुघ्न';
  }

  double _norm(double x) {
    final v = x % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}
