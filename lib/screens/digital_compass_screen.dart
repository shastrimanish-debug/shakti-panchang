import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/disha_service.dart';

const _dirAngles = <String, double>{
  'उत्तर': 0,
  'ईशान': 45,
  'उत्तर-पूर्व': 45,
  'पूर्व': 90,
  'आग्नेय': 135,
  'दक्षिण-पूर्व': 135,
  'दक्षिण': 180,
  'नैऋत्य': 225,
  'दक्षिण-पश्चिम': 225,
  'पश्चिम': 270,
  'वायव्य': 315,
  'उत्तर-पश्चिम': 315,
};

class DigitalCompassScreen extends StatefulWidget {
  final String? shoolDirection;
  final double? targetBearing;
  final String? targetName;
  final bool blocked;

  const DigitalCompassScreen({
    super.key,
    this.shoolDirection,
    this.targetBearing,
    this.targetName,
    this.blocked = false,
  });

  @override
  State<DigitalCompassScreen> createState() => _DigitalCompassScreenState();
}

class _DigitalCompassScreenState extends State<DigitalCompassScreen> {
  double _heading = 0;

  @override
  Widget build(BuildContext context) {
    final shool = widget.shoolDirection ?? DishaService.avoided(DateTime.now());
    final shoolAngle = _dirAngles[shool] ?? 90;
    final target = widget.targetBearing;
    return Scaffold(
      appBar: AppBar(title: const Text('वैदिक दिशा-सूचक')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'आज दिशाशूल: $shool',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          if (widget.targetName != null)
            Text(
              'लक्ष्य: ${widget.targetName} • ${target?.toStringAsFixed(0) ?? '—'}°'
              '${widget.blocked ? '  (दिशाशूल से प्रभावित)' : ''}',
            ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _CompassPainter(
                heading: _heading,
                shoolAngle: shoolAngle,
                targetAngle: target,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('दिशा-सूचक घुमाएँ: ${_heading.round()}°',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Slider(
            value: _heading,
            min: 0,
            max: 359,
            label: '${_heading.round()}°',
            onChanged: (v) => setState(() => _heading = v),
          ),
          const SizedBox(height: 8),
          const Text(
            'लाल क्षेत्र आज का दिशाशूल है। फोन को उत्तर की ओर मिलाकर घुंडी से '
            'सूचक सेट करें। यात्रा अध्याय से लक्ष्य-दिशा यहाँ खुलती है।',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('उत्तर • कुबेर')),
              Chip(label: Text('पूर्व • इंद्र')),
              Chip(label: Text('दक्षिण • यम')),
              Chip(label: Text('पश्चिम • वरुण')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double shoolAngle;
  final double? targetAngle;
  const _CompassPainter({
    required this.heading,
    required this.shoolAngle,
    this.targetAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);

    canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFFF4E8D1));
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = const Color(0xFF5C3A21)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final shool = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: r),
        (shoolAngle - 22.5 - 90) * math.pi / 180,
        45 * math.pi / 180,
        false,
      )
      ..close();
    canvas.drawPath(shool, Paint()..color = const Color(0x66C62828));

    const labels = [
      ('उ', 0.0),
      ('ई', 45.0),
      ('पू', 90.0),
      ('आ', 135.0),
      ('द', 180.0),
      ('नै', 225.0),
      ('प', 270.0),
      ('वा', 315.0),
    ];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final e in labels) {
      final a = (e.$2 - 90) * math.pi / 180;
      final p = Offset(math.cos(a) * (r - 22), math.sin(a) * (r - 22));
      tp.text = TextSpan(
        text: e.$1,
        style: const TextStyle(
          color: Color(0xFF5C3A21),
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      );
      tp.layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    if (targetAngle != null) {
      final a = (targetAngle! - 90) * math.pi / 180;
      final p = Offset(math.cos(a) * (r - 48), math.sin(a) * (r - 48));
      canvas.drawCircle(p, 7, Paint()..color = const Color(0xFF1565C0));
    }

    canvas.restore();
    final needle = Path()
      ..moveTo(c.dx, c.dy - r + 18)
      ..lineTo(c.dx - 8, c.dy + 10)
      ..lineTo(c.dx + 8, c.dy + 10)
      ..close();
    canvas.drawPath(needle, Paint()..color = const Color(0xFF8B1E1E));
    canvas.drawCircle(c, 6, Paint()..color = const Color(0xFFB56A00));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.heading != heading ||
      old.shoolAngle != shoolAngle ||
      old.targetAngle != targetAngle;
}
