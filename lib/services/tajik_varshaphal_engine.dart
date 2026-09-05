/// Tajik / Varshaphal annual-chart signal layer.
///
/// Receives calculated annual-chart indicators and normalizes them for the
/// prediction synthesis layer. The astronomical calculator remains the source
/// of truth for positions.
class TajikInput {
  const TajikInput({
    required this.year,
    required this.munthaHouse,
    required this.annualAscendant,
    this.munthaLord = '',
    this.annualLord = '',
    this.indicators = const [],
    this.timing = '',
  });
  final int year;
  final int munthaHouse;
  final String annualAscendant;
  final String munthaLord;
  final String annualLord;
  final List<String> indicators;
  final String timing;
}

class TajikSignal {
  const TajikSignal({
    required this.year,
    required this.munthaHouse,
    required this.annualAscendant,
    required this.munthaLord,
    required this.annualLord,
    required this.indicators,
    required this.timing,
  });
  final int year;
  final int munthaHouse;
  final String annualAscendant;
  final String munthaLord;
  final String annualLord;
  final List<String> indicators;
  final String timing;
}

class TajikVarshaphalEngine {
  const TajikVarshaphalEngine();

  TajikSignal calculate(TajikInput input) {
    return TajikSignal(
      year: input.year,
      munthaHouse: input.munthaHouse.clamp(1, 12).toInt(),
      annualAscendant: input.annualAscendant.trim(),
      munthaLord: input.munthaLord.trim(),
      annualLord: input.annualLord.trim(),
      indicators: input.indicators.where((e) => e.trim().isNotEmpty).toList(),
      timing: input.timing.trim(),
    );
  }
}
