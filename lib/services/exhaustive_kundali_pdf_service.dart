import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';
import 'astrologer_branding_store.dart';
import 'kundali_analysis_service.dart';
import 'pdf_devanagari_fonts.dart';

/// Webapp exhaustiveKundaliPdf.ts (59-page mahapatrika) ka on-device Hindi sanskaran.
class ExhaustiveKundaliPdfService {
  static const _bg = PdfColor.fromInt(0xFFFBF3E0);
  static const _brown = PdfColor.fromInt(0xFF5C3A21);
  static const _gold = PdfColor.fromInt(0xFFC58F27);
  static const _red = PdfColor.fromInt(0xFF8B1E1E);

  static const _housePhal = [
    'प्रथम भाव — तनु, स्वभाव, आकृति, स्वास्थ्य का मूल और जीवन की दिशा।',
    'द्वितीय भाव — धन संग्रह, वाणी, परिवार, आँख और भोजन।',
    'तृतीय भाव — पराक्रम, सहोदर, लघु यात्रा, लेखन और साहस।',
    'चतुर्थ भाव — माता, सुख, वाहन, भूमि, शिक्षा-आधार और अन्तःकरण।',
    'पञ्चम भाव — संतान, विद्या, बुद्धि, मन्त्र और पूर्व पुण्य।',
    'षष्ठ भाव — शत्रु, ऋण, रोग, सेवा-कर्म और प्रतिदिन का संघर्ष।',
    'सप्तम भाव — विवाह, साझेदारी, लोक व्यवहार और बाह्य संबंध।',
    'अष्टम भाव — आयु, रूपान्तर, गुप्त धन, शोध और आकस्मिक घटना।',
    'नवम भाव — धर्म, गुरु, भाग्य, तीर्थ और उच्च विद्या।',
    'दशम भाव — कर्म, पद, यश, पिता का लोक और आजीविका।',
    'एकादश भाव — लाभ, मित्र, मनोरथ सिद्धि और आय के द्वार।',
    'द्वादश भाव — व्यय, मोक्ष, विदेश, शयन और अदृश्य क्षय।',
  ];

  static const _houseDeep = [
    'लग्न बल और लग्नेश की दशा व्यक्तित्व, स्वास्थ्य-प्रवृत्ति और संसार में पहला प्रभाव तय करती है।',
    'द्वितीयेश यदि केन्द्र/त्रिकोण में हो तो वाणी और संग्रह दोनों में स्थिरता आती है।',
    'तृतीयेश का बल साहस, कौशल और छोटे उद्यम का समय देता है।',
    'चतुर्थेश का संबंध सुख-संपत्ति और मातृ-सुख से है; चंद्र यहाँ विशेष देखा जाता है।',
    'पंचमेश और गुरु संतान-बुद्धि के निर्णय में साथ पढ़े जाते हैं।',
    'षष्ठेश बल रोग-शत्रु को जीतने या उनसे उलझने दोनों का संकेत दे सकता है।',
    'सप्तमेश व शुक्र दाम्पत्य स्वभाव बताते हैं; सप्तम में नीच ग्रह विलंब या सीख का संकेत है।',
    'अष्टमेश आयु और शोध दोनों का द्वार है; गुप्त धन तभी पकता है जब दशा सहयोग करे।',
    'नवमेश भाग्य का स्तम्भ है; सूर्य-गुरु यहाँ धर्म और मान बढ़ाते हैं।',
    'दशमेश कर्म का मुकुट है; शनि-सूर्य-बुध यहाँ पेशे की दिशा बताते हैं।',
    'एकादशेश लाभ का द्वार; मित्र और नेटवर्क यहीं से फलते हैं।',
    'द्वादशेश व्यय व वैराग्य; विदेश और निद्रा-दोष यहीं देखे जाते हैं।',
  ];

