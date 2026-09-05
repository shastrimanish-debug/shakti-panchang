import 'package:flutter/material.dart';
import '../models/kundali_model.dart';
import '../services/kundali_calculator.dart';
import '../services/xalen_service.dart';

/// North Indian divisional chart renderer.
/// Supports the 16 major Parashari vargas used by the app: D1, D2, D3, D4,
/// D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45 and D60.
class KundaliChart extends StatelessWidget {
  final KundaliData data;
  final String title;
  final bool embedded;

  const KundaliChart({super.key, required this.data, required this.title, this.embedded = false});

  static int _divisionFromTitle(String title) {
    final m = RegExp(r'D(\d+)', caseSensitive: false).firstMatch(title);
    final d = int.tryParse(m?.group(1) ?? '1') ?? 1;
    return d.clamp(1, 60).toInt();
  }

  List<PlanetPosition> _chartPlanets() {
    final division = _divisionFromTitle(title);
    if (division == 1) return data.planets;

    final engine = AstronomyEngineService();
    int vargaSign(double degree) {
      try {
        return engine.calculateVargaSign(degree, division: division);
      } catch (_) {
        return _vargaSignFallback(degree, division);
      }
    }

    final ascSign = vargaSign(data.lagnaDegree);
    return data.planets.map((p) {
      final signIndex = vargaSign(p.degree);
      final house = ((signIndex - ascSign + 12) % 12) + 1;
      return PlanetPosition(
        planet: p.planet,
        rashi: KundaliCalculator.rashis[signIndex],
        degree: p.degree,
        house: house,
        isRetrograde: p.isRetrograde,
        latitude: p.latitude,
        speed: p.speed,
      );
    }).toList();
  }

  static int _vargaSignFallback(double absoluteDegree, int division) {
    var deg = absoluteDegree % 360.0;
    if (deg < 0) deg += 360.0;
    final sign = (deg / 30.0).floor();
    final within = deg - sign * 30.0;
    final part = (within / (30.0 / division)).floor().clamp(0, division - 1).toInt();
    int norm(int v) => (v % 12 + 12) % 12;

    switch (division) {
      case 1:
        return sign;
      case 2:
        return sign.isEven ? (part == 0 ? 4 : 3) : (part == 0 ? 3 : 4);
      case 3:
        return norm(sign + const [0, 4, 8][part]);
      case 4:
        return norm(sign + const [0, 3, 6, 9][part]);
      case 7:
        final start = sign.isEven ? sign : norm(sign + 6);
        return norm(start + part);
      case 9:
        final start = sign % 3 == 0 ? sign : sign % 3 == 1 ? norm(sign + 8) : norm(sign + 4);
        return norm(start + part);
      case 10:
        final start = sign.isEven ? sign : norm(sign + 8);
        return norm(start + part);
      case 12:
        return norm(sign + part);
      case 16:
        final start = sign % 3 == 0 ? 0 : sign % 3 == 1 ? 4 : 8;
        return norm(start + part);
      case 20:
        final starts = const [0, 8, 4, 3];
        return norm(starts[sign % 4] + part);
      case 24:
        return norm((sign.isEven ? 4 : 3) + part);
      case 27:
        final starts = const [0, 3, 6, 9];
        return norm(starts[sign % 4] + part);
      case 30:
        if (sign.isEven) {
          if (within < 5) return 5;
          if (within < 10) return 10;
          if (within < 18) return 8;
          if (within < 25) return 2;
          return 6;
        }
        if (within < 5) return 1;
        if (within < 10) return 7;
        if (within < 18) return 9;
        if (within < 25) return 3;
        return 5;
      case 40:
        return norm((sign.isEven ? 4 : 3) + part);
      case 45:
        final starts = const [0, 4, 8];
        return norm(starts[sign % 3] + part);
      case 60:
        return norm(sign + part);
      default:
        // Extended technical varga: equal subdivision mapped sequentially.
        // This is deliberately not presented as a classical Parashari rule.
        return norm(sign + part);
    }
  }

  @override
  Widget build(BuildContext context) {
    final planets = _chartPlanets();
    final division = _divisionFromTitle(title);
    final ascSign = () {
      try { return AstronomyEngineService().calculateVargaSign(data.lagnaDegree, division: division); }
      catch (_) { return _vargaSignFallback(data.lagnaDegree, division); }
    }();
    final chartBody = Center(
      child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFC67D24), width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: NorthIndianChartPainter(planets: planets, ascSignIndex: ascSign),
              child: Container(),
            ),
          ),
        ),
    );
    if (embedded) return chartBody;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A3E00),
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: chartBody,
    );
  }
}

