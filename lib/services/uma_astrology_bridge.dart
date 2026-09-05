import 'uma_kundali_intelligence.dart';

/// User-facing astrology bridge.
///
/// The calculation provider is intentionally kept behind this abstraction.
/// UI code should talk to UMA/domain methods rather than exposing the
/// underlying calculation engine or provider name.
class UmaAstrologyBridge {
  UmaAstrologyBridge({UmaKundaliIntelligence? intelligence})
      : _intelligence = intelligence ?? UmaKundaliIntelligence();

  final UmaKundaliIntelligence _intelligence;

  /// Converts raw astrology data into a concise prediction context.
  ///
  /// Keep provider-specific details out of widgets and user-facing strings.
  Map<String, dynamic> buildPredictionContext(
    Map<String, dynamic> chartData,
  ) {
    return <String, dynamic>{
      'chart': chartData,
      'engine': 'internal',
      'assistant': 'UMA',
    };
  }

  /// Sanitizes technical/provider leakage before anything reaches UI.
  String sanitizeUserText(String text) {
    const blocked = <String>[
      'internal calculation engine',
      'internal calculation engine',
      'internal calculation engine',
    ];
    var result = text;
    for (final token in blocked) {
      result = result.replaceAll(token, 'UMA');
    }
    return result;
  }

  UmaKundaliIntelligence get intelligence => _intelligence;
}
