/// Lal Kitab rule signal layer.
///
/// Rules are represented as data so validated classical rules can be expanded
/// without changing the prediction UI.
class LalKitabInput {
  const LalKitabInput({
    required this.planet,
    required this.house,
    this.affliction = '',
    this.weight = 1.0,
  });
  final String planet;
  final int house;
  final String affliction;
  final double weight;
}

class LalKitabSignal {
  const LalKitabSignal({
    required this.planet,
    required this.house,
    required this.affliction,
    required this.score,
  });
  final String planet;
  final int house;
  final String affliction;
  final double score;
}

class LalKitabEngine {
  const LalKitabEngine();

  List<LalKitabSignal> calculate(List<LalKitabInput> inputs) {
    return inputs.map((i) {
      final house = i.house.clamp(1, 12).toInt();
      final affliction = i.affliction.trim();
      final score = (i.weight * (affliction.isEmpty ? 1 : 2)).clamp(0.0, 10.0).toDouble();
      return LalKitabSignal(
        planet: i.planet.trim(),
        house: house,
        affliction: affliction,
        score: score,
      );
    }).toList();
  }
}
