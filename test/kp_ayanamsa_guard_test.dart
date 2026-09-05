import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_ayanamsa.dart';
import '../lib/services/kp_calculation_guard.dart';

void main() {
  test('KP configuration is explicitly KP/Newcomb', () {
    const c = KpAyanamsaConfig();
    expect(c.id, 'KP_NEWCOMB');
  });

  test('KP reference settings reject Lahiri', () {
    const g = KpCalculationGuard();
    expect(
      () => g.assertReferenceSettings(
        ayanamsa: 'Lahiri',
        houseSystem: 'Placidus',
      ),
      throwsStateError,
    );
  });

  test('KP reference settings require Placidus', () {
    const g = KpCalculationGuard();
    expect(
      () => g.assertReferenceSettings(
        ayanamsa: 'KP/Newcomb',
        houseSystem: 'Whole Sign',
      ),
      throwsStateError,
    );
  });
}
