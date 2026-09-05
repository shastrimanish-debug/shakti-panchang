import 'uma_prediction_synthesis.dart';
import 'personalized_upay_engine.dart';

/// Final orchestration layer for UMA.
///
/// The app should construct this object from real chart-calculation outputs.
/// No prediction is generated when there are no calculated signals.
class UmaFinalReading {
  const UmaFinalReading({
    required this.predictions,
    required this.upays,
  });
  final List<SynthesizedPrediction> predictions;
  final Map<String, List<PersonalizedUpay>> upays;
}

class UmaFinalEngine {
  const UmaFinalEngine({
    this.synthesizer = const UmaPredictionSynthesizer(),
    this.upayEngine = const PersonalizedUpayEngine(),
  });

  final UmaPredictionSynthesizer synthesizer;
  final PersonalizedUpayEngine upayEngine;

  UmaFinalReading build({
    required PredictionContext predictionContext,
    required UpayContext upayContext,
    List<PersonalizedUpay> researchedUpays = const [],
  }) {
    final predictions = synthesizer.synthesize(predictionContext);
    final remedies = upayEngine.recommend(
      upayContext,
      researched: researchedUpays,
    );

    final mapped = <String, List<PersonalizedUpay>>{};
    for (final prediction in predictions) {
      mapped[prediction.title] = remedies;
    }

    return UmaFinalReading(predictions: predictions, upays: mapped);
  }
}