class NorthIndianChartPainter extends CustomPainter {
  final List<PlanetPosition> planets;
  final int ascSignIndex;

  NorthIndianChartPainter({required this.planets, required this.ascSignIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7A3E00)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
    canvas.drawLine(const Offset(0, 0), Offset(w, h), paint);
    canvas.drawLine(Offset(w, 0), Offset(0, h), paint);

    final path = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas.drawPath(path, paint);

    final houseCenters = <int, Offset>{
      1: Offset(w * 0.5, h * 0.25),
      2: Offset(w * 0.25, h * 0.12),
      3: Offset(w * 0.12, h * 0.25),
      4: Offset(w * 0.25, h * 0.5),
      5: Offset(w * 0.12, h * 0.75),
      6: Offset(w * 0.25, h * 0.88),
      7: Offset(w * 0.5, h * 0.75),
      8: Offset(w * 0.75, h * 0.88),
      9: Offset(w * 0.88, h * 0.75),
      10: Offset(w * 0.75, h * 0.5),
      11: Offset(w * 0.88, h * 0.25),
      12: Offset(w * 0.75, h * 0.12),
    };

    final housePlanets = <int, List<String>>{};
    for (final p in planets) {
      if (p.house < 1 || p.house > 12) continue;
      const shortNames = <String, String>{
        'सूर्य': 'सू', 'चंद्र': 'चं', 'मंगल': 'मं', 'बुध': 'बु', 'गुरु': 'गु',
        'शुक्र': 'शु', 'शनि': 'श', 'राहु': 'रा', 'केतु': 'के',
      };
      var shortName = shortNames[p.planet] ?? p.planet;
      if (p.isRetrograde) shortName += '®';
      housePlanets.putIfAbsent(p.house, () => []).add(shortName);
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final houseNumCoords = <int, Offset>{
      1: Offset(w * 0.5, h * 0.05),
      2: Offset(w * 0.15, h * 0.05),
      3: Offset(w * 0.05, h * 0.15),
      4: Offset(w * 0.05, h * 0.5),
      5: Offset(w * 0.05, h * 0.85),
      6: Offset(w * 0.15, h * 0.92),
      7: Offset(w * 0.5, h * 0.92),
      8: Offset(w * 0.85, h * 0.92),
      9: Offset(w * 0.92, h * 0.85),
      10: Offset(w * 0.92, h * 0.5),
      11: Offset(w * 0.92, h * 0.15),
      12: Offset(w * 0.85, h * 0.05),
    };

    houseNumCoords.forEach((house, pos) {
      textPainter.text = TextSpan(
        text: '$house',
        style: const TextStyle(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2));
    });

    const signNames = ['मे','वृ','मि','क','सि','क','तु','वृ','ध','म','कु','मी'];
    final signTextCoords = <int, Offset>{
      1: Offset(w * .5, h * .15), 2: Offset(w * .25, h * .08), 3: Offset(w * .15, h * .25),
      4: Offset(w * .25, h * .5), 5: Offset(w * .15, h * .75), 6: Offset(w * .25, h * .88),
      7: Offset(w * .5, h * .82), 8: Offset(w * .75, h * .88), 9: Offset(w * .85, h * .75),
      10: Offset(w * .75, h * .5), 11: Offset(w * .85, h * .25), 12: Offset(w * .75, h * .08),
    };
    signTextCoords.forEach((house, pos) {
      final signIndex = (ascSignIndex + house - 1) % 12;
      textPainter.text = TextSpan(text: signNames[signIndex], style: const TextStyle(color: Colors.black45, fontSize: 10, fontWeight: FontWeight.w700));
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2));
    });

    houseCenters.forEach((house, center) {
      if (!housePlanets.containsKey(house)) return;
      final pText = housePlanets[house]!.join(', ');
      textPainter.text = TextSpan(
        text: pText,
        style: const TextStyle(color: Color(0xFF5A2A00), fontSize: 11, fontWeight: FontWeight.w900),
      );
      textPainter.layout(maxWidth: w * 0.22);
      textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant NorthIndianChartPainter oldDelegate) =>
      oldDelegate.planets != planets || oldDelegate.ascSignIndex != ascSignIndex;
}
