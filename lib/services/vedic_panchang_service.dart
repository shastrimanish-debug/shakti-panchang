import '../models/vedic_panchang.dart';
import 'astronomical_panchang_service.dart';

/// Compatibility adapter for older screens.
/// The authoritative values come from AstronomicalPanchangService (astronomical engine).
class VedicPanchangService {
  final AstronomicalPanchangService _astro = AstronomicalPanchangService();

  Future<VedicPanchang> calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) async {
    final p = await _astro.calculate(
      date: date,
      latitude: latitude,
      longitude: longitude,
    );

    return VedicPanchang(
      paksha: p.paksha,
      masa: 'स्थान-आधारित मास',
      samvat: 'विक्रम संवत् ${date.year + 57}',
      tithi: p.tithi,
      tithiProgress: p.tithiProgress,
      nakshatra: p.nakshatra,
      nakshatraProgress: p.nakshatraProgress,
      yoga: p.yoga,
      karana: p.karana,
      weekday: _weekday(date.weekday),
      ayanamsha: p.ayanamshaName,
      calculationNote: p.precisionNote,
    );
  }

  String _weekday(int w) => const {
    1: 'सोमवार', 2: 'मंगलवार', 3: 'बुधवार', 4: 'गुरुवार',
    5: 'शुक्रवार', 6: 'शनिवार', 7: 'रविवार',
  }[w] ?? '';
}
