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
}
