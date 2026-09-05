/// UMA prediction scoring layer.
///
/// Keeps scoring deterministic and explainable. The calculation provider can
/// supply normalized signals; the UI receives only the resulting score and
/// reasons.
class UmaPredictionSignal {
  const UmaPredictionSignal({
    required this.name,
    required this.category,
    required this.weight,
    required this.polarity,
    required this.reason,
  });

  final String name;
  final String category;
  final double weight;
  final int polarity;
  final String reason;

  double get contribution => weight * polarity;
}

class UmaPredictionScore {
  const UmaPredictionScore({
    required this.category,
    required this.score,
    required this.level,
    required this.reasons,
  });

  final String category;
  final double score;
  final String level;
  final List<String> reasons;
}

class UmaPredictionScoringEngine {
  const UmaPredictionScoringEngine();

  UmaPredictionScore score({
    required String category,
    List<UmaPredictionSignal> signals = const <UmaPredictionSignal>[],
  }) {
    final score = signals.fold<double>(
      0,
      (sum, signal) => sum + signal.contribution,
    );

    final level = score >= 6
        ? 'strong-positive'
        : score >= 2
            ? 'positive'
            : score <= -6
                ? 'strong-caution'
                : score <= -2
                    ? 'caution'
                    : 'mixed';

    return UmaPredictionScore(
      category: category,
      score: score,
      level: level,
      reasons: signals
          .where((signal) => signal.polarity != 0)
          .map((signal) => signal.reason)
          .toList(growable: false),
    );
  }

  Map<String, UmaPredictionScore> scoreAll(
    Map<String, List<UmaPredictionSignal>> signals,
  ) {
    return signals.map(
      (category, values) => MapEntry(
        category,
        score(category: category, signals: values),
      ),
    );
  }
}
