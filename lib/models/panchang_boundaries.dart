enum PanchangBoundaryType { tithi, nakshatra, yoga, karana }

class PanchangBoundary {
  final PanchangBoundaryType type;
  final String currentName;
  final String nextName;
  final DateTime start;
  final DateTime end;
  final double progress;

  const PanchangBoundary({
    required this.type,
    required this.currentName,
    required this.nextName,
    required this.start,
    required this.end,
    required this.progress,
  });
}

class DailyPanchangBoundaries {
  final PanchangBoundary tithi;
  final PanchangBoundary nakshatra;
  final PanchangBoundary yoga;
  final PanchangBoundary karana;

  const DailyPanchangBoundaries({
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
  });
}
