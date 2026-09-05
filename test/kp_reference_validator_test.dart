import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_reference_validator.dart';

void main() {
  test('reference validator passes identical fixed chart', () {
    const v=KpReferenceValidator(KpReferenceTolerance());
    final fixture=<String,dynamic>{
      'planets': {'Sun':100.0,'Moon':210.0},
      'cusps': {'1':10.0,'10':280.0},
    };
    final r=v.validate(actual:fixture,reference:fixture);
    expect(r.passed,true);
    expect(r.checked,4);
  });

  test('reference validator catches arc-second mismatch', () {
    const v=KpReferenceValidator(KpReferenceTolerance(longitudeArcSeconds:2));
    final r=v.validate(
      actual:{'planets':{'Sun':100.001}},
      reference:{'planets':{'Sun':100.0}},
    );
    expect(r.passed,false);
    expect(r.mismatches.single.deltaArcSeconds, closeTo(3.6,0.0001));
  });
}
