// lib/widgets/flutter_panchang_cards.dart
// Modern Material 3 widgets for Shakti Panchang

import 'package:flutter/material.dart';
import '../services/hora_panchak_yoga_service.dart';

class HeroTithiCard extends StatelessWidget {
  final String tithi;
  final String paksha;
  final String masa;
  final String samvat;
  final double progress;
  final String? tithiEnd;

  const HeroTithiCard({
    super.key,
    required this.tithi,
    required this.paksha,
    required this.masa,
    required this.samvat,
    required this.progress,
    this.tithiEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const RadialGradient(
          center: Alignment(-0.8, -0.6),
          radius: 1.4,
          colors: [
            Color(0xFF5A2A18),
            Color(0xFF2C1407),
            Color(0xFF150802),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x662C1407),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE5A93C).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$paksha पक्ष • $masa मास',
                style: const TextStyle(
                  color: Color(0xFFF9D976),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9D976).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF9D976).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  samvat,
                  style: const TextStyle(
                    color: Color(0xFFFEE180),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tithi,
                      style: const TextStyle(
                        color: Color(0xFFFFF4DC),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (tithiEnd != null)
                      Text(
                        'समाप्ति: $tithiEnd तक',
                        style: TextStyle(
                          color: const Color(0xFFFFF4DC).withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Color(0xFFF9D976),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Text(
                    'व्यतीत',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 6,
              color: Colors.black38,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE5A93C), Color(0xFFF9D976)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SpecialYogaBanner extends StatelessWidget {
  final List<SpecialYogaResult> yogas;

  const SpecialYogaBanner({super.key, required this.yogas});

  @override
  Widget build(BuildContext context) {
    if (yogas.isEmpty) return const SizedBox.shrink();
    return Column(
      children: yogas.map((y) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5A93C), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x145A2A18),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5A93C).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('✨', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      y.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF462B17),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      y.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF735133),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5A93C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'सक्रिय',
                  style: TextStyle(
                    color: Color(0xFF150802),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PanchakBhadraRow extends StatelessWidget {
  final PanchakDetail panchak;
  final BhadraDetail bhadra;

  const PanchakBhadraRow({
    super.key,
    required this.panchak,
    required this.bhadra,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _indicatorCard(
            title: '⚡ पञ्चक',
            value: panchak.isActive ? panchak.typeNameHindi : 'पञ्चक मुक्त',
            isWarning: panchak.isActive && panchak.nature == 'inauspicious',
            isGood: panchak.isActive && panchak.nature == 'auspicious',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _indicatorCard(
            title: '🛡️ भद्रा',
            value: bhadra.isActive ? '${bhadra.vas} (${bhadra.nature == "varjya" ? "वर्जित" : "शुभ"})' : 'भद्रा मुक्त',
            isWarning: bhadra.isActive && bhadra.nature == 'varjya',
            isGood: !bhadra.isActive || bhadra.nature == 'auspicious',
          ),
        ),
      ],
    );
  }

  Widget _indicatorCard({
    required String title,
    required String value,
    bool isWarning = false,
    bool isGood = false,
  }) {
    Color bg = const Color(0xFFFFFBF2);
    Color border = const Color(0xFFE6D6B8);
    Color text = const Color(0xFF462B17);
    if (isWarning) {
      bg = const Color(0xFFFFF0F0);
      border = const Color(0xFFFFCDD2);
      text = const Color(0xFFB71C1C);
    } else if (isGood) {
      bg = const Color(0xFFF1F8E9);
      border = const Color(0xFFC8E6C9);
      text = const Color(0xFF2E7D32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: text, fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
