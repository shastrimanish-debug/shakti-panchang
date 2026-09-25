import 'dart:convert';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/astrologer_branding.dart';
import '../models/kundali_model.dart';
import 'advanced_kundali_service.dart';
import 'astrologer_branding_store.dart';
import 'kundali_analysis_service.dart';
import 'pdf_devanagari_fonts.dart';

/// Webapp exhaustiveKundaliPdf.ts (59-page mahapatrika) ka on-device sanskaran.
class ExhaustiveKundaliPdfService {
  static const _bg = PdfColor.fromInt(0xFFFBF3E0);
  static const _brown = PdfColor.fromInt(0xFF5C3A21);
  static const _gold = PdfColor.fromInt(0xFFC58F27);
  static const _red = PdfColor.fromInt(0xFF8B1E1E);

  static const _housePhal = [
    'Pratham bhava — tanu, swabhav, aakriti, swasthya ka mool aur jeevan ki disha.',
    'Dwitiya bhava — dhan, vani, parivar.',
    'Tritiya bhava — parakram, sahodar, laghu yatra.',
    'Chaturtha bhava — mata, sukh, vahan, bhumi.',
    'Panchama bhava — santan, vidya, buddhi, mantra.',
    'Shashtha bhava — shatru, rin, rog, seva.',
    'Saptama bhava — vivah, sajhedari, lok vyavahar.',
    'Ashtama bhava — aayu, gupt dhan, shodh.',
    'Navama bhava — dharma, guru, bhagya, teerth.',
    'Dashama bhava — karma, pad, yash, aajivika.',
    'Ekadasha bhava — labh, mitra, manorath siddhi.',
    'Dwadasha bhava — vyaya, moksha, videsh, shayan.',
  ];

  static const _houseDeep = [
    'Lagna bal vyaktitva aur swasthya pravritti tay karta hai.',
    'Dwitiyesh kendra/trikon mein ho to vani aur sangrah sthir.',
    'Tritiyesh bal sahas aur kaushal deta hai.',
    'Chaturthesh sukh-sampatti aur matri-sukh se juda hai.',
    'Panchamesh aur Guru santan-buddhi ke saath padhe jaate hain.',
    'Shashthesh rog-shatru ko jeetne ya ulajhne dono ka sanket.',
    'Saptamesh va Shukra dampatya swabhav.',
    'Ashtamesh aayu aur shodh ka dwaar.',
    'Navamesh bhagya ka stambh.',
    'Dashamesh karma ka mukut.',
    'Ekadashes labh ka dwaar.',
    'Dwadashes vyaya va vairagya.',
  ];

