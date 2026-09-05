/// Prashna / Horary signal layer.
///
/// The caller supplies the question-time chart results from the astronomical
/// calculator. This layer normalizes houses, lords and strength signals for UMA.
class PrashnaInput {
  const PrashnaInput({
    required this.question,
    required this.ascendantHouse,
    required this.questionLord,
    required this.relevantHouses,
    this.strength = 1.0,
    this.timing = '',
  });
  final String question;
  final int ascendantHouse;
  final String questionLord;
  final List<int> relevantHouses;
  final double strength;
  final String timing;
}

class PrashnaSignal {
  const PrashnaSignal({
    required this.question,
    required this.ascendantHouse,
    required this.questionLord,
    required this.relevantHouses,
    required this.score,
    required this.timing,
  });
  final String question;
  final int ascendantHouse;
  final String questionLord;
  final List<int> relevantHouses;
  final double score;
  final String timing;
}

class PrashnaHoraryEngine {
  const PrashnaHoraryEngine();

  PrashnaSignal calculate(PrashnaInput input) {
    final houses = input.relevantHouses
        .where((h) => h >= 1 && h <= 12)
        .toSet()
        .toList();
    return PrashnaSignal(
      question: input.question.trim(),
      ascendantHouse: input.ascendantHouse.clamp(1, 12).toInt(),
      questionLord: input.questionLord.trim(),
      relevantHouses: houses,
      score: (houses.length * input.strength).clamp(0.0, 12.0).toDouble(),
      timing: input.timing.trim(),
    );
  }
}
