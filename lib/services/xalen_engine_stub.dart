import 'dart:math' as math;
import 'meeus_engine.dart';

class AstronomyEngineResult {
  final double sunSiderealDeg, moonSiderealDeg, ayanamsaDeg;
  final int status;
  const AstronomyEngineResult({
    required this.sunSiderealDeg,
    required this.moonSiderealDeg,
    required this.ayanamsaDeg,
    required this.status,
  });
}

class AstronomyEnginePlanetResult {
  final double siderealDeg, tropicalDeg, latitudeDeg, speedDegDay;
  final bool retrograde;
  const AstronomyEnginePlanetResult({
    required this.siderealDeg,
    required this.tropicalDeg,
    required this.latitudeDeg,
    required this.speedDegDay,
    required this.retrograde,
  });
}

class AstronomyEngineHousesResult {
  final List<double> cusps;
  final double ascendantDeg, mcDeg;
  const AstronomyEngineHousesResult({
    required this.cusps,
    required this.ascendantDeg,
    required this.mcDeg,
  });
}

/// Web / desktop fallback: Meeus Sun–Moon–Rahu + mean planets. No FFI.
class AstronomyEngineService {
  AstronomyEngineResult calculate(DateTime local) {
    final ayan = MeeusEngine.lahiriAyanamsha(local);
    return AstronomyEngineResult(
      sunSiderealDeg: MeeusEngine.norm(MeeusEngine.sunTropical(local) - ayan),
      moonSiderealDeg: MeeusEngine.norm(MeeusEngine.moonTropical(local) - ayan),
      ayanamsaDeg: ayan,
      status: 0,
    );
  }

  AstronomyEnginePlanetResult calculatePlanet(
    DateTime local, {
    required int bodyId,
    double timezoneHours = 5.5,
  }) {
    final ayan = MeeusEngine.lahiriAyanamsha(local);
    final trop = _tropical(local, bodyId);
    final sid = MeeusEngine.norm(trop - ayan);
    return AstronomyEnginePlanetResult(
      siderealDeg: sid,
      tropicalDeg: trop,
      latitudeDeg: 0,
      speedDegDay: 0,
      retrograde: false,
    );
  }

  int calculateVargaSign(double siderealDegree, {required int division}) {
    final span = 30.0 / division;
    return ((MeeusEngine.norm(siderealDegree) / span).floor()) % 12;
  }

  AstronomyEngineHousesResult calculateHouses(
    DateTime local, {
    required double latitude,
    required double longitude,
    double timezoneHours = 5.5,
  }) {
    final jd = local.toUtc().millisecondsSinceEpoch / 86400000.0 + 2440587.5;
    final gst = MeeusEngine.norm(280.46061837 + 360.98564736629 * (jd - 2451545.0));
    final lst = MeeusEngine.norm(gst + longitude);
    final eps = 23.4392911 * math.pi / 180;
    final lat = latitude * math.pi / 180;
    final ramc = lst * math.pi / 180;
    final y = math.cos(ramc);
    final x = -(math.sin(ramc) * math.cos(eps) + math.tan(lat) * math.sin(eps));
    var tropAsc = math.atan2(y, x) * 180 / math.pi;
    tropAsc = MeeusEngine.norm(tropAsc);
    final ayan = MeeusEngine.lahiriAyanamsha(local);
    final sidAsc = MeeusEngine.norm(tropAsc - ayan);
    final cusps = List<double>.generate(12, (i) => MeeusEngine.norm(sidAsc + i * 30));
    return AstronomyEngineHousesResult(
      cusps: cusps,
      ascendantDeg: sidAsc,
      mcDeg: MeeusEngine.norm(lst - ayan),
    );
  }

  double _tropical(DateTime d, int bodyId) {
    final t = (d.toUtc().millisecondsSinceEpoch / 86400000.0 + 2440587.5 - 2451545.0) / 36525.0;
    switch (bodyId) {
      case 0:
        return MeeusEngine.sunTropical(d);
      case 1:
        return MeeusEngine.moonTropical(d);
      case 2: // Mars
        return MeeusEngine.norm(355.433 + 19140.2993 * t);
      case 3: // Mercury
        return MeeusEngine.norm(252.251 + 149472.6746 * t);
      case 4: // Jupiter
        return MeeusEngine.norm(34.352 + 3034.9057 * t);
      case 5: // Venus
        return MeeusEngine.norm(181.980 + 58517.8157 * t);
      case 6: // Saturn
        return MeeusEngine.norm(50.077 + 1222.1138 * t);
      case 8: // Rahu / mean node
        return MeeusEngine.meanNodeTropical(d);
      default:
        return MeeusEngine.sunTropical(d);
    }
  }
}
