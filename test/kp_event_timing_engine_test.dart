import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_event_timing_engine.dart';

void main() {
  test('timing window rejects inverted date ranges', () async {
    expect(
      () => const KpEventTimingEngine().findWindows(
        chart: throw UnimplementedError(),
        reading: throw UnimplementedError(),
        favourableHouses: const [2,6,10,11],
        from: DateTime(2026, 1, 2),
        to: DateTime(2026, 1, 1),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
