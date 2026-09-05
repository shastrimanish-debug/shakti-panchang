/// Additional dasha timing signal layer.
///
/// The existing astronomical/dasha calculators should provide the actual
/// periods. This layer normalizes multiple systems into a common timeline.
class DashaPeriod {
  const DashaPeriod({
    required this.system,
    required this.level,
    required this.lord,
    required this.start,
    required this.end,
    this.signals = const [],
  });
  final String system;
  final int level;
  final String lord;
  final DateTime start;
  final DateTime end;
  final List<String> signals;
}

class AdditionalDashaEngine {
  const AdditionalDashaEngine();

  List<DashaPeriod> normalize(List<DashaPeriod> periods) {
    return periods
        .where((p) => p.end.isAfter(p.start) && p.lord.trim().isNotEmpty)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  List<DashaPeriod> activeAt(List<DashaPeriod> periods, DateTime when) {
    return normalize(periods)
        .where((p) => !when.isBefore(p.start) && when.isBefore(p.end))
        .toList();
  }
}
