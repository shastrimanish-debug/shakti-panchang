import 'package:flutter_test/flutter_test.dart';
import 'package:shakti_panchang/services/kp_astrology_engine.dart';
import 'package:shakti_panchang/services/lal_kitab_engine.dart';
import 'package:shakti_panchang/services/prashna_horary_engine.dart';
import 'package:shakti_panchang/services/tajik_varshaphal_engine.dart';
import 'package:shakti_panchang/services/additional_dasha_engine.dart';
import 'package:shakti_panchang/services/advanced_milan_engine.dart';
import 'package:shakti_panchang/services/uma_prediction_synthesis.dart';
import 'package:shakti_panchang/services/uma_final_engine.dart';
import 'package:shakti_panchang/services/personalized_upay_engine.dart';

void main() {
  test('KP normalizes significator houses', () {
    // const hatakar final kiya
    final result = const KpAstrologyEngine().calculate(const [
      KpInput(cusp: 10, starLord: 'Shani', subLord: 'Budh', significatorHouses: [10, 6, 14, 0]),
    ]);
    expect(result.single.significatorHouses, [10, 6]);
    expect(result.single.house, 10);
  });

  test('Lal Kitab produces a deterministic signal', () {
    // const hatakar final kiya
    final result = const LalKitabEngine().calculate(const [
      LalKitabInput(planet: 'Shani', house: 8, affliction: 'test', weight: 2),
    ]);
    expect(result.single.house, 8);
    expect(result.single.score, 4);
  });

  test('Prashna validates relevant houses and timing', () {
    // const hatakar final kiya
    final result = const PrashnaHoraryEngine().calculate(const PrashnaInput(
      question: 'Will the work succeed?',
      ascendantHouse: 1,
      questionLord: 'Guru',
      relevantHouses: [1, 10, 13],
      strength: 2,
      timing: '3 months',
    ));
    expect(result.relevantHouses, [1, 10]);
    expect(result.timing, '3 months');
    expect(result.score, 4);
  });

  test('Tajik normalizes annual chart fields', () {
    final result = const TajikVarshaphalEngine().calculate(const TajikInput(
      year: 2026,
      munthaHouse: 5,
      annualAscendant: 'Mesha',
      indicators: ['Muntha'],
    ));
    expect(result.year, 2026);
    expect(result.munthaHouse, 5);
  });

  test('Additional Dasha finds the active period', () {
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2027, 1, 1);
    final periods = const AdditionalDashaEngine().normalize([
      DashaPeriod(system: 'Vimshottari', level: 1, lord: 'Guru', start: start, end: end),
    ]);
    expect(const AdditionalDashaEngine().activeAt(periods, DateTime(2026, 8, 1)), hasLength(1));
  });

  test('Advanced Milan combines multiple compatibility signals', () {
    final result = const AdvancedKundaliMilanEngine().calculate(const [
      MilanSignal(name: 'Guna', score: 20, maxScore: 36),
      MilanSignal(name: 'Bhava', score: 8, maxScore: 10),
    ]);
    expect(result.overallScore, closeTo(60.869, 0.01));
  });

  test('UMA synthesis refuses to fabricate when signals are missing', () {
    expect(const UmaPredictionSynthesizer().synthesize(const PredictionContext(signals: [])), isEmpty);
  });

  test('UMA final engine maps calculated predictions to personalized upays', () {
    // const hatakar final kiya
    final reading = const UmaFinalEngine().build(
      predictionContext: const PredictionContext(signals: [
        CalculatedSignal(
          key: 'Career', value: 'Supportive', weight: 8,
          system: AstrologySystem.dasha,
          explanation: 'Dasha signal is supportive.',
        ),
      ]),
      upayContext: const UpayContext(affectedGraha: ['Shani'], predictionCategory: 'Career'),
    );
    expect(reading.predictions, hasLength(1));
    expect(reading.upays['Career'], isNotEmpty);
  });
}
