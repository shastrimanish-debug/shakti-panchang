import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_full_depth_engine.dart';

void main() {
  test('KP event judgement reports insufficient data instead of fabricating', () {
    const reading = KpFullDepthReading(cusps: [], planets: [], rulingPlanets: []);
    final result = const KpFullDepthEngine().judgeEvent(
      reading: reading,
      event: 'career',
      favourableHouses: [2, 6, 10, 11],
      unfavourableHouses: [5, 8, 12],
    );
    expect(result.decision, 'Insufficient KP signals');
  });
}
