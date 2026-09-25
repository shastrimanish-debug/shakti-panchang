class AstronomicalPanchang {
  final DateTime localSunrise;
  final DateTime localSunset;
  final DateTime nextLocalSunrise;
  final String tithi;
  final int tithiNumber;
  final String paksha;
  final double tithiProgress;
  final String nakshatra;
  final int nakshatraNumber;
  final double nakshatraProgress;
  final String yoga;
  final int yogaNumber;
  final String karana;
  final int karanaNumber;
  final String solarRashi;
  final double solarLongitude;
  final double lunarLongitude;
  final double ayanamsha;
  final String ayanamshaName;
  final String engine;
  final String precisionNote;

  const AstronomicalPanchang({
    required this.localSunrise,
    required this.localSunset,
    required this.nextLocalSunrise,
    required this.tithi,
    required this.tithiNumber,
    required this.paksha,
    required this.tithiProgress,
    required this.nakshatra,
    required this.nakshatraNumber,
    required this.nakshatraProgress,
    required this.yoga,
    required this.yogaNumber,
    required this.karana,
    required this.karanaNumber,
    required this.solarRashi,
    required this.solarLongitude,
    required this.lunarLongitude,
    required this.ayanamsha,
    required this.ayanamshaName,
    required this.engine,
    required this.precisionNote,
  });

  static const _rashis = [
    'मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या',
    'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन',
  ];

  static const _sauraMasa = [
    'वैशाख', 'ज्येष्ठ', 'आषाढ़', 'श्रावण', 'भाद्रपद', 'आश्विन',
    'कार्तिक', 'मार्गशीर्ष', 'पौष', 'माघ', 'फाल्गुन', 'चैत्र',
  ];

  String get lunarRashiName {
    final i = ((lunarLongitude % 360) / 30).floor() % 12;
    return _rashis[i];
  }

  int get nakshatraPada {
    const span = 360.0 / 27.0;
    final inNak = (lunarLongitude % 360) % span;
    return (inNak / (span / 4)).floor() + 1;
  }

  String get masa {
    final i = ((solarLongitude % 360) / 30).floor() % 12;
    return _sauraMasa[i];
  }

  String get samvat => 'विक्रम संवत्';
}
