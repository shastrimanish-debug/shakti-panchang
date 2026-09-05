import 'package:flutter_test/flutter_test.dart';
import '../lib/services/full_astrology_engine.dart';
import '../lib/services/kundali_calculator.dart';

void main() {
  test('Yogini dasha has deterministic 8-lord cycle', () async {
    final d = await KundaliCalculator.calculate(name:'Test',birthDate:DateTime(1990,1,1),birthTime:'12:00',birthPlace:'Vadodara',latitude:22.3072,longitude:73.1812);
    final periods = const FullAstrologyEngine().yoginiDasha(d);
    expect(periods.length, 32);
    expect(periods.first.endDate.isAfter(periods.first.startDate), isTrue);
    expect(periods[8].planet, periods.first.planet);
  });
}
