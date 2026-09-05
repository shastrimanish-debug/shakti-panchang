import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_horary_judgement.dart';
import '../lib/services/kp_deep_engine.dart';
import '../lib/services/kp_horary_reference.dart';

void main() {
  test('KP Horary validates input range', () {
    const e = KpHoraryJudgementEngine(KpDeepEngine());
    const empty = KpDeepReading(cusps: [], significators: [], rulingPlanets: []);
    expect(() => e.judge(number: 0, question: KpQuestionType.career, reading: empty), throwsArgumentError);
    expect(() => e.judge(number: 250, question: KpQuestionType.career, reading: empty), throwsArgumentError);
  });

  test('KP reference anchors are retained', () {
    expect(kpReferenceRows.length, 11);
    expect(kpReferenceRows.first.starLord, 'केतु');
    expect(kpReferenceRows.first.subLord, 'केतु');
    expect(kpReferenceRows.last.number, 249);
  });

  test('No calculated significators means MIXED, never fabricated YES', () {
    const e = KpHoraryJudgementEngine(KpDeepEngine());
    const empty = KpDeepReading(cusps: [], significators: [], rulingPlanets: []);
    final v = e.judge(number: 137, question: KpQuestionType.career, reading: empty);
    expect(v.decision, 'MIXED');
    expect(v.supportScore, 0);
    expect(v.denialScore, 0);
  });
}
