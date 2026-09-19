import 'dart:math' as math;

/// Free second engine (Meeus) — Sun, Moon, mean Rahu. No Swiss license.
class MeeusEngine {
  static double norm(double x) {
    var v = x % 360.0;
    if (v < 0) v += 360.0;
    return v;
  }

  static double _rev(double x) => norm(x);

  static double _rad(double d) => d * math.pi / 180.0;
  static double _jd(DateTime d) => d.toUtc().millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  static double _t(DateTime d) => (_jd(d) - 2451545.0) / 36525.0;

  static double sunTropical(DateTime d) {
    final t = _t(d);
    final l0 = _rev(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
    final m = _rev(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(_rad(m)) +
        (0.019993 - 0.000101 * t) * math.sin(_rad(2 * m)) +
        0.000289 * math.sin(_rad(3 * m));
    return _rev(l0 + c);
  }

  static double moonTropical(DateTime d) {
    final t = _t(d);
    final lp = 218.3164477 + 481267.88123421 * t - 0.0015786 * t * t;
    final D = 297.8501921 + 445267.1114034 * t - 0.0018819 * t * t;
    final m = 357.5291092 + 35999.0502909 * t;
    final mp = 134.9633964 + 477198.8675055 * t + 0.0087414 * t * t;
    final f = 93.272095 + 483202.0175233 * t - 0.0036539 * t * t;
    final lon = lp +
        6.288774 * math.sin(_rad(mp)) +
        1.274027 * math.sin(_rad(2 * D - mp)) +
        0.658314 * math.sin(_rad(2 * D)) +
        0.213618 * math.sin(_rad(2 * mp)) -
        0.185116 * math.sin(_rad(m)) -
        0.114332 * math.sin(_rad(2 * f));
    return _rev(lon);
  }

  static double meanNodeTropical(DateTime d) {
    final t = _t(d);
    return _rev(125.0445479 - 1934.1362891 * t + 0.0020754 * t * t);
  }

  static double lahiriAyanamsha(DateTime d) {
    final t = _t(d);
    return 23.856 + 1.3969 * t + 0.0003 * t * t;
  }

  static double ramanAyanamsha(DateTime d) => lahiriAyanamsha(d) - 0.855;
  static double kpAyanamsha(DateTime d) => lahiriAyanamsha(d) + 0.214;

  static double ayanamsha(DateTime d, String id) {
    switch (id) {
      case 'raman':
        return ramanAyanamsha(d);
      case 'kp':
        return kpAyanamsha(d);
      default:
        return lahiriAyanamsha(d);
    }
  }
}

class DualEngineCheck {
  final double xalenSun;
  final double meeusSun;
  final double xalenMoon;
  final double meeusMoon;
  final double sunDeltaArcsec;
  final double moonDeltaArcsec;
  DualEngineCheck({
    required this.xalenSun,
    required this.meeusSun,
    required this.xalenMoon,
    required this.meeusMoon,
    required this.sunDeltaArcsec,
    required this.moonDeltaArcsec,
  });
}
