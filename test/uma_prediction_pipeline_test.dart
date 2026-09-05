import 'package:flutter_test/flutter_test.dart';
import 'package:shakti_panchang/services/uma_prediction_pipeline.dart';
import 'package:shakti_panchang/services/uma_prediction_scoring_engine.dart';

void main() {
  test('UMA scoring remains deterministic and explainable', () {
    const engine = UmaPredictionScoringEngine();
    final result = engine.score(
      category: 'Career',
      signals: [
        const UmaPredictionSignal(
          name: 'Gochar',
          category: 'Career',
          weight: 2,
          polarity: 1,
          reason: 'Supportive transit',
        ),
      ],
    );

    expect(result.score, 2);
    expect(result.level, 'positive');
    expect(result.reasons, contains('Supportive transit'));
  });

  test('pipeline merges signal categories without inventing missing data', () {
    const pipeline = UmaPredictionPipeline();
    const signal = UmaPredictionSignal(
      name: 'Yoga',
      category: 'Yoga/Dosha',
      weight: 1,
      polarity: 0,
      reason: 'Neutral',
    );

    final merged = pipeline.mergeSignals(yoga: [signal]);
    expect(merged['Yoga/Dosha'], hasLength(1));
    expect(merged['Yoga/Dosha']!.first.polarity, 0);
  });
}
