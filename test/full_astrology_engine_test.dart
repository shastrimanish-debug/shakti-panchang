import 'package:flutter_test/flutter_test.dart';

import '../lib/models/kundali_model.dart';
import '../lib/services/full_astrology_engine.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () {
    // IMPORTANT:
    // Do not call KundaliCalculator.calculate() here.
    //
    // That method loads the native XALEN/Rust astronomical engine, which
    // intentionally targets Android. `flutter test` runs on the GitHub
    // Linux runner, so this unit test must remain independent of native FFI.
    //
    // The Yogini Dasha engine itself only needs the birth date and Moon
    // longitude. We therefore provide a deterministic synthetic KundaliData
    // containing a fixed Moon position.

    final birthDate = DateTime(1990, 1, 1);

    final data = KundaliData(
      name: 'Test',
      birthDate: birthDate,
      birthTime: '12:00',
      birthPlace: 'Vadodara',
      latitude: 22.3072,
      longitude: 73.1812,
      timezoneHours: 5.5,

      // Moon at 15 degrees sidereal longitude.
      //
      // This lies inside the first nakshatra and therefore gives a
      // deterministic Yogini starting lord.
      planets: [
        PlanetPosition(
          planet: 'चंद्र',
          rashi: 'मेष',
          degree: 15.0,
          house: 1,
        ),
      ],

      lagnaDegree: 0.0,
      lagnaRashi: 'मेष',
      moonRashi: 'मेष',
      sunRashi: 'मेष',
      nakshatra: 'अश्विनी',
      charan: '4',
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

    final periods = const FullAstrologyEngine().yoginiDasha(data);

    // Four complete 8-lord cycles.
    expect(periods.length, 32);

    const expectedCycle = <String>[
      'मंगला',
      'पिंगला',
      'धन्या',
      'भ्रामरी',
      'भद्रा',
      'उल्का',
      'सिद्धा',
      'संकटा',
    ];

    // With Moon at 15 degrees, the first Yogini lord is determined
    // deterministically by the first nakshatra.
    expect(periods.first.planet, expectedCycle.first);

    // Verify all four complete cycles.
    for (var i = 0; i < periods.length; i++) {
      final expectedLord = expectedCycle[i % expectedCycle.length];

      expect(
        periods[i].planet,
        expectedLord,
        reason:
            'Invalid Yogini lord at index $i: '
            'expected $expectedLord, got ${periods[i].planet}',
      );

      expect(
        periods[i].endDate.isAfter(periods[i].startDate),
        isTrue,
        reason:
            'Invalid date range for ${periods[i].planet} '
            'at index $i.',
      );
    }

    // Explicitly verify the cycle repeats after 8 periods.
    for (var i = 0; i < 24; i++) {
      expect(
        periods[i + 8].planet,
        periods[i].planet,
        reason:
            'Yogini 8-lord cycle did not repeat at '
            '$i -> ${i + 8}.',
      );
    }
  });
}
