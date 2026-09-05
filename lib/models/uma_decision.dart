enum UmaDecisionLevel { excellent, recommended, caution, avoid, insufficientData }

class UmaDecision {
  final String userQuestion;
  final String shortAnswer;
  final String spokenAnswer;
  final UmaDecisionLevel level;
  final List<String> reasons;
  final List<String> checks;
  final String action;

  const UmaDecision({
    required this.userQuestion,
    required this.shortAnswer,
    required this.spokenAnswer,
    required this.level,
    required this.reasons,
    required this.checks,
    required this.action,
  });
}
