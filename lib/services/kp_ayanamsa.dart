/// Central KP ayanamsa convention.
///
/// KP/Newcomb must be selected explicitly for KP calculations. The actual
/// astronomical longitude should be supplied by the ephemeris layer; this
/// class does not invent a fixed offset.
enum KpAyanamsa { kpNewcomb }

class KpAyanamsaConfig {
  const KpAyanamsaConfig({
    this.mode = KpAyanamsa.kpNewcomb,
  });

  final KpAyanamsa mode;

  String get id => 'KP_NEWCOMB';
  String get displayName => 'KP / Krishnamurti–Newcomb';
}
