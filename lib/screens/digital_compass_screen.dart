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

class _Cardinal {
  const _Cardinal(this.name, this.angle, this.en, this.devata);
  final String name;
  final double angle;
  final String en;
  final String devata;
}

const _cardinals = [
  _Cardinal('उत्तर', 0, 'N', 'कुबेर'),
  _Cardinal('ईशान', 45, 'NE', 'शिव'),
  _Cardinal('पूर्व', 90, 'E', 'इंद्र'),
  _Cardinal('आग्नेय', 135, 'SE', 'अग्नि'),
  _Cardinal('दक्षिण', 180, 'S', 'यम'),
  _Cardinal('नैऋत्य', 225, 'SW', 'नैऋति'),
  _Cardinal('पश्चिम', 270, 'W', 'वरुण'),
  _Cardinal('वायव्य', 315, 'NW', 'वायु'),
];

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

  _Cardinal _facing(double deg) {
    final n = (deg % 360 + 360) % 360;
    _Cardinal best = _cardinals.first;
    var bestDist = 360.0;
    for (final c in _cardinals) {
      final diff = (n - c.angle).abs();
      final dist = math.min(diff, 360 - diff);
      if (dist < bestDist) {
        bestDist = dist;
        best = c;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final shool = widget.shoolDirection ?? DishaService.avoided(DateTime.now());
    final shoolAngle = _dirAngles[shool] ?? 90;
    final target = widget.targetBearing ?? 90;
    final targetName = widget.targetName ?? directionForBearingV9(target);
    final facing = _facing(_heading);
    final facingShool = (_dirAngles[facing.name] ?? -1) == (_dirAngles[shool] ?? -2);

    return Scaffold(
      appBar: AppBar(title: const Text('वैदिक दिशा-सूचक')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('अष्ट दिक्पाल • दिशाशूल चेतावनी', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          Text('आज दिशाशूल: $shool  •  कोण ${_heading.round()}°'),
          if (widget.targetName != null)
            Text('लक्ष्य: ${widget.targetName} • ${target.toStringAsFixed(0)}°${widget.blocked ? '  (दिशाशूल से प्रभावित)' : ''}'),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: _CompassPainter(
                heading: _heading,
                shoolAngle: shoolAngle,
                targetAngle: target,
                facingLabel: facing.name,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'मुख: ${facing.name} (${facing.en}) • दिक्पाल ${facing.devata}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Slider(
            value: _heading,
            min: 0,
            max: 359,
            label: '${_heading.round()}°',
            onChanged: (v) => setState(() => _heading = v),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('उ 0°', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              Text('पू 90°', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              Text('द 180°', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              Text('प 270°', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            color: facingShool ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
            child: ListTile(
              leading: Icon(facingShool ? Icons.warning_amber_rounded : Icons.verified_rounded),
              title: Text(facingShool ? 'दिशाशूल चेतावनी' : 'अनुकूल दिशा', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(
                facingShool
                    ? 'मुख आज के वर्जित दिशाशूल ($shool) की ओर है। प्रस्थान से पहले परिहार करें।'
                    : 'मुख ${facing.name} है, दिक्पाल ${facing.devata}। आज दिशाशूल $shool वर्जित है।',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: const Color(0xFFF4E8D1),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _kv('यात्रा गंतव्य', '${target.toStringAsFixed(0)}° ($targetName)'),
                  _kv('आज का दिशाशूल', '$shool दिशा'),
                  _kv('मार्ग स्थिति', widget.blocked ? 'दिशाशूल प्रभावित' : 'शुभ व निर्बाध'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('लाल क्षेत्र आज का दिशाशूल। सोने का तीर गंतव्य। फोन को उत्तर मिलाकर घुंडी से सूचक सेट करें।'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in _cardinals)
                Chip(
                  backgroundColor: c.name == shool ? const Color(0xFFFFCDD2) : null,
                  label: Text('${c.name} • ${c.devata}'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  final double shoolAngle;
  final double? targetAngle;
  final String facingLabel;
  const _CompassPainter({
    required this.heading,
    required this.shoolAngle,
    this.targetAngle,
    required this.facingLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.42;
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);

    canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFFF4E8D1));
    canvas.drawCircle(Offset.zero, r, Paint()..color = const Color(0xFF5C3A21)..style = PaintingStyle.stroke..strokeWidth = 3);

    final shool = Path()
      ..moveTo(0, 0)
      ..arcTo(Rect.fromCircle(center: Offset.zero, radius: r), (shoolAngle - 22.5 - 90) * math.pi / 180, 45 * math.pi / 180, false)
      ..close();
    canvas.drawPath(shool, Paint()..color = const Color(0x66C62828));

    const labels = [
      ('उत्तर', 0.0),
      ('ईशान', 45.0),
      ('पूर्व', 90.0),
      ('आग्नेय', 135.0),
      ('दक्षिण', 180.0),
      ('नैऋत्य', 225.0),
      ('पश्चिम', 270.0),
      ('वायव्य', 315.0),
    ];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final e in labels) {
      final a = (e.$2 - 90) * math.pi / 180;
      final p = Offset(math.cos(a) * (r - 26), math.sin(a) * (r - 26));
      tp.text = TextSpan(
        text: e.$1,
        style: TextStyle(
          color: e.$2 == shoolAngle ? const Color(0xFF8B1E1E) : const Color(0xFF5C3A21),
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      );
      tp.layout();
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }

    if (targetAngle != null) {
      final a = (targetAngle! - 90) * math.pi / 180;
      final p = Offset(math.cos(a) * (r - 52), math.sin(a) * (r - 52));
      final gold = Paint()
        ..color = const Color(0xFFE69A33)
        ..strokeWidth = 3;
      canvas.drawLine(Offset.zero, p, gold);
      canvas.drawCircle(p, 7, gold);
    }

    canvas.restore();
    final needle = Path()
      ..moveTo(c.dx, c.dy - r + 18)
      ..lineTo(c.dx - 8, c.dy + 10)
      ..lineTo(c.dx + 8, c.dy + 10)
      ..close();
    canvas.drawPath(needle, Paint()..color = const Color(0xFF8B1E1E));
    canvas.drawCircle(c, 18, Paint()..color = const Color(0xFFF4E8D1));
    canvas.drawCircle(c, 18, Paint()..color = const Color(0xFFB56A00)..style = PaintingStyle.stroke..strokeWidth = 2);
    final hub = TextPainter(
      text: TextSpan(
        text: '${heading.round()}°\n$facingLabel',
        style: const TextStyle(color: Color(0xFF5C3A21), fontWeight: FontWeight.w900, fontSize: 9),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    hub.paint(canvas, c - Offset(hub.width / 2, hub.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.heading != heading || old.shoolAngle != shoolAngle || old.targetAngle != targetAngle || old.facingLabel != facingLabel;
}
