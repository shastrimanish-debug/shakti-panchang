import 'package:flutter_test/flutter_test.dart';
import '../lib/services/full_astrology_engine.dart';
import '../lib/services/kundali_calculator.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () async {
    final d = await KundaliCalculator.calculate(
      name: 'Test',
      birthDate: DateTime(1990, 1, 1),
      birthTime: '12:00',
      birthPlace: 'Vadodara',
      latitude: 22.3072,
      longitude: 73.1812,
    );

    final periods = const FullAstrologyEngine().yoginiDasha(d);

    // Four complete 8-lord cycles.
    expect(periods.length, 32);

    // Every generated period must have a valid forward time range.
    for (final period in periods) {
      expect(
        period.endDate.isAfter(period.startDate),
        isTrue,
        reason:
            'Yogini period ${period.planet} must end after it starts.',
      );
    }

    // Verify the canonical 8-lord sequence repeats after one complete cycle.
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

    // The first period can begin with any lord because the starting lord is
    // determined from the Moon's birth nakshatra. Therefore validate the
    // relative 8-lord cycle rather than assuming a fixed first lord.
    final firstIndex = expectedCycle.indexOf(periods.first.planet);

    expect(
      firstIndex,
      greaterThanOrEqualTo(0),
      reason: 'First Yogini lord must belong to the canonical 8-lord cycle.',
    );

    for (var i = 0; i < 8; i++) {
      final expectedLord =
          expectedCycle[(firstIndex + i) % expectedCycle.length];

      expect(
        periods[i].planet,
        expectedLord,
        reason: 'Invalid Yogini lord at cycle position $i.',
      );

      expect(
        periods[i + 8].planet,
        expectedLord,
        reason: 'Second Yogini cycle does not repeat correctly at position $i.',
      );

      expect(
        periods[i + 16].planet,
        expectedLord,
        reason: 'Third Yogini cycle does not repeat correctly at position $i.',
      );

      expect(
        periods[i + 24].planet,
        expectedLord,
        reason: 'Fourth Yogini cycle does not repeat correctly at position $i.',
      );
    }
  });
}