  static const _planetPhal = {
    'Surya': 'Atma, pita, prashasan, tej.',
    'Chandra': 'Man, mata, lokpriyata.',
    'Mangal': 'Urja, bhumi, bhrata, sahas.',
    'Budh': 'Buddhi, vanijya, vani, lekhan.',
    'Guru': 'Dharma, santan, guru, vistaar.',
    'Shukra': 'Kala, vivah, sukh, lakshmi.',
    'Shani': 'Karma, aayu, vilamb, anushasan.',
    'Rahu': 'Videsh, technique, moh, parivartan.',
    'Ketu': 'Vairagya, shodh, adhyatma, vicched.',
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
    ['D1 Rashi / Lagna', 'Samagra jeevan, shareer aur drishya karma.'],
    ['D2 Hora', 'Dhan-sanchay pravritti.'],
    ['D3 Drekkana', 'Sahodar, sahas, kaushal.'],
    ['D4 Chaturthamsha', 'Sampatti, vahan, bhumi.'],
    ['D7 Saptamsha', 'Santan aur rachna.'],
    ['D9 Navamsha', 'Dharma, dampatya, graha bal.'],
    ['D10 Dashamsha', 'Karma, pad, lok karya.'],
    ['D12 Dwadashamsha', 'Mata-pita, parampara.'],
    ['D16 Shodashamsha', 'Sukh, vahan, bhog.'],
    ['D20 Vimshamsha', 'Upasana, adhyatma.'],
    ['D24 Chaturvimshamsha', 'Vidya, siddhata.'],
    ['D27 Bhamsha', 'Bal aur kamzori.'],
    ['D30 Trimshamsha', 'Arishta, rog.'],
    ['D40 Khavedamsha', 'Matri paksha.'],
    ['D45 Akshavedamsha', 'Pitri paksha.'],
    ['D60 Shashtyamsha', 'Purva janma sanskar.'],
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
                        'Shakti Panchang • Sampurna Kundali Patrika',
                        style: pw.TextStyle(font: fonts.bold, fontSize: 8, color: _gold),
                      ),
                      pw.Text(
                        'Page $pageNo',
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

    page('Janma Patrika Aavaran', [
      pw.Text(d.name, style: pw.TextStyle(font: fonts.bold, fontSize: 22)),
      pw.SizedBox(height: 8),
      pw.Text('Janma: ${_fmt(d.birthDate)}  samay ${d.birthTime}'),
      pw.Text('Sthan: ${d.birthPlace}'),
      pw.Text('Lat ${d.latitude.toStringAsFixed(4)}  Lon ${d.longitude.toStringAsFixed(4)}  TZ ${d.timezoneHours}'),
      pw.SizedBox(height: 10),
      pw.Text('Lagna ${d.lagnaRashi} (${d.lagnaDegree.toStringAsFixed(2)}) • Chandra ${d.moonRashi} • Surya ${d.sunRashi}'),
      pw.Text('Nakshatra ${d.nakshatra}  charan ${d.charan}  nakshatresh ${_nakLordOf(d.nakshatra)}'),
      pw.Text('Nadi ${d.nadi} • Gana ${d.gana} • Yoni ${d.yoni} • Varna ${d.varna}'),
      pw.Text('Vimshottari: mahadasha ${d.mahadasha} / antardasha ${d.antardasha}'),
      pw.SizedBox(height: 16),
      if (brand.isConfigured) ...[
        pw.Text('Jyotish paramarsh', style: pw.TextStyle(font: fonts.bold, fontSize: 13)),
        pw.Text(brand.displayLine),
        if (brand.sansthan.isNotEmpty) pw.Text(brand.sansthan),
        if (brand.city.isNotEmpty) pw.Text(brand.city),
        if (brand.phone.isNotEmpty) pw.Text('Phone: ${brand.phone}'),
        if (brand.email.isNotEmpty) pw.Text(brand.email),
        if (brand.specialization.isNotEmpty) pw.Text(brand.specialization),
      ] else
        pw.Text('Jyotishi branding set nahi hai — settings se naam jodein.'),
    ]);

    page('Pathan vidhi', [
      pw.Text('Yeh patrika webapp exhaustive mahapatrika ki bhavna se on-device bani hai.'),
      pw.SizedBox(height: 8),
      pw.Bullet(text: 'Pehle lagna, chandra aur vartaman dasha sthir karein.'),
      pw.Bullet(text: 'Phir bhava-swami, yuti aur drishti dekhein.'),
      pw.Bullet(text: 'Navamsha (D9) se graha bal ki pariksha karein.'),
      pw.Bullet(text: 'Gochar aur dasha bina samay na bandhein.'),
      pw.Bullet(text: 'Upay daan-seva-jap star ke hon; ratna visheshagya se.'),
    ]);

    page('Graha sthiti', [
      ...d.planets.map(
        (p) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(
            '${p.planet}: ${p.rashi} ${p.degree.toStringAsFixed(2)} • bhava ${p.house}'
            '${p.isRetrograde ? ' • vakri' : ''} • gati ${p.speed.toStringAsFixed(3)}/din',
          ),
        ),
      ),
    ]);

    for (final h in houses) {
      final planets = h.planets.isEmpty ? 'rikt bhava' : h.planets.join(', ');
      page('Bhava ${h.house} — ${h.sign} (swami ${h.lord})', [
        pw.Text(_housePhal[(h.house - 1).clamp(0, 11)]),
        pw.SizedBox(height: 8),
        pw.Text(_houseDeep[(h.house - 1).clamp(0, 11)]),
        pw.SizedBox(height: 8),
        pw.Text('Is bhava mein graha: $planets'),
      ]);
    }

    for (final p in d.planets) {
      page('Graha path — ${p.planet}', [
        pw.Text(_planetPhal[p.planet] ?? 'Graha phal dasha aur bhava se dekha jata hai.'),
        pw.SizedBox(height: 8),
        pw.Text('Rashi ${p.rashi}, bhava ${p.house}, amsha ${p.degree.toStringAsFixed(2)}'),
        pw.Text(p.isRetrograde ? 'Vakri gati.' : 'Margi gati.'),
      ]);
    }

    page('Yoga vichar', [
      ...yogas.map((y) => pw.Bullet(text: y)),
      pw.SizedBox(height: 10),
      pw.Text('Yoga sanket hain, phal dasha aane par khilte hain.'),
    ]);

    page('Dosha vichar', [
      ...doshas.map((y) => pw.Bullet(text: y)),
      pw.SizedBox(height: 10),
      pw.Text('Dosha milan, dasha aur nishedh-bhang ke bina antim na maanein.'),
    ]);

    page('Vimshottari mahadasha', [
      pw.Text('Vartaman: ${d.mahadasha} / ${d.antardasha}'),
      pw.SizedBox(height: 8),
      ...d.dashaPeriods.take(9).map(
            (p) => pw.Text('${p.planet}: ${_fmt(p.startDate)} -> ${_fmt(p.endDate)} (${p.years.toStringAsFixed(2)} varsh)'),
          ),
    ]);

