import 'package:flutter_test/flutter_test.dart';
import '../lib/services/kp_horary_engine.dart';

void main() {
  const engine = KpHoraryEngine();
  test('canonical KP 1-249 count and first rows', () {
    final table = engine.table();
    expect(table.length, 249);
    expect(table[0].number, 1);
    expect(table[0].sign, 'मेष');
    expect(table[0].starLord, 'केतु');
    expect(table[0].subLord, 'केतु');
    expect(table[0].fromDegree, closeTo(0, 1e-9));
    expect(table[1].number, 2);
    expect(table[1].subLord, 'शुक्र');
    expect(table[1].fromDegree, closeTo(0.7777777778, 1e-8));
    expect(table[9].number, 10);
    expect(table[9].fromDegree, closeTo(13.3333333333, 1e-8));
  });
  test('sign-crossing subs produce the canonical 249 rows', () {
    final table = engine.table();
    expect(table.length, 249);
    expect(table.where((x) => x.sign == 'मेष').length, 22);
    expect(table.where((x) => x.sign == 'वृषभ').length, 19);
    expect(table.where((x) => x.sign == 'मिथुन').length, 21);
    expect(table.where((x) => x.sign == 'कर्क').length, 21);
    expect(table.where((x) => x.sign == 'सिंह').length, 22);
    expect(table.where((x) => x.sign == 'कन्या').length, 19);
    expect(table.where((x) => x.sign == 'तुला').length, 21);
    expect(table.where((x) => x.sign == 'वृश्चिक').length, 21);
    expect(table.where((x) => x.sign == 'धनु').length, 22);
    expect(table.where((x) => x.sign == 'मकर').length, 19);
    expect(table.where((x) => x.sign == 'कुंभ').length, 21);
    expect(table.where((x) => x.sign == 'मीन').length, 21);
    expect(table.last.number, 249);
    expect(table.last.sign, 'मीन');
  });
}
