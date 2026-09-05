typedef PhaseFunction = double Function(DateTime time);
typedef AsyncPhaseFunction = Future<double> Function(DateTime time);

class BoundarySolver {
  static DateTime findCrossing({
    required DateTime left,
    required DateTime right,
    required double target,
    required PhaseFunction phase,
    int iterations = 45,
  }) {
    var a = left;
    var b = right;

    double norm(double x) {
      var v = x % 360.0;
      if (v < 0) v += 360.0;
      return v;
    }

    double forwardDelta(double from, double to) {
      final d = (norm(to) - norm(from)) % 360.0;
      return d < 0 ? d + 360.0 : d;
    }

    final targetN = norm(target);
    for (var i = 0; i < iterations; i++) {
      final mid = a.add(Duration(
        milliseconds: b.difference(a).inMilliseconds ~/ 2,
      ));
      final da = forwardDelta(phase(a), targetN);
      final dm = forwardDelta(phase(mid), targetN);
      if (dm < da) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return a.add(Duration(
      milliseconds: b.difference(a).inMilliseconds ~/ 2,
    ));
  }
  static Future<DateTime> findCrossingAsync({
    required DateTime left,
    required DateTime right,
    required double target,
    required AsyncPhaseFunction phase,
    int iterations = 32,
  }) async {
    var a = left;
    var b = right;

    double norm(double x) {
      var v = x % 360.0;
      if (v < 0) v += 360.0;
      return v;
    }

    double forwardDelta(double from, double to) {
      final d = (norm(to) - norm(from)) % 360.0;
      return d < 0 ? d + 360.0 : d;
    }

    final targetN = norm(target);
    for (var i = 0; i < iterations; i++) {
      final mid = a.add(Duration(
        milliseconds: b.difference(a).inMilliseconds ~/ 2,
      ));
      final da = forwardDelta(await phase(a), targetN);
      final dm = forwardDelta(await phase(mid), targetN);
      if (dm < da) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return a.add(Duration(
      milliseconds: b.difference(a).inMilliseconds ~/ 2,
    ));
  }

}