  static const _planetPhal = {
    'सूर्य': 'आत्मा, पिता, प्रशासन, अस्थि और तेज। उच्च में सिंह/मेष के निकट आत्मविश्वास।',
    'चंद्र': 'मन, माता, लोकप्रियता, रक्त और चंचलता। पक्ष और नक्षत्र से मन का रंग बदलता है।',
    'मंगल': 'ऊर्जा, भूमि, भ्राता, रक्त-धातु और साहस। वक्री मंगल निर्णय में पुनरावृत्ति लाता है।',
    'बुध': 'बुद्धि, वाणिज्य, वाणी, त्वचा और लेखन। सूर्य-संग बुधादित्य, चंद्र-संग चंचल बुद्धि।',
    'गुरु': 'धर्म, संतान, गुरु, मेद और विस्तार। केन्द्र/त्रिकोण में गजकेसरी जैसे योग पुष्ट होते हैं।',
    'शुक्र': 'कला, विवाह, सुख, शुक्रधातु और लक्ष्मी। नीच/वक्र पर भोग में असंतुलन।',
    'शनि': 'कर्म, आयु, विलम्ब, वायु और अनुशासन। दृष्टि जहाँ पड़े वहाँ परिपक्वता या भार।',
    'राहु': 'विदेश, तकनीक, मोह और अचानक परिवर्तन। छाया ग्रह — युति ग्रह का रंग उग्र करता है।',
    'केतु': 'वैराग्य, शोध, आध्यात्म और विच्छेद। जहाँ केतु हो वहाँ विषय अधूरा या पारलौकिक लगता है।',
  };

  static const _nakLord = {
    'अश्विनी': 'केतु',
    'भरणी': 'शुक्र',
    'कृतिका': 'सूर्य',
    'रोहिणी': 'चंद्र',
    'मृगशिरा': 'मंगल',
    'आर्द्रा': 'राहु',
    'पुनर्वसु': 'गुरु',
    'पुष्य': 'शनि',
    'अश्लेषा': 'बुध',
    'मघा': 'केतु',
    'पूर्वाफाल्गुनी': 'शुक्र',
    'उत्तराफाल्गुनी': 'सूर्य',
    'हस्त': 'चंद्र',
    'चित्रा': 'मंगल',
    'स्वाति': 'राहु',
    'विशाखा': 'गुरु',
    'अनुराधा': 'शनि',
    'ज्येष्ठा': 'बुध',
    'मूल': 'केतु',
    'पूर्वाषाढ़ा': 'शुक्र',
    'उत्तराषाढ़ा': 'सूर्य',
    'श्रवण': 'चंद्र',
    'धनिष्ठा': 'मंगल',
    'शतभिषा': 'राहु',
    'पूर्वाभाद्रपद': 'गुरु',
    'उत्तराभाद्रपद': 'शनि',
    'रेवती': 'बुध',
  };

  static const _vargaNotes = [
    ['D1 राशि / लग्न', 'समग्र जीवन, शरीर और दृश्य कर्म।'],
    ['D2 होरा', 'धन-संचय की प्रवृत्ति।'],
    ['D3 द्रेष्काण', 'सहोदर, साहस, कौशल।'],
    ['D4 चतुर्थांश', 'संपत्ति, वाहन, भूमि।'],
    ['D7 सप्तमांश', 'संतान और रचना।'],
    ['D9 नवमांश', 'धर्म, दाम्पत्य, ग्रह बल।'],
    ['D10 दशमांश', 'कर्म, पद, लोक कार्य।'],
    ['D12 द्वादशांश', 'माता-पिता, परंपरा।'],
    ['D16 षोडशांश', 'सुख, वाहन, भोग।'],
    ['D20 विंशांश', 'उपासना, आध्यात्म।'],
    ['D24 चतुर्विंशांश', 'विद्या, सिद्धता।'],
    ['D27 भांशा', 'बल और कमजोरी।'],
    ['D30 त्रिंशांश', 'अरिष्ट, रोग।'],
    ['D40 खवेदांश', 'मातृ पक्ष।'],
    ['D45 अक्षवेदांश', 'पितृ पक्ष।'],
    ['D60 षष्ट्यांश', 'पूर्व जन्म संस्कार।'],
  ];

  static pw.Font? _regular;
  static pw.Font? _bold;

  static pw.Font _fontFromB64(String b64) {
    final bytes = Uint8List.fromList(base64Decode(b64.replaceAll('\n', '')));
    return pw.Font.ttf(ByteData.view(bytes.buffer));
  }

  static Future<({pw.Font regular, pw.Font bold})> _fonts() async {
    if (_regular != null && _bold != null) {
      return (regular: _regular!, bold: _bold!);
    }
    try {
      if (kPdfDevaRegularB64.trim().isNotEmpty &&
          kPdfDevaBoldB64.trim().isNotEmpty) {
        _regular = _fontFromB64(kPdfDevaRegularB64);
        _bold = _fontFromB64(kPdfDevaBoldB64);
        return (regular: _regular!, bold: _bold!);
      }
    } catch (_) {}
    final pair = (
      regular: await PdfGoogleFonts.notoSansDevanagariRegular(),
      bold: await PdfGoogleFonts.notoSansDevanagariBold(),
    );
    _regular = pair.regular;
    _bold = pair.bold;
    return pair;
  }

