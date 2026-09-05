import 'dart:math' as math;

class YatraResult {
  final String direction;
  final double bearing;
  final bool directionShool;
  final String message;

  const YatraResult({
    required this.direction,
    required this.bearing,
    required this.directionShool,
    required this.message,
  });
}

class YatraService {
  static const labels = [
    'उत्तर', 'उत्तर-पूर्व', 'पूर्व', 'दक्षिण-पूर्व',
    'दक्षिण', 'दक्षिण-पश्चिम', 'पश्चिम', 'उत्तर-पश्चिम'
  ];

  static YatraResult check({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
    required String shoolDirection,
  }) {
    final phi1 = _rad(fromLat);
    final phi2 = _rad(toLat);
    final dLon = _rad(toLon - fromLon);
    final y = math.sin(dLon) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(dLon);
    final bearing = (_deg(math.atan2(y, x)) + 360) % 360;
    final index = ((bearing + 22.5) / 45).floor() % 8;
    final direction = labels[index];
    final blocked = direction == shoolDirection ||
        (direction == 'उत्तर-पूर्व' && shoolDirection == 'पूर्व') ||
        (direction == 'उत्तर-पश्चिम' && shoolDirection == 'पश्चिम') ||
        (direction == 'दक्षिण-पूर्व' && shoolDirection == 'पूर्व') ||
        (direction == 'दक्षिण-पश्चिम' && shoolDirection == 'पश्चिम');

    return YatraResult(
      direction: direction,
      bearing: bearing,
      directionShool: blocked,
      message: blocked
          ? 'यात्रा की दिशा आज के दिशाशूल से प्रभावित है। पारंपरिक मान्यता के अनुसार यात्रा का समय/दिशा पुनः देखें।'
          : 'यात्रा की दिशा आज के दिशाशूल में सीधे वर्जित नहीं है।',
    );
  }

  static double _rad(double d) => d * math.pi / 180;
  static double _deg(double r) => r * 180 / math.pi;
}
