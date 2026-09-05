import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../models/kundali_model.dart';
import 'kundali_analysis_service.dart';
import 'advanced_kundali_service.dart';

/// Server-side detailed Kundali PDF service.
/// The server embeds the exact fonts/kundali/fonts/noto.ttf file.
class PdfService {
  static const String _endpoint =
      'https://myshivshakti.in/kundali/generate_kundali.php';

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Map<String, dynamic> _planet(PlanetPosition p) => {
        'planet': p.planet,
        'rashi': p.rashi,
        'degree': p.degree,
        'house': p.house,
        'retrograde': p.isRetrograde,
        'latitude': p.latitude,
        'speed': p.speed,
      };

  static Map<String, dynamic> _dasha(DashaPeriod p) => {
        'planet': p.planet,
        'start': _date(p.startDate),
        'end': _date(p.endDate),
        'years': p.years,
      };

  static Map<String, dynamic> _antar(DashaSubPeriod p) => {
        'maha': p.maha,
        'antar': p.antar,
        'start': _date(p.startDate),
        'end': _date(p.endDate),
        'years': p.years,
      };

  static Map<String, dynamic> _praty(DashaPratyantar p) => {
        'maha': p.maha,
        'antar': p.antar,
        'pratyantar': p.pratyantar,
        'start': _date(p.startDate),
        'end': _date(p.endDate),
        'years': p.years,
      };

  static Future<Map<String, dynamic>> _payload(KundaliData data) async {
    final houses = KundaliAnalysisService.houses(data)
        .map((h) => {
              'house': h.house,
              'sign': h.sign,
              'lord': h.lord,
              'planets': h.planets,
            })
        .toList();
    final transits = await KundaliAnalysisService.currentTransits(data);
    final transitJson = transits
        .map((p) => {
              'planet': p.planet,
              'rashi': p.rashi,
              'degree': p.degree,
              'house': p.house,
              'retrograde': p.retrograde,
            })
        .toList();
    final doshas = KundaliAnalysisService.doshas(data);
    final yogas = KundaliAnalysisService.yogas(data);
    final remedy = AdvancedKundaliService.remedies(data);

    return {
      'name': data.name,
      'birthDate': _date(data.birthDate),
      'birthTime': data.birthTime,
      'birthPlace': data.birthPlace,
      'latitude': data.latitude,
      'longitude': data.longitude,
      'timezoneHours': data.timezoneHours,
      'lagnaDegree': data.lagnaDegree,
      'lagnaRashi': data.lagnaRashi,
      'moonRashi': data.moonRashi,
      'sunRashi': data.sunRashi,
      'nakshatra': data.nakshatra,
      'charan': data.charan,
      'nadi': data.nadi,
      'gana': data.gana,
      'yoni': data.yoni,
      'varna': data.varna,
      'mahadasha': data.mahadasha,
      'antardasha': data.antardasha,
      'planets': data.planets.map(_planet).toList(),
      'dashaPeriods': data.dashaPeriods.map(_dasha).toList(),
      'antarPeriods': data.antarPeriods.map(_antar).toList(),
      'pratyantarPeriods': data.pratyantarPeriods.map(_praty).toList(),
      'vargaDivisions': const [1, 2, 3, 4, 7, 9, 10, 12, 16, 20, 24, 27, 30, 40, 45, 60],
      'houses': houses,
      'transits': transitJson,
      'yogas': yogas,
      'doshas': doshas,
      'remedy': {
        'focusPlanet': remedy.focusPlanet,
        'remedies': remedy.remedies,
        'avoid': remedy.avoid,
      },
    };
  }

  static Future<void> generateAndSaveKundali(
    BuildContext context,
    KundaliData data,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('विस्तृत कुंडली रिपोर्ट बन रही है, कृपया प्रतीक्षा करें...'),
          duration: Duration(seconds: 5),
        ),
      );

      final payload = await _payload(data);
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: const {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/pdf, application/json',
              'Cache-Control': 'no-cache',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 60));

      final bytes = response.bodyBytes;
      final isPdf = bytes.length >= 4 &&
          bytes[0] == 0x25 && bytes[1] == 0x50 &&
          bytes[2] == 0x44 && bytes[3] == 0x46;

      if (response.statusCode == 200 && isPdf) {
        final safeName = data.name
            .replaceAll(RegExp(r'[^\w\-]+'), '_')
            .replaceAll(RegExp(r'_+'), '_');
        await Printing.sharePdf(
          bytes: Uint8List.fromList(bytes),
          filename: 'Shakti_Panchang_Detailed_$safeName.pdf',
        );
        return;
      }

      String serverText = utf8.decode(bytes, allowMalformed: true).trim();
      if (serverText.length > 400) serverText = '${serverText.substring(0, 400)}...';
      debugPrint('Kundali PDF server response ${response.statusCode}: $serverText');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Error ${response.statusCode}: $serverText')),
        );
      }
    } catch (e) {
      debugPrint('Kundali PDF connection error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF Connection Error: $e')),
        );
      }
    }
  }
}
