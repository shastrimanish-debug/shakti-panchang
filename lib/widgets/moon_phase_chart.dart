import 'dart:math' as math;

import 'package:flutter/material.dart';

class MoonPhaseChart extends StatelessWidget {
  final double solarLongitude;
  final double lunarLongitude;
  final String tithi;
  final String paksha;
  final String nakshatra;
  final String lunarRashi;
  final double tithiProgress;

  const MoonPhaseChart({
    super.key,
    required this.solarLongitude,
    required this.lunarLongitude,
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.lunarRashi,
    required this.tithiProgress,
  });

  double get elongation {
    final d = (lunarLongitude - solarLongitude) % 360;
    return d < 0 ? d + 360 : d;
  }

  double get illumination {
    final rad = elongation * math.pi / 180;
    return ((1 - math.cos(rad)) / 2).clamp(0.0, 1.0);
  }

  bool get waxing => elongation <= 180;

  @override
  Widget build(BuildContext context) {
    final pct = (illumination * 100).round();
    return Card(
      color: const Color(0xFF1B1530),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'चन्द्र कला',
              style: TextStyle(
                color: Color(0xFFF6E7B2),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 168,
              width: 168,
              child: CustomPaint(
                painter: _MoonPainter(elongation: elongation),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$tithi • $paksha',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${waxing ? 'शुक्ल पक्ष — बढ़ती कला' : 'कृष्ण पक्ष — घटती कला'} • प्रकाश $pct%',
              style: const TextStyle(color: Color(0xFFD7CBB3), fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'राशि $lunarRashi • नक्षत्र $nakshatra • तिथि ${((tithiProgress.clamp(0, 1)) * 100).round()}%',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFBFAE8A), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoonPainter extends CustomPainter {
  final double elongation;
  const _MoonPainter({required this.elongation});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.38;
    canvas.drawCircle(c, r + 10, Paint()..color = const Color(0x22F6E7B2));
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFE8E0C8));

    final illum = ((1 - math.cos(elongation * math.pi / 180)) / 2).clamp(0.0, 1.0);
    final waxing = elongation <= 180;
    final shadow = Path();
    if (illum < 0.02) {
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFF2A2344));
      return;
    }
    if (illum > 0.98) return;

    final w = r * (1 - illum) * 2;
    if (waxing) {
      shadow.addOval(Rect.fromCircle(center: c, radius: r));
      final cut = Path()
        ..addOval(Rect.fromCenter(center: Offset(c.dx + (r - w / 2), c.dy), width: w.clamp(2, r * 2), height: r * 2));
      final night = Path.combine(PathOperation.difference, shadow, cut);
      canvas.drawPath(night, Paint()..color = const Color(0xCC1B1530));
    } else {
      shadow.addOval(Rect.fromCircle(center: c, radius: r));
      final cut = Path()
        ..addOval(Rect.fromCenter(center: Offset(c.dx - (r - w / 2), c.dy), width: w.clamp(2, r * 2), height: r * 2));
      final night = Path.combine(PathOperation.difference, shadow, cut);
      canvas.drawPath(night, Paint()..color = const Color(0xCC1B1530));
    }
  }

  @override
  bool shouldRepaint(covariant _MoonPainter old) => old.elongation != elongation;
}
