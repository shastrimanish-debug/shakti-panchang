import 'uma_prediction_scoring_engine.dart';
import 'uma_prediction_explanation.dart';
import 'uma_signal_adapter.dart';

/// End-to-end, provider-neutral prediction pipeline.
///
/// Existing calculation services can pass their already-calculated signals
/// here. The pipeline does not invent missing astrology data.
class UmaPredictionPipeline {
  const UmaPredictionPipeline();

  Map<String, UmaPredictionExplanation> build({
    required Map<String, List<UmaPredictionSignal>> signalsByCategory,
    Map<String, String> timingByCategory = const <String, String>{},
  }) {
    const scoring = UmaPredictionScoringEngine();
    const composer = UmaPredictionComposer();

    final scores = scoring.scoreAll(signalsByCategory);

    return scores.map((category, score) {
      return MapEntry(
        category,
        composer.compose(
          category: category,
          score: score,
          timing: timingByCategory[category] ?? 'Current cycle',
        ),
      );
    });
  }

  Map<String, List<UmaPredictionSignal>> mergeSignals({
    List<UmaPredictionSignal> gochar = const <UmaPredictionSignal>[],
    List<UmaPredictionSignal> yoga = const <UmaPredictionSignal>[],
    List<UmaPredictionSignal> nakshatra = const <UmaPredictionSignal>[],
    List<UmaPredictionSignal> rashi = const <UmaPredictionSignal>[],
    List<UmaPredictionSignal> dasha = const <UmaPredictionSignal>[],
  }) {
    final merged = <String, List<UmaPredictionSignal>>{};

    void add(List<UmaPredictionSignal> values) {
      for (final signal in values) {
        merged.putIfAbsent(signal.category, () => <UmaPredictionSignal>[])
            .add(signal);
      }
    }

    add(gochar);
    add(yoga);
    add(nakshatra);
    add(rashi);
    add(dasha);

    return merged;
  }
}

/// Factory helpers kept separate so the UI never needs to know calculation
/// provider implementation details.
class UmaSignalPipelineFactory {
  const UmaSignalPipelineFactory();

  List<UmaPredictionSignal> transitSignals(
    List<Map<String, dynamic>> values,
  ) {
    return const UmaSignalAdapter().fromTransit(
      category: 'Gochar',
      transits: values,
    );
  }

  List<UmaPredictionSignal> yogaSignals(
    List<Map<String, dynamic>> values,
  ) {
    return const UmaSignalAdapter().fromYoga(
      category: 'Yoga/Dosha',
      yogas: values,
    );
  }
}
