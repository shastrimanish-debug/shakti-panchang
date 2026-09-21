import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/astronomical_panchang.dart';
import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';
import 'kundali_analysis_service.dart';

/// ऑन-डिवाइस भोजपत्र PDF — वेब ऐप जैसी पत्रिका, PHP सर्वर नहीं।
class BhojpatraPdfService {
  static const _bg = PdfColor.fromInt(0xFFFBF3E0);
  static const _brown = PdfColor.fromInt(0xFF5C3A21);
  static const _gold = PdfColor.fromInt(0xFFC58F27);
  static const _red = PdfColor.fromInt(0xFF8B1E1E);

  static Future<({pw.Font regular, pw.Font bold})> _fonts() async {
    return (
      regular: await PdfGoogleFonts.notoSansDevanagariRegular(),
      bold: await PdfGoogleFonts.notoSansDevanagariBold(),
    );
  }

  static Future<void> kundali(KundaliData d) async {
    final f = await _fonts();
    final doc = pw.Document();
    final houses = KundaliAnalysisService.houses(d);
    final yogas = KundaliAnalysisService.yogas(d);
    final doshas = KundaliAnalysisService.doshas(d);
    final remedy = AdvancedKundaliService.remedies(d);
    final date =
        '${d.birthDate.day}/${d.birthDate.month}/${d.birthDate.year}';

    pw.Widget page(String title, List<pw.Widget> body) => pw.Container(
          width: double.infinity,
          height: double.infinity,
          color: _bg,
          padding: const pw.EdgeInsets.all(22),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _red, width: 2.2),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _gold, width: 1),
                  ),
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                        child: pw.Text('॥ श्री गणेशाय नमः ॥',
                            style: pw.TextStyle(font: f.bold, fontSize: 11, color: _red)),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Center(
                        child: pw.Text(title,
                            style: pw.TextStyle(font: f.bold, fontSize: 16, color: _brown)),
                      ),
                      pw.SizedBox(height: 10),
                      ...body,
                      pw.Spacer(),
                      pw.Center(
                        child: pw.Text('शक्ति पंचांग • व्यक्तिगत ज्योतिष पत्रिका • Swiss नहीं',
                            style: pw.TextStyle(font: f.regular, fontSize: 8, color: _gold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

    pw.Widget h(String t) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
          child: pw.Text(t, style: pw.TextStyle(font: f.bold, fontSize: 12, color: _red)),
        );
    pw.Widget p(String t) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(t, style: pw.TextStyle(font: f.regular, fontSize: 10, color: _brown, lineSpacing: 2)),
        );

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('जन्म कुंडली पत्रिका', [
        p('जातक: ${d.name}'),
        p('जन्म: $date, ${d.birthTime}'),
        p('स्थान: ${d.birthPlace}  (${d.latitude.toStringAsFixed(4)}, ${d.longitude.toStringAsFixed(4)})'),
        p('लग्न: ${d.lagnaRashi} ${d.lagnaDegree.toStringAsFixed(2)}°'),
        p('सूर्य राशि: ${d.sunRashi}  •  चंद्र राशि: ${d.moonRashi}'),
        p('नक्षत्र: ${d.nakshatra} चरण ${d.charan}  •  नाड़ी ${d.nadi}  •  गण ${d.gana}'),
        p('वर्तमान महादशा: ${d.mahadasha}  •  अंतरदशा: ${d.antardasha}'),
      ]),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('ग्रह स्थिति', [
        pw.TableHelper.fromTextArray(
          headers: const ['ग्रह', 'राशि', 'भाव', 'अंश', 'वक्र'],
          data: d.planets
              .map((x) => [
                    x.planet,
                    x.rashi,
                    '${x.house}',
                    x.degree.toStringAsFixed(2),
                    x.isRetrograde ? 'हाँ' : 'नहीं',
                  ])
              .toList(),
          headerStyle: pw.TextStyle(font: f.bold, fontSize: 9, color: _bg),
          headerDecoration: const pw.BoxDecoration(color: _brown),
          cellStyle: pw.TextStyle(font: f.regular, fontSize: 9, color: _brown),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ]),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('भाव फल', [
        ...houses.take(12).map((x) => p(
              '${x.house} भाव (${x.sign}, भावेश ${x.lord}): '
              '${x.planets.isEmpty ? 'खाली भाव' : x.planets.join(', ')}। '
              '${_houseHint(x.house)}',
            )),
      ]),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('योग, दोष और दशा', [
        h('योग'),
        ...yogas.take(8).map(p),
        h('दोष / सावधानी'),
        ...doshas.take(8).map(p),
        h('विम्शोत्तरी महादशा'),
        ...d.dashaPeriods.take(9).map((x) => p(
              '${x.planet}: ${x.startDate.day}/${x.startDate.month}/${x.startDate.year} — '
              '${x.endDate.day}/${x.endDate.month}/${x.endDate.year}',
            )),
      ]),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('फलित — क्या, क्यों, कब', [
        h('क्या'),
        p('लग्न ${d.lagnaRashi}, चंद्र ${d.moonRashi}, नक्षत्र ${d.nakshatra}। '
          'अभी ${d.mahadasha} महादशा और ${d.antardasha} अंतरदशा चल रही है।'),
        h('करियर (कर्म भाव)'),
        p(_area(d, 10, 'पद-यश', 'दसवें भाव और उसके स्वामी से आजीविका का संकेत मिलता है।')),
        h('धन'),
        p(_area(d, 2, 'धन-वाणी', 'दूसरे और ग्यारहवें भाव से आय-व्यय देखा जाता है।')),
        h('विवाह'),
        p(_area(d, 7, 'दाम्पत्य', 'सातवें भाव, शुक्र/गुरु और दशा से संबंध का समय देखा जाता है।')),
        h('स्वास्थ्य'),
        p(_area(d, 1, 'तनु', 'लग्न और छठे भाव से स्वास्थ्य का सामान्य संकेत — यह चिकित्सा नहीं।')),
      ]),
    ));

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => page('उपाय और घोषणा', [
        h('फोकस ग्रह: ${remedy.focusPlanet}'),
        ...remedy.remedies.take(8).map(p),
        h('बचें'),
        ...remedy.avoid.take(6).map(p),
        h('घोषणा'),
        p('यह पत्रिका शक्ति पंचांग के लाहिरी/मीयस इंजन से बनी है। Swiss Ephemeris नहीं। '
          'फलित सामान्य शास्त्र-संकेत हैं, भाग्य-लेख नहीं। विवाह, स्वास्थ्य, धन के निर्णय '
          'केवल इसी PDF से न लें। रत्न/अनुष्ठान योग्य आचार्य की सलाह से करें।'),
        p('शक्ति पंचांग • Powered by SHIV SHAKTI'),
      ]),
    ));

    final bytes = await doc.save();
    final safe = d.name.replaceAll(RegExp(r'[^\w\-]+'), '_');
    await Printing.sharePdf(bytes: bytes, filename: 'Shakti_Patrika_$safe.pdf');
  }

  static Future<void> panchang({
    required AstronomicalPanchang p,
    required DateTime date,
    required String place,
  }) async {
    final f = await _fonts();
    final doc = pw.Document();
    String hm(DateTime t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (_) => pw.Container(
        color: _bg,
        padding: const pw.EdgeInsets.all(24),
        child: pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: _red, width: 2.4)),
          padding: const pw.EdgeInsets.all(16),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(child: pw.Text('॥ श्री गणेशाय नमः ॥', style: pw.TextStyle(font: f.bold, color: _red))),
              pw.SizedBox(height: 8),
              pw.Center(
                  child: pw.Text('दैनिक भोजपत्र पंचांग',
                      style: pw.TextStyle(font: f.bold, fontSize: 18, color: _brown))),
              pw.SizedBox(height: 6),
              pw.Center(
                  child: pw.Text('$place  •  ${date.day}/${date.month}/${date.year}',
                      style: pw.TextStyle(font: f.regular, fontSize: 11, color: _brown))),
              pw.SizedBox(height: 16),
              _row(f, 'पक्ष / तिथि', '${p.paksha} ${p.tithi}'),
              _row(f, 'नक्षत्र', p.nakshatra),
              _row(f, 'योग', p.yoga),
              _row(f, 'करण', p.karana),
              _row(f, 'सूर्य राशि', p.solarRashi),
              _row(f, 'अयनांश', '${p.ayanamshaName} ${p.ayanamsha.toStringAsFixed(4)}°'),
              _row(f, 'सूर्योदय', hm(p.localSunrise)),
              _row(f, 'सूर्यास्त', hm(p.localSunset)),
              _row(f, 'इंजन', p.engine),
              pw.SizedBox(height: 16),
              pw.Text(
                'आज सात्विक कार्य सूर्योदय के बाद करें। राहुकाल में नया शुभ कार्य न लगाएँ। '
                'यह पंचांग स्थानीय सूर्योदय पर आधारित है।',
                style: pw.TextStyle(font: f.regular, fontSize: 10, color: _brown),
              ),
              pw.Spacer(),
              pw.Center(
                  child: pw.Text('शक्ति पंचांग • ₹99/वर्ष • Swiss नहीं',
                      style: pw.TextStyle(font: f.regular, fontSize: 8, color: _gold))),
            ],
          ),
        ),
      ),
    ));
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'Shakti_Panchang_${date.year}_${date.month}_${date.day}.pdf',
    );
  }

  static pw.Widget _row(({pw.Font regular, pw.Font bold}) f, String k, String v) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(children: [
          pw.SizedBox(
              width: 120,
              child: pw.Text(k, style: pw.TextStyle(font: f.bold, fontSize: 11, color: _red))),
          pw.Expanded(child: pw.Text(v, style: pw.TextStyle(font: f.regular, fontSize: 11, color: _brown))),
        ]),
      );

  static String _houseHint(int h) => const {
        1: 'व्यक्तित्व और स्वास्थ्य का आधार।',
        2: 'धन, वाणी, परिवार।',
        3: 'साहस, सहोदर, अल्पकालिक यात्रा।',
        4: 'सुख, माता, भूमि, वाहन।',
        5: 'विद्या, संतान, बुद्धि।',
        6: 'रोग, ऋण, शत्रु, सेवा।',
        7: 'विवाह और साझेदारी।',
        8: 'आयु, गूढ़, आकस्मिक घटना।',
        9: 'भाग्य, धर्म, गुरु, दीर्घ यात्रा।',
        10: 'कर्म, यश, आजीविका।',
        11: 'लाभ, मित्र, मनोकामना।',
        12: 'व्यय, विदेश, मोक्ष।',
      }[h] ??
      '';

  static String _area(KundaliData d, int house, String label, String why) {
    final occ = d.planets.where((p) => p.house == house).map((p) => p.planet).join(', ');
    return 'क्या: $label भाव में ${occ.isEmpty ? 'कोई ग्रह नहीं' : occ}। '
        'क्यों: $why '
        'समय: वर्तमान ${d.mahadasha}/${d.antardasha} दशा में इस भाव का फल विशेष देखा जाए। '
        'सावधानी: एक भाव से पूरा जीवन न पढ़ें। '
        'उपाय: दान, सेवा और दशा-स्वामी ग्रह के सरल उपाय।';
  }
}
