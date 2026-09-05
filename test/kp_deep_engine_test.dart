import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_deep_engine.dart';

void main() {
  test('KP event engine never fabricates a favourable result without signals', () {
    const reading = KpDeepReading(cusps: [], significators: [], rulingPlanets: []);
    final result = const KpDeepEngine().judgeEvent(
      reading: reading,
      event: 'career',
      favourableHouses: [2, 6, 10, 11],
      unfavourableHouses: [5, 8, 12],
    );
    expect(result.score, 0);
    expect(result.decision, 'Mixed or insufficient KP significators');
  });
}
