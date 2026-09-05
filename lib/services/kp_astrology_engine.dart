import '../models/kundali_model.dart';
import 'kp_full_depth_engine.dart';

class KpInput {
  const KpInput({required this.cusp, required this.starLord, required this.subLord, required this.significatorHouses, this.weight = 1.0});
  final int cusp; final String starLord; final String subLord; final List<int> significatorHouses; final double weight;
}
class KpSignal {
  const KpSignal({required this.house, required this.starLord, required this.subLord, required this.significatorHouses, required this.score});
  final int house; final String starLord; final String subLord; final List<int> significatorHouses; final double score;
}

/// Compatibility facade. New code should use [KpFullDepthEngine].
class KpAstrologyEngine {
  const KpAstrologyEngine();
  List<KpSignal> calculate(List<KpInput> inputs) => inputs.map((i) {
    final houses = i.significatorHouses.where((h) => h >= 1 && h <= 12).toSet().toList()..sort();
    return KpSignal(house: i.cusp.clamp(1,12).toInt(), starLord: i.starLord.trim(), subLord: i.subLord.trim(), significatorHouses: houses, score: (houses.length*i.weight).clamp(0.0,12.0).toDouble());
  }).toList(growable:false);

  Future<KpFullDepthReading> calculateFromChart(KundaliData data) =>
      const KpFullDepthEngine().calculate(data);
}
