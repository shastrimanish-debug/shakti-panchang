import 'kp_ayanamsa.dart';

class KpCalculationGuard {
  const KpCalculationGuard();

  void requireKpAyanamsa(KpAyanamsaConfig config) {
    if (config.mode != KpAyanamsa.kpNewcomb) {
      throw StateError('KP calculations require KP/Newcomb ayanamsa.');
    }
  }

  void assertReferenceSettings({
    required String ayanamsa,
    required String houseSystem,
  }) {
    if (ayanamsa.toUpperCase() != 'KP/NEWCOMB' &&
        ayanamsa.toUpperCase() != 'KP_NEWCOMB') {
      throw StateError('Reference mismatch: KP requires KP/Newcomb ayanamsa.');
    }
    if (houseSystem.toLowerCase() != 'placidus') {
      throw StateError('Reference mismatch: KP validation requires Placidus.');
    }
  }
}