    for (final p in d.dashaPeriods.take(9)) {
      page('Mahadasha — ${p.planet}', [
        pw.Text('${_fmt(p.startDate)} se ${_fmt(p.endDate)}'),
        pw.Text('Avadhi lagbhag ${p.years.toStringAsFixed(2)} varsh.'),
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
        page('Antardasha — mahadasha ${e.key}', [
          ...e.value.take(18).map(
                (a) => pw.Text('${a.antar}: ${_fmt(a.startDate)} -> ${_fmt(a.endDate)} (${a.years.toStringAsFixed(2)} varsh)'),
              ),
        ]);
      }
    }

    if (d.pratyantarPeriods.isNotEmpty) {
      page('Pratyantar dasha', [
        ...d.pratyantarPeriods.take(24).map(
              (p) => pw.Text('${p.maha}/${p.antar}/${p.pratyantar}: ${_fmt(p.startDate)} -> ${_fmt(p.endDate)}'),
            ),
      ]);
    }

    page('Ashtakavarga (sarvashtak)', [
      pw.Text('Rashi kram Mesha se Meena. 28+ generally balwan kshetra.'),
      pw.SizedBox(height: 8),
      pw.Text('Sarvashtak: ${av.sarva.join('  ')}'),
      pw.SizedBox(height: 10),
      ...av.bhinna.entries.map((e) => pw.Text('${e.key}: ${e.value.join('  ')}')),
    ]);

    page('Bhava bal', [
      ...bhava.map(
        (h) => pw.Text('Bhava ${h['house']} ${h['sign']} • swami ${h['lord']} • SAV ${h['ashtakavarga']} • ank ${h['score']}'),
      ),
    ]);

    page('Shadbala saar', [
      ...shadbala.map(
        (s) => pw.Text(
          '${s['planet']}: kul ${(s['total'] as num).toStringAsFixed(1)} • '
          'sthana ${(s['sthana'] as num).toStringAsFixed(0)} '
          'dik ${(s['dig'] as num).toStringAsFixed(0)} '
          'kaal ${(s['kala'] as num).toStringAsFixed(0)} '
          'cheshta ${(s['chesta'] as num).toStringAsFixed(0)}',
        ),
      ),
    ]);

    page('Grahavastha', [
      ...avastha.map((a) => pw.Text('${a['planet']}: ${a['baladi']} • ${a['jagrad']} • ${a['deeptadi']} • ${a['status']}')),
    ]);

    for (final v in _vargaNotes) {
      page('Varga — ${v[0]}', [
        pw.Text(v[1]),
        pw.SizedBox(height: 8),
        pw.Text('Jatak: ${d.name} • lagna ${d.lagnaRashi} • chandra ${d.moonRashi}.'),
      ]);
    }

    page('Jeevan — vivah', [...marriage.map((t) => pw.Bullet(text: t))]);
    page('Jeevan — career', [...career.map((t) => pw.Bullet(text: t))]);
    page('Jeevan — dhan', [...wealth.map((t) => pw.Bullet(text: t))]);

    page('Dasha upay — ${remedies.focusPlanet}', [
      pw.Text('Kendra graha: ${remedies.focusPlanet}'),
      pw.SizedBox(height: 8),
      pw.Text('Karein', style: pw.TextStyle(font: fonts.bold)),
      ...remedies.remedies.map((t) => pw.Bullet(text: t)),
      pw.SizedBox(height: 8),
      pw.Text('Bachein', style: pw.TextStyle(font: fonts.bold)),
      ...remedies.avoid.map((t) => pw.Bullet(text: t)),
    ]);

    page('Satvik upay', [
      pw.Bullet(text: 'Nitya ishtadev / kuldevata smaran.'),
      pw.Bullet(text: 'Pratah surya arghya aur sandhya deep.'),
      pw.Bullet(text: 'Vartaman dasha swami ke vaar par daan-jap.'),
      pw.Bullet(text: 'Mata-pita ashirvad aur annadaan.'),
      pw.Bullet(text: 'Go-seva, vidyadaan aur satya vachan.'),
    ]);

    page('Seema evam ghoshana', [
      pw.Text('Yeh patrika ganana aur shastriya sanket hai, bhaya ya niyati nahi. Chikitsa, vidhik ya vittiya nirnay visheshagya se lein.'),
      pw.SizedBox(height: 12),
      pw.Text('Jatak: ${d.name}'),
      pw.Text('Janma: ${_fmt(d.birthDate)} ${d.birthTime}, ${d.birthPlace}'),
      if (brand.isConfigured) pw.Text('Paramarsh: ${brand.displayLine}'),
    ]);

    final bytes = await doc.save();
    final safe = d.name.replaceAll(RegExp(r'[^\w\u0900-\u097F]+'), '_');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Shakti_Sampurna_${safe.isEmpty ? 'Kundali' : safe}.pdf',
    );
  }
}
