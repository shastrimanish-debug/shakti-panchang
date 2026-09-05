/// Shakti Panchang 8-point prediction synthesis contracts.
///
/// This layer is the integration boundary for KP, Lal Kitab, Prashna,
/// Tajik/Varshaphal, additional Dashas, advanced Milan and UMA.
///
/// Calculation engines should populate these structures from real chart data.
/// No generic prediction should be emitted when required signals are absent.

enum AstrologySystem { kp, lalKitab, prashna, tajik, dasha, milan, vedic }

class CalculatedSignal {
  const CalculatedSignal({
    required this.key,
    required this.value,
    required this.weight,
    this.system = AstrologySystem.vedic,
    this.explanation = '',
  });
  final String key;
  final String value;
  final double weight;
  final AstrologySystem system;
  final String explanation;
}

class PredictionContext {
  const PredictionContext({
    required this.signals,
    this.question = '',
    this.year = 0,
    this.personA = '',
    this.personB = '',
  });
  final List<CalculatedSignal> signals;
  final String question;
  final int year;
  final String personA;
  final String personB;
}

class SynthesizedPrediction {
  const SynthesizedPrediction({
    required this.title,
    required this.summary,
    required this.reasons,
    required this.confidence,
    required this.systems,
    this.timing = '',
  });
  final String title;
  final String summary;
  final List<String> reasons;
  final double confidence;
  final List<AstrologySystem> systems;
  final String timing;
}

class UmaPredictionSynthesizer {
  const UmaPredictionSynthesizer();

  List<SynthesizedPrediction> synthesize(PredictionContext context) {
    if (context.signals.isEmpty) return const [];

    final grouped = <String, List<CalculatedSignal>>{};
    for (final signal in context.signals) {
      grouped.putIfAbsent(signal.key, () => []).add(signal);
    }

    final output = <SynthesizedPrediction>[];
    for (final entry in grouped.entries) {
      final signals = entry.value;
      final total = signals.fold<double>(0, (a, b) => a + b.weight.abs());
      if (total == 0) continue;

      final confidence = (signals.fold<double>(
        0,
        (a, b) => a + b.weight.abs(),
      ) / (signals.length * 10)).clamp(0.0, 1.0).toDouble();

      final reasons = signals
          .where((s) => s.explanation.isNotEmpty)
          .map((s) => s.explanation)
          .toList();

      final systems = signals.map((s) => s.system).toSet().toList();

      output.add(SynthesizedPrediction(
        title: entry.key,
        summary: signals.map((s) => s.value).join(' • '),
        reasons: reasons,
        confidence: confidence,
        systems: systems,
        timing: _timing(signals),
      ));
    }
    return output;
  }

  String _timing(List<CalculatedSignal> signals) {
    for (final s in signals) {
      if (s.key.toLowerCase().contains('timing')) return s.value;
      if (s.key.toLowerCase().contains('dasha')) return s.value;
      if (s.key.toLowerCase().contains('transit')) return s.value;
    }
    return '';
  }
}

/// Normalized inputs for the advanced systems. Existing calculators should
/// populate these fields rather than using hard-coded predictions.
class AdvancedAstrologyInputs {
  const AdvancedAstrologyInputs({
    this.kpSignificators = const [],
    this.kpSubLord = '',
    this.lalKitabSignals = const [],
    this.prashnaSignals = const [],
    this.tajikSignals = const [],
    this.additionalDashaSignals = const [],
    this.milanSignals = const [],
  });

  final List<CalculatedSignal> kpSignificators;
  final String kpSubLord;
  final List<CalculatedSignal> lalKitabSignals;
  final List<CalculatedSignal> prashnaSignals;
  final List<CalculatedSignal> tajikSignals;
  final List<CalculatedSignal> additionalDashaSignals;
  final List<CalculatedSignal> milanSignals;

  List<CalculatedSignal> toSignals() => [
    ...kpSignificators,
    if (kpSubLord.isNotEmpty)
      CalculatedSignal(
        key: 'KP sub-lord',
        value: kpSubLord,
        weight: 8,
        system: AstrologySystem.kp,
        explanation: 'KP sub-lord supplied by the calculation layer.',
      ),
    ...lalKitabSignals,
    ...prashnaSignals,
    ...tajikSignals,
    ...additionalDashaSignals,
    ...milanSignals,
  ];
}
