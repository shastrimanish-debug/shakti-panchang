import 'uma_prediction_explanation.dart';

class UmaPredictionViewModel {
  const UmaPredictionViewModel({
    required this.category,
    required this.title,
    required this.summary,
    required this.timing,
    required this.guidance,
    required this.level,
    required this.reasons,
  });

  final String category;
  final String title;
  final String summary;
  final String timing;
  final String guidance;
  final String level;
  final List<String> reasons;

  factory UmaPredictionViewModel.fromExplanation(
    UmaPredictionExplanation value,
  ) {
    return UmaPredictionViewModel(
      category: value.title.replaceFirst(' prediction', ''),
      title: value.title,
      summary: value.summary,
      timing: value.timing,
      guidance: value.guidance,
      level: value.level,
      reasons: List<String>.unmodifiable(value.reasons),
    );
  }
}