  static String _fmt(DateTime d) => '${d.day}-${d.month}-${d.year}';

  static String _nakLordOf(String nak) {
    for (final e in _nakLord.entries) {
      if (nak.contains(e.key)) return e.value;
    }
    return '—';
  }

  static Future<void> generate(KundaliData d) async {
    final fonts = await _fonts();
    final brand = await AstrologerBrandingStore.load();
    final yogas = KundaliAnalysisService.yogas(d);
    final doshas = KundaliAnalysisService.doshas(d);
    final houses = KundaliAnalysisService.houses(d);
    final av = AdvancedKundaliService.ashtakavarga(d);
    final shadbala = AdvancedKundaliService.shadbala(d);
    final avastha = AdvancedKundaliService.avastha(d);
    final bhava = AdvancedKundaliService.bhavaBala(d, av);
    final remedies = AdvancedKundaliService.remedies(d);
    final marriage = AdvancedKundaliService.lifeAnalysis(d, 'विवाह');
    final career = AdvancedKundaliService.lifeAnalysis(d, 'करियर');
    final wealth = AdvancedKundaliService.lifeAnalysis(d, 'धन');

    final doc = pw.Document();
    var pageNo = 0;

    void page(String title, List<pw.Widget> body) {
      pageNo += 1;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (_) => pw.Container(
            color: _bg,
            padding: const pw.EdgeInsets.all(16),
            child: pw.DefaultTextStyle(
              style: pw.TextStyle(
                font: fonts.regular,
                fontSize: 11,
                color: _brown,
                height: 1.35,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'शक्ति पंचांग • सम्पूर्ण कुंडली पत्रिका',
                        style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: _gold),
                      ),
                      pw.Text(
                        'पृष्ठ $pageNo',
                        style: pw.TextStyle(font: fonts.regular, fontSize: 8, color: _gold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(title, style: pw.TextStyle(font: fonts.bold, fontSize: 16, color: _red)),
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(vertical: 8),
                    height: 1.2,
                    color: _gold,
                  ),
                  ...body,
                  pw.Spacer(),
                  pw.Text(
                    brand.isConfigured
                        ? '${brand.displayLine}${brand.city.isNotEmpty ? ' • ${brand.city}' : ''}'
                        : 'Powered by SHIV SHAKTI',
                    style: pw.TextStyle(font: fonts.regular, fontSize: 8, color: _gold),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    page('॥ श्री गणेशाय नमः ॥  जन्म पत्रिका आवरण', [
      pw.Text(d.name, style: pw.TextStyle(font: fonts.bold, fontSize: 22)),
      pw.SizedBox(height: 8),
      pw.Text('जन्म: ${_fmt(d.birthDate)}  समय ${d.birthTime}'),
      pw.Text('स्थान: ${d.birthPlace}'),
      pw.Text('अक्षांश ${d.latitude.toStringAsFixed(4)}  रेखांश ${d.longitude.toStringAsFixed(4)}  TZ ${d.timezoneHours}'),
      pw.SizedBox(height: 10),
      pw.Text('लग्न ${d.lagnaRashi} (${d.lagnaDegree.toStringAsFixed(2)}°) • चंद्र ${d.moonRashi} • सूर्य ${d.sunRashi}'),
      pw.Text('नक्षत्र ${d.nakshatra}  चरण ${d.charan}  नक्षत्रेश ${_nakLordOf(d.nakshatra)}'),
      pw.Text('नाड़ी ${d.nadi} • गण ${d.gana} • योनि ${d.yoni} • वर्ण ${d.varna}'),
      pw.Text('विंशोत्तरी: महादशा ${d.mahadasha} / अंतर्दशा ${d.antardasha}'),
      pw.SizedBox(height: 16),
      if (brand.isConfigured) ...[
        pw.Text('ज्योतिष परामर्श', style: pw.TextStyle(font: fonts.bold, fontSize: 13)),
        pw.Text(brand.displayLine),
        if (brand.sansthan.isNotEmpty) pw.Text(brand.sansthan),
        if (brand.city.isNotEmpty) pw.Text(brand.city),
        if (brand.phone.isNotEmpty) pw.Text('दूरभाष: ${brand.phone}'),
        if (brand.email.isNotEmpty) pw.Text(brand.email),
        if (brand.specialization.isNotEmpty) pw.Text(brand.specialization),
      ] else
        pw.Text('ज्योतिषी ब्रांडिंग सेट नहीं है — सेटिंग से नाम जोड़ें, आवरण पर छपेगा।'),
    ]);

    page('जातक परिचय व पठन विधि', [
      pw.Text('यह पत्रिका वेब ऐप की सम्पूर्ण महापत्रिका की भावना से ऑन-डिवाइस बनी है। ग्रह, भाव, योग-दोष, विंशोत्तरी, अष्टकवर्ग, षड्बल और वर्ग एक साथ पढ़ें।'),
      pw.SizedBox(height: 8),
      pw.Bullet(text: 'पहले लग्न, चंद्र और वर्तमान दशा स्थिर करें।'),
      pw.Bullet(text: 'फिर भाव-स्वामी, युति और दृष्टि देखें।'),
      pw.Bullet(text: 'नवमांश (D9) से ग्रह बल की परीक्षा करें।'),
      pw.Bullet(text: 'गोचर और दशा बिना समय न बाँधें।'),
      pw.Bullet(text: 'उपाय दान-सेवा-जप स्तर के हों; रत्न विशेषज्ञ से ही।'),
    ]);

    page('ग्रह स्थिति सारणी', [
      ...d.planets.map(
        (p) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(
            '${p.planet}: ${p.rashi} ${p.degree.toStringAsFixed(2)}° • भाव ${p.house}'
            '${p.isRetrograde ? ' • वक्री' : ''} • गति ${p.speed.toStringAsFixed(3)}°/दिन',
          ),
        ),
      ),
    ]);

    for (final h in houses) {
      final planets = h.planets.isEmpty ? 'रिक्त भाव' : h.planets.join(', ');
      page('भाव ${h.house} — ${h.sign} (स्वामी ${h.lord})', [
        pw.Text(_housePhal[(h.house - 1).clamp(0, 11)]),
        pw.SizedBox(height: 8),
        pw.Text(_houseDeep[(h.house - 1).clamp(0, 11)]),
        pw.SizedBox(height: 8),
        pw.Text('इस भाव में ग्रह: $planets'),
        pw.SizedBox(height: 8),
        pw.Text('भाव फल जातक के कर्म, दशा और गोचर से पकता है। केवल भाव-स्वामी या एक दृष्टि से निश्चय न करें।'),
      ]);
    }

    for (final p in d.planets) {
      page('ग्रह पाठ — ${p.planet}', [
        pw.Text(_planetPhal[p.planet] ?? 'ग्रह फल दशा और भाव से देखा जाता है।'),
        pw.SizedBox(height: 8),
        pw.Text('राशि ${p.rashi}, भाव ${p.house}, अंश ${p.degree.toStringAsFixed(2)}°'),
        pw.Text(p.isRetrograde ? 'वक्री गति — विषय में पुनर्विचार और पुनरावृत्ति।' : 'मार्गी गति।'),
      ]);
    }

    page('योग विचार', [
      ...yogas.map((y) => pw.Bullet(text: y)),
      pw.SizedBox(height: 10),
      pw.Text('योग संकेत हैं, फल दशा आने पर ही पूर्ण खिलते हैं।'),
    ]);

    page('दोष विचार', [
      ...doshas.map((y) => pw.Bullet(text: y)),
      pw.SizedBox(height: 10),
      pw.Text('दोष मिलान, दशा और निषेध-भंग के बिना अंतिम न मानें।'),
    ]);

    page('विंशोत्तरी महादशा क्रम', [
      pw.Text('वर्तमान: ${d.mahadasha} / ${d.antardasha}'),
      pw.SizedBox(height: 8),
      ...d.dashaPeriods.take(9).map(
            (p) => pw.Text('${p.planet}: ${_fmt(p.startDate)} → ${_fmt(p.endDate)} (${p.years.toStringAsFixed(2)} वर्ष)'),
          ),
    ]);

    for (final p in d.dashaPeriods.take(9)) {
      page('महादशा — ${p.planet}', [
        pw.Text('${_fmt(p.startDate)} से ${_fmt(p.endDate)}'),
        pw.Text('अवधि लगभग ${p.years.toStringAsFixed(2)} वर्ष।'),
        pw.SizedBox(height: 8),
        pw.Text(_planetPhal[p.planet] ?? ''),
      ]);
    }

    if (d.antarPeriods.isNotEmpty) {
      final byMaha = <String, List<DashaSubPeriod>>{};
      for (final a in d.antarPeriods) {
        byMaha.putIfAbsent(a.maha, () => []).add(a);
      }
      for (final e in byMaha.entries.take(9)) {
        page('अंतर्दशा — महादशा ${e.key}', [
          ...e.value.take(18).map(
                (a) => pw.Text('${a.antar}: ${_fmt(a.startDate)} → ${_fmt(a.endDate)} (${a.years.toStringAsFixed(2)} वर्ष)'),
              ),
        ]);
      }
    }

    if (d.pratyantarPeriods.isNotEmpty) {
      page('प्रत्यंतर दशा', [
        ...d.pratyantarPeriods.take(24).map(
              (p) => pw.Text('${p.maha}/${p.antar}/${p.pratyantar}: ${_fmt(p.startDate)} → ${_fmt(p.endDate)}'),
            ),
      ]);
    }

    page('अष्टकवर्ग (सर्वाष्टक)', [
      pw.Text('राशि क्रम मेष से मीन। 28+ सामान्यतः बलवान क्षेत्र।'),
      pw.SizedBox(height: 8),
      pw.Text('सर्वाष्टक: ${av.sarva.join('  ')}'),
      pw.SizedBox(height: 10),
      ...av.bhinna.entries.map((e) => pw.Text('${e.key}: ${e.value.join('  ')}')),
    ]);

    page('भाव बल', [
      ...bhava.map(
        (h) => pw.Text('भाव ${h['house']} ${h['sign']} • स्वामी ${h['lord']} • SAV ${h['ashtakavarga']} • अंक ${h['score']}'),
      ),
    ]);

    page('षड्बल सार', [
      ...shadbala.map(
        (s) => pw.Text(
          '${s['planet']}: कुल ${(s['total'] as num).toStringAsFixed(1)} • '
          'स्थान ${(s['sthana'] as num).toStringAsFixed(0)} '
          'दिक् ${(s['dig'] as num).toStringAsFixed(0)} '
          'काल ${(s['kala'] as num).toStringAsFixed(0)} '
          'चेष्टा ${(s['chesta'] as num).toStringAsFixed(0)}',
        ),
      ),
    ]);

    page('ग्रहावस्था', [
      ...avastha.map((a) => pw.Text('${a['planet']}: ${a['baladi']} • ${a['jagrad']} • ${a['deeptadi']} • ${a['status']}')),
    ]);

    for (final v in _vargaNotes) {
      page('वर्ग — ${v[0]}', [
        pw.Text(v[1]),
        pw.SizedBox(height: 8),
        pw.Text('जातक: ${d.name} • लग्न ${d.lagnaRashi} • चंद्र ${d.moonRashi}।'),
      ]);
    }

    page('जीवन क्षेत्र — विवाह', [...marriage.map((t) => pw.Bullet(text: t))]);
    page('जीवन क्षेत्र — करियर', [...career.map((t) => pw.Bullet(text: t))]);
    page('जीवन क्षेत्र — धन', [...wealth.map((t) => pw.Bullet(text: t))]);

    page('दशा उपाय — ${remedies.focusPlanet}', [
      pw.Text('केन्द्र ग्रह: ${remedies.focusPlanet}'),
      pw.SizedBox(height: 8),
      pw.Text('करें', style: pw.TextStyle(font: fonts.bold)),
      ...remedies.remedies.map((t) => pw.Bullet(text: t)),
      pw.SizedBox(height: 8),
      pw.Text('बचें', style: pw.TextStyle(font: fonts.bold)),
      ...remedies.avoid.map((t) => pw.Bullet(text: t)),
    ]);

    page('सात्विक उपाय', [
      pw.Bullet(text: 'नित्य इष्टदेव / कुलदेवता स्मरण।'),
      pw.Bullet(text: 'प्रातः सूर्य अर्घ्य और संध्या दीप।'),
      pw.Bullet(text: 'वर्तमान दशा स्वामी के वार पर दान-जप।'),
      pw.Bullet(text: 'माता-पिता का आशीर्वाद और अन्नदान।'),
      pw.Bullet(text: 'गो-सेवा, विद्यादान और सत्य वचन।'),
    ]);

    page('सीमाएँ एवं घोषणा', [
      pw.Text('यह पत्रिका गणना और शास्त्रीय संकेत है, भय या नियति नहीं। चिकित्सा, विधिक या वित्तीय निर्णय विशेषज्ञ से लें।'),
      pw.SizedBox(height: 12),
      pw.Text('जातक: ${d.name}'),
      pw.Text('जन्म: ${_fmt(d.birthDate)} ${d.birthTime}, ${d.birthPlace}'),
      if (brand.isConfigured) pw.Text('परामर्श: ${brand.displayLine}'),
    ]);

    final bytes = await doc.save();
    final safe = d.name.replaceAll(RegExp(r'[^\w\u0900-\u097F]+'), '_');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Shakti_Sampurna_${safe.isEmpty ? 'Kundali' : safe}.pdf',
    );
  }
}
