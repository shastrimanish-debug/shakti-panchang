import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';

final class AstronomyEngineResultNative extends ffi.Struct {
  @ffi.Double() external double sunSiderealDeg;
  @ffi.Double() external double moonSiderealDeg;
  @ffi.Double() external double ayanamsaDeg;
  @ffi.Int32() external int status;
}

final class AstronomyEnginePlanetNative extends ffi.Struct {
  @ffi.Double() external double siderealDeg;
  @ffi.Double() external double tropicalDeg;
  @ffi.Double() external double latitudeDeg;
  @ffi.Double() external double speedDegDay;
  @ffi.Int32() external int retrograde;
  @ffi.Int32() external int status;
}

final class AstronomyEngineHousesNative extends ffi.Struct {
  @ffi.Array(12) external ffi.Array<ffi.Double> cusps;
  @ffi.Double() external double ascendantDeg;
  @ffi.Double() external double mcDeg;
  @ffi.Int32() external int status;
}

typedef _CalcNative = ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Double, ffi.Pointer<AstronomyEngineResultNative>);
typedef _CalcDart = int Function(int, int, int, int, int, int, double, ffi.Pointer<AstronomyEngineResultNative>);

typedef _PlanetNative = ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Double, ffi.Int32, ffi.Pointer<AstronomyEnginePlanetNative>);
typedef _PlanetDart = int Function(int, int, int, int, int, int, double, int, ffi.Pointer<AstronomyEnginePlanetNative>);

typedef _HouseNative = ffi.Int32 Function(ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Int32, ffi.Double, ffi.Double, ffi.Double, ffi.Pointer<AstronomyEngineHousesNative>);
typedef _HouseDart = int Function(int, int, int, int, int, int, double, double, double, ffi.Pointer<AstronomyEngineHousesNative>);

typedef _VargaNative = ffi.Int32 Function(ffi.Double, ffi.Int32, ffi.Pointer<ffi.Int32>);
typedef _VargaDart = int Function(double, int, ffi.Pointer<ffi.Int32>);

class AstronomyEngineResult {
  final double sunSiderealDeg, moonSiderealDeg, ayanamsaDeg;
  final int status;
  const AstronomyEngineResult({required this.sunSiderealDeg, required this.moonSiderealDeg, required this.ayanamsaDeg, required this.status});
}

class AstronomyEnginePlanetResult {
  final double siderealDeg, tropicalDeg, latitudeDeg, speedDegDay;
  final bool retrograde;
  const AstronomyEnginePlanetResult({required this.siderealDeg, required this.tropicalDeg, required this.latitudeDeg, required this.speedDegDay, required this.retrograde});
}

class AstronomyEngineHousesResult {
  final List<double> cusps;
  final double ascendantDeg, mcDeg;
  const AstronomyEngineHousesResult({required this.cusps, required this.ascendantDeg, required this.mcDeg});
}

class AstronomyEngineService {
  ffi.DynamicLibrary? _lib;
  _CalcDart? _calc;
  _PlanetDart? _planet;
  _HouseDart? _houses;
  _VargaDart? _varga;

  void _ensureLoaded() {
    if (_calc != null) return;
    if (!Platform.isAndroid) throw UnsupportedError('Native astronomical engine currently targets Android.');
    _lib = ffi.DynamicLibrary.open('libshakti_xalen.so');
    _calc = _lib!.lookupFunction<_CalcNative, _CalcDart>('shakti_xalen_calculate');
    _planet = _lib!.lookupFunction<_PlanetNative, _PlanetDart>('shakti_xalen_planet');
    _houses = _lib!.lookupFunction<_HouseNative, _HouseDart>('shakti_xalen_houses');
    _varga = _lib!.lookupFunction<_VargaNative, _VargaDart>('shakti_xalen_varga_sign');
  }

  AstronomyEngineResult calculate(DateTime local) {
    _ensureLoaded();
    final o = calloc<AstronomyEngineResultNative>();
    try {
      final s = _calc!(local.year, local.month, local.day, local.hour, local.minute, local.second, 5.5, o);
      if (s != 0) throw StateError('Astronomical calculation failed: $s');
      return AstronomyEngineResult(sunSiderealDeg: o.ref.sunSiderealDeg, moonSiderealDeg: o.ref.moonSiderealDeg, ayanamsaDeg: o.ref.ayanamsaDeg, status: o.ref.status);
    } finally {
      calloc.free(o);
    }
  }

  AstronomyEnginePlanetResult calculatePlanet(DateTime local, {required int bodyId, double timezoneHours = 5.5}) {
    _ensureLoaded();
    final o = calloc<AstronomyEnginePlanetNative>();
    try {
      final s = _planet!(local.year, local.month, local.day, local.hour, local.minute, local.second, timezoneHours, bodyId, o);
      if (s != 0) throw StateError('Planet calculation failed: $s');
      return AstronomyEnginePlanetResult(siderealDeg: o.ref.siderealDeg, tropicalDeg: o.ref.tropicalDeg, latitudeDeg: o.ref.latitudeDeg, speedDegDay: o.ref.speedDegDay, retrograde: o.ref.retrograde != 0);
    } finally {
      calloc.free(o);
    }
  }

  int calculateVargaSign(double siderealDegree, {required int division}) {
    _ensureLoaded();
    if (division < 1 || division > 60) {
      throw ArgumentError.value(division, 'division', 'Supported Varga divisions are 1..60.');
    }
    final o = calloc<ffi.Int32>();
    try {
      final s = _varga!(siderealDegree, division, o);
      if (s != 0) throw StateError('Varga calculation failed: $s');
      return o.value;
    } finally {
      calloc.free(o);
    }
  }

  AstronomyEngineHousesResult calculateHouses(DateTime local, {required double latitude, required double longitude, double timezoneHours = 5.5}) {
    _ensureLoaded();
    final o = calloc<AstronomyEngineHousesNative>();
    try {
      final s = _houses!(local.year, local.month, local.day, local.hour, local.minute, local.second, timezoneHours, latitude, longitude, o);
      if (s != 0) throw StateError('House calculation failed: $s');
      final c = List<double>.generate(12, (i) => o.ref.cusps[i]);
      return AstronomyEngineHousesResult(cusps: c, ascendantDeg: o.ref.ascendantDeg, mcDeg: o.ref.mcDeg);
    } finally {
      calloc.free(o);
    }
  }
}
