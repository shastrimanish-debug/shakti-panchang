import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/kundali_model.dart';

/// उत्तर भारतीय हीरा-चक्र — PDF canvas.
class PdfNorthChart extends pw.StatelessWidget {
  PdfNorthChart({
    required this.data,
    required this.regular,
    required this.bold,
  });

  final KundaliData data;
  final pw.Font regular;
  final pw.Font bold;

  static const _abbr = {
    'सूर्य': 'Su',
    'चंद्र': 'Mo',
    'चन्द्र': 'Mo',
    'मंगल': 'Ma',
    'बुध': 'Me',
    'गुरु': 'Ju',
    'शुक्र': 'Ve',
    'शनि': 'Sa',
    'राहु': 'Ra',
    'केतु': 'Ke',
  };

  @override
  pw.Widget build(pw.Context context) {
    final byHouse = <int, List<String>>{};
    for (final p in data.planets) {
      final tag = '${_abbr[p.planet] ?? p.planet}${p.isRetrograde ? 'R' : ''}';
      byHouse.putIfAbsent(p.house, () => []).add(tag);
    }
    final pdfRegular = regular.getFont(context);
    final pdfBold = bold.getFont(context);
    return pw.Column(
      children: [
        pw.Text(
          'D1 North Indian chart  •  Lagna ${data.lagnaRashi}',
          style: pw.TextStyle(font: bold, fontSize: 12),
        ),
        pw.SizedBox(height: 8),
        pw.SizedBox(
          width: 320,
          height: 320,
          child: pw.CustomPaint(
            painter: (PdfGraphics g, PdfPoint size) {
              _paint(g, size, byHouse, pdfRegular, pdfBold);
            },
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Su Surya  Mo Chandra  Ma Mangal  Me Budh  Ju Guru  Ve Shukra  Sa Shani  Ra Rahu  Ke Ketu. R = vakri.',
          style: pw.TextStyle(font: regular, fontSize: 8),
        ),
      ],
    );
  }

  void _paint(
    PdfGraphics g,
    PdfPoint size,
    Map<int, List<String>> byHouse,
    PdfFont pdfRegular,
    PdfFont pdfBold,
  ) {
    final w = size.x;
    final h = size.y;
    final brown = PdfColor.fromInt(0xFF5C3A21);
    final gold = PdfColor.fromInt(0xFFC58F27);
    final cream = PdfColor.fromInt(0xFFFBF3E0);

    g.setFillColor(cream);
    g.drawRect(0, 0, w, h);
    g.fillPath();
    g.setStrokeColor(brown);
    g.setLineWidth(1.4);
    g.drawRect(2, 2, w - 4, h - 4);
    g.strokePath();

    g.setStrokeColor(brown);
    g.setLineWidth(1.1);
    _line(g, 2, 2, w - 2, h - 2);
    _line(g, w - 2, 2, 2, h - 2);
    _line(g, w / 2, 2, w / 2, h - 2);
    _line(g, 2, h / 2, w - 2, h / 2);
    g.setStrokeColor(gold);
    g.setLineWidth(0.8);
    _line(g, w / 2, 2, 2, h / 2);
    _line(g, w / 2, 2, w - 2, h / 2);
    _line(g, w / 2, h - 2, 2, h / 2);
    _line(g, w / 2, h - 2, w - 2, h / 2);

    final spots = <int, PdfPoint>{
      1: PdfPoint(w * 0.50, h * 0.62),
      2: PdfPoint(w * 0.28, h * 0.80),
      3: PdfPoint(w * 0.14, h * 0.62),
      4: PdfPoint(w * 0.28, h * 0.50),
      5: PdfPoint(w * 0.14, h * 0.32),
      6: PdfPoint(w * 0.28, h * 0.16),
      7: PdfPoint(w * 0.50, h * 0.32),
      8: PdfPoint(w * 0.72, h * 0.16),
      9: PdfPoint(w * 0.86, h * 0.32),
      10: PdfPoint(w * 0.72, h * 0.50),
      11: PdfPoint(w * 0.86, h * 0.62),
      12: PdfPoint(w * 0.72, h * 0.80),
    };

    g.setFillColor(brown);
    for (final e in spots.entries) {
      final planets = (byHouse[e.key] ?? const []).join(' ');
      g.drawString(pdfBold, 9, '${e.key}', e.value.x - 4, e.value.y + 6);
      if (planets.isNotEmpty) {
        g.drawString(
          pdfRegular,
          8,
          planets,
          e.value.x - planets.length * 2.1,
          e.value.y - 6,
        );
      }
    }
  }

  void _line(PdfGraphics g, double x1, double y1, double x2, double y2) {
    g.moveTo(x1, y1);
    g.lineTo(x2, y2);
    g.strokePath();
  }
}
