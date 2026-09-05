import 'kundali_calculator.dart';

class KpHoraryDivision {
  const KpHoraryDivision({
    required this.number,
    required this.sign,
    required this.signLord,
    required this.nakshatra,
    required this.starLord,
    required this.subLord,
    required this.fromDegree,
    required this.toDegree,
  });
  final int number;
  final String sign;
  final String signLord;
  final String nakshatra;
  final String starLord;
  final String subLord;
  final double fromDegree;
  final double toDegree;
}

class KpHoraryReading {
  const KpHoraryReading({
    required this.number,
    required this.ascendantDegree,
    required this.sign,
    required this.signLord,
    required this.nakshatra,
    required this.starLord,
    required this.subLord,
  });
  final int number;
  final double ascendantDegree;
  final String sign;
  final String signLord;
  final String nakshatra;
  final String starLord;
  final String subLord;
}

/// KP 1–249 horary number map.
///
/// The 243 ordinary nakshatra sub-divisions are split at the six sign
/// boundaries that cross a sub, producing the canonical 249 entries.
class KpHoraryEngine {
  const KpHoraryEngine();

  static const _years = <String, double>{
    'केतु': 7, 'शुक्र': 20, 'सूर्य': 6, 'चंद्र': 10, 'मंगल': 7,
    'राहु': 18, 'गुरु': 16, 'शनि': 19, 'बुध': 17,
  };
  static const _order = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
  static const _signs = KundaliCalculator.rashis;
  static const _nak = KundaliCalculator.nakshatras;
  static const _lords = <String,String>{
    'मेष':'मंगल','वृषभ':'शुक्र','मिथुन':'बुध','कर्क':'चंद्र','सिंह':'सूर्य','कन्या':'बुध',
    'तुला':'शुक्र','वृश्चिक':'मंगल','धनु':'गुरु','मकर':'शनि','कुंभ':'शनि','मीन':'गुरु',
  };

  List<KpHoraryDivision> table() {
    final raw = <_Arc>[];
    final nakSpan = 360.0 / 27.0;
    for (var n = 0; n < 27; n++) {
      final start = n * nakSpan;
      final star = _order[n % 9];
      final startIdx = _order.indexOf(star);
      var cursor = start;
      for (var i = 0; i < 9; i++) {
        final sub = _order[(startIdx + i) % 9];
        final end = cursor + nakSpan * (_years[sub]! / 120.0);
        raw.add(_Arc(cursor, end, n, star, sub));
        cursor = end;
      }
    }
    final split = <_Arc>[];
    for (final arc in raw) {
      var a = arc.from;
      while (a < arc.to - 1e-10) {
        final nextBoundary = ((a / 30.0).floor() + 1) * 30.0;
        final b = nextBoundary < arc.to ? nextBoundary : arc.to;
        split.add(_Arc(a, b, arc.nakIndex, arc.starLord, arc.subLord));
        a = b;
      }
    }
    split.sort((a,b) => a.from.compareTo(b.from));
    return List.generate(split.length, (i) {
      final a = split[i];
      final signIndex = (a.from / 30.0).floor().clamp(0,11);
      return KpHoraryDivision(
        number: i + 1,
        sign: _signs[signIndex],
        signLord: _lords[_signs[signIndex]]!,
        nakshatra: _nak[a.nakIndex],
        starLord: a.starLord,
        subLord: a.subLord,
        fromDegree: a.from,
        toDegree: a.to,
      );
    });
  }

  KpHoraryDivision division(int number) {
    if (number < 1 || number > 249) {
      throw ArgumentError.value(number, 'number', 'KP horary number must be 1..249.');
    }
    return table()[number - 1];
  }

  KpHoraryReading reading(int number) {
    final d = division(number);
    return KpHoraryReading(
      number: number,
      ascendantDegree: d.fromDegree,
      sign: d.sign,
      signLord: d.signLord,
      nakshatra: d.nakshatra,
      starLord: d.starLord,
      subLord: d.subLord,
    );
  }
}

class _Arc {
  const _Arc(this.from, this.to, this.nakIndex, this.starLord, this.subLord);
  final double from;
  final double to;
  final int nakIndex;
  final String starLord;
  final String subLord;
}
