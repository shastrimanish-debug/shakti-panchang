import 'uma_prediction_scoring_engine.dart';

/// Converts common calculated chart values into scoring signals.
///
/// The adapter is intentionally conservative: it only scores values explicitly
/// supplied by the existing calculation layer. Missing data never becomes a
/// fabricated positive/negative prediction.
class UmaSignalAdapter {
  const UmaSignalAdapter();

  UmaPredictionSignal numeric({
    required String name,
    required String category,
    required double value,
    double weight = 1,
    String? positiveReason,
    String? negativeReason,
  }) {
    final polarity = value > 0
        ? 1
        : value < 0
            ? -1
            : 0;

    return UmaPredictionSignal(
      name: name,
      category: category,
      weight: weight,
      polarity: polarity,
      reason: polarity > 0
          ? (positiveReason ?? '$name supports this area.')
          : polarity < 0
              ? (negativeReason ?? '$name calls for caution in this area.')
              : '$name is neutral for this area.',
    );
  }

  List<UmaPredictionSignal> fromTransit({
    required String category,
    required List<Map<String, dynamic>> transits,
  }) {
    return transits.map((item) {
      final value = (item['value'] as num?)?.toDouble() ?? 0;
      return numeric(
        name: item['planet']?.toString() ?? 'Transit',
        category: category,
        value: value,
        weight: (item['weight'] as num?)?.toDouble() ?? 1,
        positiveReason: item['positiveReason']?.toString(),
        negativeReason: item['negativeReason']?.toString(),
      );
    }).toList(growable: false);
  }

  List<UmaPredictionSignal> fromYoga({
    required String category,
    required List<Map<String, dynamic>> yogas,
  }) {
    return yogas.map((item) {
      final value = (item['value'] as num?)?.toDouble() ?? 0;
      return numeric(
        name: item['name']?.toString() ?? 'Yoga',
        category: category,
        value: value,
        weight: (item['weight'] as num?)?.toDouble() ?? 1,
        positiveReason: item['positiveReason']?.toString(),
        negativeReason: item['negativeReason']?.toString(),
      );
    }).toList(growable: false);
  }
}
