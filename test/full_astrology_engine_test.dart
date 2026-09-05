import 'package:flutter_test/flutter_test.dart';

import '../lib/models/kundali_model.dart';
import '../lib/services/full_astrology_engine.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () {
    final birthDate = DateTime(1990, 1, 1);

    final data = KundaliData(
      name: 'Test',
      birthDate: birthDate,
      birthTime: '12:00',
      birthPlace: 'Vadodara',
      latitude: 22.3072,
      longitude: 73.1812,
      timezoneHours: 5.5,
      planets: [
        PlanetPosition(
          planet: 'चंद्र',
          rashi: 'मेष',
          degree: 0.0,
          house: 1,
        ),
      ],
      lagnaDegree: 0.0,
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

    final periods = const FullAstrologyEngine().yoginiDasha(data);

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

    expect(periods.first.planet, expectedCycle.first);

    for (var i = 0; i < periods.length; i++) {
      expect(
        periods[i].planet,
        expectedCycle[i % expectedCycle.length],
        reason: 'Invalid Yogini lord at index $i',
      );

      expect(
        periods[i].endDate.isAfter(periods[i].startDate),
        isTrue,
      );
    }

    for (var i = 0; i < 24; i++) {
      expect(
        periods[i + 8].planet,
        periods[i].planet,
      );
    }
  });
}import 'package:flutter_test/flutter_test.dart';

import '../lib/models/kundali_model.dart';
import '../lib/services/full_astrology_engine.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () {
    final birthDate = DateTime(1990, 1, 1);

    final data = KundaliData(
      name: 'Test',
      birthDate: birthDate,
      birthTime: '12:00',
      birthPlace: 'Vadodara',
      latitude: 22.3072,
      longitude: 73.1812,
      timezoneHours: 5.5,
      planets: [
        PlanetPosition(
          planet: 'चंद्र',
          rashi: 'मेष',
          degree: 0.0,
          house: 1,
        ),
      ],
      lagnaDegree: 0.0,
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

    final periods = const FullAstrologyEngine().yoginiDasha(data);

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

    expect(periods.first.planet, expectedCycle.first);

    for (var i = 0; i < periods.length; i++) {
      expect(
        periods[i].planet,
        expectedCycle[i % expectedCycle.length],
        reason: 'Invalid Yogini lord at index $i',
      );

      expect(
        periods[i].endDate.isAfter(periods[i].startDate),
        isTrue,
      );
    }

    for (var i = 0; i < 24; i++) {
      expect(
        periods[i + 8].planet,
        periods[i].planet,
      );
    }
  });
}import 'package:flutter_test/flutter_test.dart';

import '../lib/models/kundali_model.dart';
import '../lib/services/full_astrology_engine.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () {
    final birthDate = DateTime(1990, 1, 1);

    final data = KundaliData(
      name: 'Test',
      birthDate: birthDate,
      birthTime: '12:00',
      birthPlace: 'Vadodara',
      latitude: 22.3072,
      longitude: 73.1812,
      timezoneHours: 5.5,
      planets: [
        PlanetPosition(
          planet: 'चंद्र',
          rashi: 'मेष',
          degree: 0.0,
          house: 1,
        ),
      ],
      lagnaDegree: 0.0,
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

    final periods = const FullAstrologyEngine().yoginiDasha(data);

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

    expect(periods.first.planet, expectedCycle.first);

    for (var i = 0; i < periods.length; i++) {
      expect(
        periods[i].planet,
        expectedCycle[i % expectedCycle.length],
        reason: 'Invalid Yogini lord at index $i',
      );

      expect(
        periods[i].endDate.isAfter(periods[i].startDate),
        isTrue,
      );
    }

    for (var i = 0; i < 24; i++) {
      expect(
        periods[i + 8].planet,
        periods[i].planet,
      );
    }
  });
}
