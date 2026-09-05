import 'package:flutter/material.dart';

class PlanetIcon extends StatelessWidget {
  final String planet;
  final double size;

  const PlanetIcon({super.key, required this.planet, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = _getPlanetColor(planet);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Text(
          _getPlanetSymbol(planet),
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String _getPlanetSymbol(String planet) {
    switch (planet) {
      case 'सूर्य': return '☉';
      case 'चंद्र': return '☽';
      case 'मंगल': return '♂';
      case 'बुध': return '☿';
      case 'गुरु': return '♃';
      case 'शुक्र': return '♀';
      case 'शनि': return '♄';
      case 'राहु': return '☊';
      case 'केतु': return '☋';
      default: return '●';
    }
  }

  Color _getPlanetColor(String planet) {
    switch (planet) {
      case 'सूर्य': return Colors.orange;
      case 'चंद्र': return Colors.grey.shade400;
      case 'मंगल': return Colors.red;
      case 'बुध': return Colors.green;
      case 'गुरु': return Colors.amber;
      case 'शुक्र': return Colors.pink.shade300;
      case 'शनि': return Colors.blueGrey;
      case 'राहु': return Colors.deepPurple;
      case 'केतु': return Colors.brown;
      default: return Colors.grey;
    }
  }
}
