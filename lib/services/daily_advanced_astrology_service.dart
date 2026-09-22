import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';

/// Advanced daily timing helpers used by the personalized Daily Rashifal.
///
/// Sookshma and Prana are derived by recursively splitting the active
/// Vimshottari Pratyantar interval using the classical 120-year proportions.
/// The Ashtakavarga layer uses the natal Bhinna Ashtakavarga points of each
/// transit planet and the natal Sarva Ashtakavarga total for the transit sign.
class DailyAdvancedAstrologyService {
  static const order = <String>[
    'केतु', 'शुक्र', 'सूर्य', 'चंद्र', 'मंगल', 'राहु', 'गुरु', 'शनि', 'बुध'
  ];

  static const years = <String, double>{
    'केतु': 7, 'शुक्र': 20, 'सूर्य': 6, 'चंद्र': 10, 'मंगल': 7,
    'राहु': 18, 'गुरु': 16, 'शनि': 19, 'बुध': 17,
  };

  static String? activeSukshma(KundaliData natal, DateTime date) {
    final p = _activePratyantar(natal.pratyantarPeriods, date);
    if (p == null) return null;
    return _activeNested(p.startDate, p.endDate, p.pratyantar, date)?.lord;
  }

  static String? activePrana(KundaliData natal, DateTime date) {
    final p = _activePratyantar(natal.pratyantarPeriods, date);
    if (p == null) return null;
    final sk = _activeNested(p.startDate, p.endDate, p.pratyantar, date);
    if (sk == null) return null;
    return _activeNested(sk.start, sk.end, sk.lord, date)?.lord;
  }

  static ({String? sukshma, String? prana}) depths(KundaliData natal, DateTime date) => (
    sukshma: activeSukshma(natal, date),
    prana: activePrana(natal, date),
  );

  static DailyAshtakavarga ashtakavarga(KundaliData natal, Map<String, double> transitDegrees) {
    final report = AdvancedKundaliService.ashtakavarga(natal);
    final points = <String, int>{};
    for (final entry in transitDegrees.entries) {
      final sign = ((entry.value % 360 + 360) % 360 / 30).floor() % 12;
      final row = report.bhinna[entry.key];
      if (row != null) points[entry.key] = row[sign];
    }
    final sarva = <String, int>{};
    for (final entry in transitDegrees.entries) {
      final sign = ((entry.value % 360 + 360) % 360 / 30).floor() % 12;
      sarva[entry.key] = report.sarva[sign];
    }
    final ranked = points.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final strongest = ranked.isEmpty ? null : ranked.first;
    final weakest = ranked.isEmpty ? null : ranked.last;
    return DailyAshtakavarga(
      planetPoints: points,
      sarvaPoints: sarva,
      strongestPlanet: strongest?.key,
      strongestPoints: strongest?.value,
      weakestPlanet: weakest?.key,
      weakestPoints: weakest?.value,
    );
  }

  static DashaPratyantar? _activePratyantar(List<DashaPratyantar> xs, DateTime date) {
    for (final x in xs) {
      if (!date.isBefore(x.startDate) && date.isBefore(x.endDate)) return x;
    }
    return null;
  }

  static _Nested? _activeNested(DateTime start, DateTime end, String seedLord, DateTime date) {
    if (!end.isAfter(start)) return null;
    final seedIndex = order.indexOf(seedLord);
    if (seedIndex < 0) return null;
    var cursor = start;
    final totalMs = end.difference(start).inMilliseconds;
    for (var i = 0; i < 9; i++) {
      final lord = order[(seedIndex + i) % 9];
      final portion = totalMs * years[lord]! / 120.0;
      final next = i == 8 ? end : cursor.add(Duration(milliseconds: portion.round()));
      if (!date.isBefore(cursor) && date.isBefore(next)) return _Nested(lord, cursor, next);
      cursor = next;
    }
    return null;
  }
}

class _Nested {
  final String lord;
  final DateTime start;
  final DateTime end;
  const _Nested(this.lord, this.start, this.end);
}

class DailyAshtakavarga {
  final Map<String, int> planetPoints;
  final Map<String, int> sarvaPoints;
  final String? strongestPlanet;
  final int? strongestPoints;
  final String? weakestPlanet;
  final int? weakestPoints;

  const DailyAshtakavarga({
    required this.planetPoints,
    required this.sarvaPoints,
    required this.strongestPlanet,
    required this.strongestPoints,
    required this.weakestPlanet,
    required this.weakestPoints,
  });

  String get summary {
    if (planetPoints.isEmpty) return 'अष्टकवर्ग daily transit data उपलब्ध नहीं है।';
    final p = planetPoints.entries.map((e) => '${e.key}: ${e.value}').join(' • ');
    return 'BAV transit points — $p';
  }
}
