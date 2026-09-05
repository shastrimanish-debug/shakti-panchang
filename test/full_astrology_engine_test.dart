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

    expect(periods.length, 32);

    const lords = <String>[
      'मंगला',
      'पिंगला',
      'धन्या',
      'भ्रामरी',
      'भद्रा',
      'उल्का',
      'सिद्धा',
      'संकटा',
    ];

    // The first lord is determined from the Moon's birth nakshatra.
    // From that point onward, the Yogini lords must advance in the
    // canonical 8-lord order and wrap around deterministically.
    final firstIndex = lords.indexOf(periods.first.planet);

    expect(
      firstIndex,
      greaterThanOrEqualTo(0),
      reason: 'Unexpected first Yogini lord: ${periods.first.planet}',
    );

    for (var i = 0; i < periods.length; i++) {
      final expectedLord = lords[(firstIndex + i) % lords.length];

      expect(
        periods[i].planet,
        expectedLord,
        reason:
            'Unexpected Yogini lord at period $i: '
            'expected $expectedLord, got ${periods[i].planet}',
      );

      expect(
        periods[i].endDate.isAfter(periods[i].startDate),
        isTrue,
        reason:
            'Invalid date range for Yogini period ${periods[i].planet} '
            'at index $i.',
      );
    }

    // Every complete 8-lord cycle must repeat exactly.
    for (var i = 0; i < 24; i++) {
      expect(
        periods[i + 8].planet,
        periods[i].planet,
        reason:
            'Yogini cycle did not repeat at index $i / ${i + 8}.',
      );
    }
  });
}
