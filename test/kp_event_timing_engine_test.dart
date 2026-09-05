import 'package:flutter_test/flutter_test.dart';
import '../lib/models/kundali_model.dart';
import '../lib/services/kp_deep_engine.dart';
import '../lib/services/kp_event_timing_engine.dart';

void main() {
  test('timing window rejects inverted date ranges', () async {
    final chart = KundaliData(
      name: 'Test',
      birthDate: DateTime(2000, 1, 1),
      birthTime: '12:00',
      birthPlace: 'Test',
      latitude: 0,
      longitude: 0,
      planets: const [],
      lagnaDegree: 0,
      lagnaRashi: 'मेष',
      moonRashi: 'मेष',
      sunRashi: 'मेष',
      nakshatra: 'अश्विनी',
      charan: '1',
      nadi: 'आदि',
      gana: 'देव',
      yoni: 'अश्व',
      varna: 'क्षत्रिय',
      mahadasha: 'केतु',
      antardasha: 'केतु',
      dashaPeriods: const [],
      antarPeriods: const [],
      pratyantarPeriods: const [],
    );
    const reading = KpDeepReading(
      cusps: [],
      significators: [],
      rulingPlanets: [],
    );

    await expectLater(
      const KpEventTimingEngine().findWindows(
        chart: chart,
        reading: reading,
        favourableHouses: const [2, 6, 10, 11],
        from: DateTime(2026, 1, 2),
        to: DateTime(2026, 1, 1),
      ),
      throwsArgumentError,
    );
  });
}
