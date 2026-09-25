class SadeSatiPhase {
  final String name;
  final String shaniRashi;
  final String window;
  final bool active;
  final String intensity;
  final String description;
  const SadeSatiPhase({
    required this.name,
    required this.shaniRashi,
    required this.window,
    required this.active,
    required this.intensity,
    required this.description,
  });
}

class SadeSatiStatus {
  final String natalMoon;
  final String shaniRashi;
  final int houseFromMoon;
  final bool sadeSati;
  final bool dhaiya;
  final String dhaiyaType;
  final String summary;
  final List<SadeSatiPhase> phases;
  final List<String> remedies;
  const SadeSatiStatus({
    required this.natalMoon,
    required this.shaniRashi,
    required this.houseFromMoon,
    required this.sadeSati,
    required this.dhaiya,
    required this.dhaiyaType,
    required this.summary,
    required this.phases,
    required this.remedies,
  });
}

/// Port of shakti_panchang `src/services/sadesati.ts` using Shani ingress table.
class SadeSatiService {
  static const rashis = [
    'मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या',
    'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन',
  ];

  static const _ingress = [
    ('तुला', '2011-11-15', '2014-11-02'),
    ('वृश्चिक', '2014-11-02', '2017-01-26'),
    ('धनु', '2017-01-26', '2020-01-24'),
    ('मकर', '2020-01-24', '2023-01-17'),
    ('कुंभ', '2023-01-17', '2025-03-29'),
    ('मीन', '2025-03-29', '2028-02-23'),
    ('मेष', '2028-02-23', '2030-04-17'),
    ('वृषभ', '2030-04-17', '2032-05-31'),
    ('मिथुन', '2032-05-31', '2034-07-13'),
    ('कर्क', '2034-07-13', '2036-08-27'),
    ('सिंह', '2036-08-27', '2038-10-22'),
    ('कन्या', '2038-10-22', '2041-11-08'),
  ];

  static String currentShaniRashi([DateTime? when]) {
    final d = when ?? DateTime.now();
    for (final row in _ingress) {
      final start = DateTime.parse(row.$2);
      final end = DateTime.parse(row.$3);
      if (!d.isBefore(start) && d.isBefore(end)) return row.$1;
    }
    return 'मीन';
  }

  static String _windowFor(String rashi) {
    for (final row in _ingress) {
      if (row.$1 == rashi) return '${row.$2} → ${row.$3}';
    }
    return 'ढाई वर्ष';
  }

  static SadeSatiStatus forMoonRashi(String moonRashi, {DateTime? when}) {
    final moon = rashis.contains(moonRashi) ? moonRashi : 'कर्क';
    final moonIdx = rashis.indexOf(moon);
    final shani = currentShaniRashi(when);
    final shaniIdx = rashis.indexOf(shani);
    final house = ((shaniIdx - moonIdx + 12) % 12) + 1;
    final rising = house == 12;
    final peak = house == 1;
    final setting = house == 2;
    final sade = rising || peak || setting;
    final kantaka = house == 4;
    final ashtama = house == 8;
    final r12 = rashis[(moonIdx + 11) % 12];
    final r1 = rashis[moonIdx];
    final r2 = rashis[(moonIdx + 1) % 12];

    String summary;
    if (rising) {
      summary = 'चंद्र राशि $moon। शनि $shani में (१२वें भाव) — चढ़ती साढ़ेसाती। व्यय और नींद का संयम रखें।';
    } else if (peak) {
      summary = 'चंद्र राशि $moon पर शनि स्वयं गोचर कर रहे हैं — शिखर साढ़ेसाती। यह परीक्षा और परिश्रम का काल है।';
    } else if (setting) {
      summary = 'शनि चंद्र से द्वितीय भाव $shani में — उतरती साढ़ेसाती। कष्ट धीरे हटते हैं।';
    } else if (kantaka) {
      summary = 'चंद्र से चतुर्थ भाव में शनि — कंटक शनि ढैया। गृह-सुख और वाहन में सावधानी।';
    } else if (ashtama) {
      summary = 'चंद्र से अष्टम भाव में शनि — अष्टम ढैया। स्वास्थ्य सजगता और हनुमान पाठ।';
    } else {
      summary = 'शुभ समाचार। $moon चंद्र पर साढ़ेसाती या ढैया नहीं है। शनि चंद्र से $houseवें भाव में हैं।';
    }

    return SadeSatiStatus(
      natalMoon: moon,
      shaniRashi: shani,
      houseFromMoon: house,
      sadeSati: sade,
      dhaiya: kantaka || ashtama,
      dhaiyaType: kantaka
          ? 'कंटक शनि (चतुर्थ)'
          : ashtama
              ? 'अष्टम शनि'
              : 'कोई नहीं',
      summary: summary,
      phases: [
        SadeSatiPhase(
          name: 'प्रथम चरण — चढ़ती (मस्तक)',
          shaniRashi: r12,
          window: _windowFor(r12),
          active: rising,
          intensity: 'मध्यम',
          description: 'शनि द्वादश भाव में — व्यय, चिंता, अध्यात्म की ओर झुकाव।',
        ),
        SadeSatiPhase(
          name: 'द्वितीय चरण — शिखर (हृदय)',
          shaniRashi: r1,
          window: _windowFor(r1),
          active: peak,
          intensity: 'तीव्र',
          description: 'शनि जन्म राशि पर — कठोर परीक्षा, परिश्रम से सिद्धि।',
        ),
        SadeSatiPhase(
          name: 'तृतीय चरण — उतरती (चरण)',
          shaniRashi: r2,
          window: _windowFor(r2),
          active: setting,
          intensity: 'हल्का',
          description: 'शनि द्वितीय भाव में — धीरे राहत, वाणी और धन का अनुशासन।',
        ),
      ],
      remedies: const [
        'शनिवार को पीपल के नीचे सरसों तेल का दीप और सात परिक्रमा।',
        'नित्य हनुमान चालीसा या बजरंग बाण।',
        'शनिवार छाया दान — तेल में मुख देखकर दान।',
        'काले तिल, उड़द या कंबल का दान।',
        'सेवा और सत्य वचन — शनि कर्म से प्रसन्न होते हैं।',
      ],
    );
  }
}
