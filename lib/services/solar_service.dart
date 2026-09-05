import 'dart:math' as math;
import '../models/panchang_models.dart';

/// NOAA-style solar calculation.
/// India-first build: results are returned in IST (UTC+05:30).
/// Accuracy is intended for Panchang time windows; a later production pass
/// can add a full timezone/ephemeris library for global coverage.
class SolarService {
  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  static SolarTimes forDate({
    required DateTime date,
    required double latitude,
    required double longitude,
  }) {
    final d0 = DateTime(date.year, date.month, date.day);
    final sunriseUtc = _sunEvent(d0, latitude, longitude, true);
    final sunsetUtc = _sunEvent(d0, latitude, longitude, false);

    final nextDate = d0.add(const Duration(days: 1));
    final nextSunriseUtc = _sunEvent(nextDate, latitude, longitude, true);

    return SolarTimes(
      sunrise: sunriseUtc.add(istOffset),
      sunset: sunsetUtc.add(istOffset),
      nextSunrise: nextSunriseUtc.add(istOffset),
    );
  }

  static DateTime _sunEvent(
      DateTime date, double latitude, double longitude, bool sunrise) {
    final n = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final lngHour = longitude / 15.0;
    final t = n + ((sunrise ? 6.0 : 18.0) - lngHour) / 24.0;

    final meanAnomaly = (0.9856 * t) - 3.289;
    final trueLong = (meanAnomaly +
            1.916 * math.sin(_rad(meanAnomaly)) +
            0.020 * math.sin(_rad(2 * meanAnomaly)) +
            282.634) %
        360.0;

    var ra = _deg(math.atan(0.91764 * math.tan(_rad(trueLong))));
    ra = (ra + 360) % 360;
    final lQuadrant = (trueLong / 90).floor() * 90.0;
    final raQuadrant = (ra / 90).floor() * 90.0;
    ra += lQuadrant - raQuadrant;
    ra /= 15.0;

    final sinDec = 0.39782 * math.sin(_rad(trueLong));
    final cosDec = math.cos(math.asin(sinDec));

    const zenith = 90.833;
    final cosH = (math.cos(_rad(zenith)) -
            sinDec * math.sin(_rad(latitude))) /
        (cosDec * math.cos(_rad(latitude)));

    if (cosH > 1 || cosH < -1) {
      // Fallback for polar edge cases; not normally relevant in India.
      return DateTime.utc(date.year, date.month, date.day, sunrise ? 0 : 12);
    }

    var h = sunrise
        ? 360 - _deg(math.acos(cosH))
        : _deg(math.acos(cosH));
    h /= 15.0;

    final localMeanTime = h + ra - (0.06571 * t) - 6.622;
    var utcHour = localMeanTime - lngHour;
    utcHour %= 24;
    if (utcHour < 0) utcHour += 24;

    final minutes = (utcHour * 60).round();
    return DateTime.utc(date.year, date.month, date.day)
        .add(Duration(minutes: minutes));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
  static double _deg(double rad) => rad * 180.0 / math.pi;
}
