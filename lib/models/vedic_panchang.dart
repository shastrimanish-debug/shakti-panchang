class VedicPanchang {
  final String paksha;
  final String masa;
  final String samvat;
  final String tithi;
  final double tithiProgress;
  final String nakshatra;
  final double nakshatraProgress;
  final String yoga;
  final String karana;
  final String weekday;
  final String ayanamsha;
  final String calculationNote;

  const VedicPanchang({
    required this.paksha,
    required this.masa,
    required this.samvat,
    required this.tithi,
    required this.tithiProgress,
    required this.nakshatra,
    required this.nakshatraProgress,
    required this.yoga,
    required this.karana,
    required this.weekday,
    required this.ayanamsha,
    required this.calculationNote,
  });
}
