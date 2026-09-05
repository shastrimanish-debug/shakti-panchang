import 'uma_prediction_scoring_engine.dart';

/// Converts calculated astrology signals into concise, user-facing UMA advice.
/// This layer deliberately contains no provider/calculation-engine branding.
class UmaPredictionExplanation {
  const UmaPredictionExplanation({
    required this.title,
    required this.summary,
    required this.timing,
    required this.guidance,
    required this.reasons,
    required this.level,
  });

  final String title;
  final String summary;
  final String timing;
  final String guidance;
  final List<String> reasons;
  final String level;
}

class UmaPredictionComposer {
  const UmaPredictionComposer();

  UmaPredictionExplanation compose({
    required String category,
    required UmaPredictionScore score,
    String timing = 'Current cycle',
  }) {
    final positive = score.score >= 2;
    final caution = score.score <= -2;

    final summary = positive
        ? 'Conditions are supportive, with a stronger opportunity window.'
        : caution
            ? 'Proceed carefully and prefer planning over rushed decisions.'
            : 'The indications are mixed; steady action and review are advisable.';

    final guidance = positive
        ? 'Use the supportive period for focused action, while keeping decisions practical.'
        : caution
            ? 'Double-check commitments, timing and assumptions before taking major decisions.'
            : 'Keep options open, verify important details and avoid overconfidence.';

    return UmaPredictionExplanation(
      title: '$category prediction',
      summary: summary,
      timing: timing,
      guidance: guidance,
      reasons: score.reasons,
      level: score.level,
    );
  }
}
