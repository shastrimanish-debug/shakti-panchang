import '../models/kundali_model.dart';

/// Live panchang snapshot so Uma can speak today's numbers without
/// depending on Gemini / a remote server.
class UmaPanchangSnap {
  final String place;
  final String weekday;
  final String paksha;
  final String tithi;
  final String nakshatra;
  final String yoga;
  final String karana;
  final String sunrise;
  final String sunset;
  final String rahuKaal;
  final String yamaganda;
  final String gulika;
  final String shubhChoghadiya;
  final String currentChoghadiya;
  final String dishaShool;
  final String brahmaMuhurat;

  const UmaPanchangSnap({
    required this.place,
    required this.weekday,
    required this.paksha,
    required this.tithi,
    required this.nakshatra,
    required this.yoga,
    required this.karana,
    required this.sunrise,
    required this.sunset,
    required this.rahuKaal,
    required this.yamaganda,
    required this.gulika,
    required this.shubhChoghadiya,
    required this.currentChoghadiya,
    required this.dishaShool,
    required this.brahmaMuhurat,
  });
}

class UmaVidvanReply {
  final String text;
  final String action;
  final List<String> reasons;
  final List<String> checks;

  const UmaVidvanReply({
    required this.text,
    this.action =
        'विवाह, करियर, धन, स्वास्थ्य, साढ़ेसाती, दशा या आज का पंचांग पूछ सकते हैं।',
    this.reasons = const ['काशी-उज्जैन परंपरा का स्थानीय विद्वान् इंजन'],
    this.checks = const ['यह मार्गदर्शन शास्त्रीय संकेत है, भय नहीं।'],
  });
}

/// Port of shakti_panchang src/lib/uma.ts localVedicInference +
/// server.ts vidvan system prompt. Works fully offline.
class UmaVidvanEngine {
  const UmaVidvanEngine();

  static const String greeting =
      'नमस्ते प्रिय यजमान, मैं उमा हूँ — शक्ति पंचांग की विदुषी ज्योतिषाचार्य। बोलिए, क्या जानना है?';

  static const Map<String, String> dashaRemedies = {
    'सूर्य':
        'नित्य प्रातः तांबे के लोटे से सूर्यदेव को अर्घ्य दें और ॐ सूर्याय नमः अथवा आदित्य हृदय स्तोत्र का पाठ करें।',
    'चंद्र':
        'सोमवार को शिवलिंग पर कच्चा दूध व जल अर्पित करें और ॐ नमः शिवाय का १०२ बार मानसिक जप करें।',
    'मंगल':
        'नित्य हनुमान चालीसा का पाठ करें, मंगलवार को लाल मसूर अथवा गुड़ का दान करें और ॐ भौमाय नमः जपें।',
    'बुध':
        'प्रतिदिन श्री गणेश संकट नाशन स्तोत्र का पाठ करें, बुधवार को गाय को हरा चारा खिलाएं और ॐ बुधाय नमः जपें।',
    'गुरु':
        'बृहस्पतिवार को भगवान विष्णु की आराधना करें, पीले चंदन का तिलक लगाएं और ॐ ग्रां ग्रीं ग्रौं सः गुरवे नमः जपें।',
    'शुक्र':
        'शुक्रवार को श्री सूक्त या कनकधारा स्तोत्र का पाठ करें, कन्याओं का आदर करें और ॐ शुं शुक्राय नमः जपें।',
    'शनि':
        'शनिवार को पीपल के वृक्ष के नीचे सरसों के तेल का दीपक प्रज्वलित करें, शनि चालीसा पढ़ें और काले तिल का दान करें।',
    'राहु':
        'शनिवार या बुधवार को ॐ भ्रां भ्रीं भ्रौं सः राहवे नमः का जप करें, भैरव जी की उपासना करें और पक्षियों को बाजरा डालें।',
    'केतु':
        'श्री गणेश जी की आराधना करें, दुर्वा अर्पित करें और ॐ कें केतवे नमः का जप करें। आवारा श्वान को रोटी दें।',
  };

  UmaVidvanReply answer({
    required String query,
    KundaliData? kundali,
    UmaPanchangSnap? panchang,
    String? pageContext,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) {
      return UmaVidvanReply(text: _wrap(greeting), action: 'कोई विषय बोलिए।');
    }
    if (_has(q, ['सम्पूर्ण', 'पूरा फलादेश', 'फुल रीडिंग', 'कुंडली चेक', 'कुंडली देखो', 'kundali check', 'पूरी कुंडली', 'कुंडली बता'])) {
      return _kundaliReading(kundali);
    }
    if (_has(q, ['करियर', 'नौकरी', 'जॉब', 'व्यापार', 'बिज़्नेस', 'बिजनेस', 'career', 'job', 'business', 'प्रमोशन', 'आजीविका'])) {
      return _career(kundali);
    }
    if (_has(q, ['विवाह', 'शादी', 'marriage', 'wedding', 'दाम्पत्य', 'सगाई', 'मिलान'])) {
      return _marriage(kundali);
    }
    if (_has(q, ['धन', 'पैसा', 'आय', 'कर्ज', 'संपत्ति', 'wealth', 'money', 'finance', 'लाभ', 'लक्ष्मी'])) {
      return _wealth(kundali);
    }
    if (_has(q, ['शनि', 'साढ़ेसाती', 'साढेसाती', 'ढैय्या', 'sade sati', 'sadesati', 'saturn'])) {
      return _shani(kundali, panchang);
    }
    if (_has(q, ['स्वास्थ्य', 'बीमारी', 'रोग', 'health', 'तबीयत', 'आरोग्य'])) {
      return _health(kundali);
    }
    if (_has(q, ['राहु काल', 'राहुकाल', 'राहु', 'यमगंड', 'यमगण्ड', 'गुलिक', 'rahu'])) {
      return _panchangKaal(panchang, focus: 'rahu');
    }
    if (_has(q, ['चौघड़िया', 'चौघड़िया', 'choghadiya', 'चोघड़िया'])) {
      return _panchangKaal(panchang, focus: 'choghadiya');
    }
    if (_has(q, ['यात्रा', 'दिशाशूल', 'दिशा शूल', 'travel', 'निकलना'])) {
      return _travel(panchang);
    }
    if (_has(q, ['सूर्योदय', 'सूर्यास्त', 'sunrise', 'sunset', 'ब्रह्म मुहूर्त'])) {
      return _panchangKaal(panchang, focus: 'sun');
    }
    if (_has(q, ['पंचांग', 'panchang', 'तिथि', 'नक्षत्र', 'आज का', 'आज की'])) {
      return _panchangKaal(panchang, focus: 'panchang');
    }
    if (_has(q, ['महादशा', 'अंतरदशा', 'अन्तर्दशा', 'दशा', 'dasha', 'antardasha'])) {
      return _dasha(kundali);
    }
    if (_has(q, ['ग्रह कहाँ', 'ग्रह कहा', 'मेरे ग्रह', 'planets', 'ग्रह स्थिति', 'लग्न'])) {
      return _graha(kundali);
    }
    if (_has(q, ['मांगलिक', 'मंगल दोष', 'manglik'])) {
      return _manglik(kundali);
    }
    if (_has(q, ['उपाय', 'Remedy', 'remedy', 'क्या करूँ', 'क्या करूं'])) {
      return _remedy(kundali);
    }
    if (pageContext != null && _has(q, ['इस पन्ने', 'इस पेज', 'पन्ने की', 'इस अध्याय'])) {
      return UmaVidvanReply(
        text: _wrap(
          'प्रिय यजमान, आप अभी **$pageContext** अध्याय में हैं।\n\n'
          'यह ग्रंथ का पन्ना है। विषय पूछिए — पंचांग, कुंडली, मुहूर्त, यात्रा या उपाय — मैं उसी पर शास्त्रीय उत्तर दूँगी।',
        ),
        action: '$pageContext से जुड़ा प्रश्न पूछें।',
      );
    }
    return _default(query, kundali, panchang);
  }

  UmaVidvanReply _kundaliReading(KundaliData? k) {
    if (k == null) return _needKundali('सम्पूर्ण फलादेश');
    final yogas = _yogas(k);
    final dosha = _manglikLine(k);
    final remedy = dashaRemedies[k.mahadasha] ?? 'नित्य गायत्री मंत्र का १०२ बार जप करें।';
    return UmaVidvanReply(
      text: _wrap(
        '**जातक:** ${k.name} | **लग्न:** ${k.lagnaRashi} | '
        '**चंद्र राशि:** ${k.moonRashi} (${k.nakshatra} नक्षत्र, चरण ${k.charan})\n'
        '**सूर्य राशि:** ${k.sunRashi}\n\n'
        '**१. व्यक्तित्व व लग्न बल:**\n'
        'आपका लग्न ${k.lagnaRashi} है। यह लग्न स्वभाव, शरीर और जीवन की दिशा तय करता है।\n\n'
        '**२. प्रमुख ग्रहीय योग:**\n$yogas\n$dosha\n\n'
        '**३. वर्तमान विंशोत्तरी दशा:**\n'
        'महादशा **${k.mahadasha}**, अंतर्दशा **${k.antardasha}**।\n\n'
        '**४. शास्त्रीय सात्विक उपाय:**\n'
        '• दशा शांति: $remedy\n'
        '• इष्टदेव / कुलदेवता का नित्य स्मरण करें।\n'
        '• शनिवार-मंगलवार को अन्नदान या सेवा करें।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'कुंडली चक्र में भाव और ग्रह देखें।',
      reasons: ['लग्न ${k.lagnaRashi}, चंद्र ${k.moonRashi}', 'दशा ${k.mahadasha}/${k.antardasha}'],
    );
  }

  UmaVidvanReply _career(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(
        text: _wrap('करियर का विचार **दशम भाव**, दशमेश, शनि और सूर्य से होता है। \u0915ुंडली अध्याय में जन्म पत्रिका लोड करें।\n\n$_shlokaSurya'),
        action: 'कुंडली बनाएँ।',
      );
    }
    final tenth = k.planets.where((p) => p.house == 10).toList();
    final sun = _find(k, 'सूर्य');
    final sat = _find(k, 'शनि');
    final tenthText = tenth.isEmpty
        ? 'दशम भाव रिक्त है — दशमेश प्रधान।'
        : 'दशम भाव में ${tenth.map((p) => '${p.planet} (${p.rashi})').join(', ')} स्थित हैं।';
    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी — करियर:**\n\n• $tenthText\n'
        '• सूर्य: ${sun?.rashi ?? '—'} / भाव ${sun?.house ?? '—'}। शनि: ${sat?.rashi ?? '—'} / भाव ${sat?.house ?? '—'}।\n'
        '• दशा **${k.mahadasha}–${k.antardasha}**।\n\n'
        'कौशल निखारें, टकराव से बचें। शुभ मुहूर्त में आवेदन करें।\n\n$_shlokaSurya',
      ),
      action: 'दशम भाव कुंडली में देखें।',
    );
  }

  UmaVidvanReply _marriage(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(
        text: _wrap('विवाह का विचार सप्तम भाव, सप्तमेश, शुक्र और चंद्र से होता है। कुंडली लोड करें तब मैं भाव और दोष बताऊँगी।\n\n$_shlokaVishnu'),
        action: 'कुंडली या मिलान अध्याय खोलें।',
      );
    }
    final seventh = k.planets.where((p) => p.house == 7).toList();
    final venus = _find(k, 'शुक्र');
    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी — विवाह:**\n\n'
        '• सप्तम भाव: ${seventh.isEmpty ? 'रिक्त — सप्तमेश प्रधान' : seventh.map((p) => p.planet).join(', ')}।\n'
        '• शुक्र: ${venus?.rashi ?? '—'} / भाव ${venus?.house ?? '—'}।\n'
        '• ${_manglikLine(k)}\n'
        '• दशा ${k.mahadasha}/${k.antardasha}।\n\n$_shlokaVishnu',
      ),
      action: 'कुंडली मिलान देखें।',
    );
  }

  UmaVidvanReply _wealth(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(text: _wrap('धन का विचार द्वितीय और एकादश भाव से होता है। कुंडली लोड करें।\n\n$_shlokaLakshmi'), action: 'कुंडली बनाएँ।');
    }
    final second = k.planets.where((p) => p.house == 2).map((p) => p.planet).join(', ');
    final eleventh = k.planets.where((p) => p.house == 11).map((p) => p.planet).join(', ');
    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी — धन योग:**\n\n'
        '• द्वितीय भाव: ${second.isEmpty ? 'शुभ दृष्टि / स्वामी प्रधान' : second}।\n'
        '• एकादश भाव: ${eleventh.isEmpty ? 'कर्म अनुसार फल' : eleventh}।\n'
        '• दशा **${k.mahadasha}** में व्यय पर संयम रखें।\n\n$_shlokaLakshmi',
      ),
    );
  }

  UmaVidvanReply _shani(KundaliData? k, UmaPanchangSnap? p) {
    final moon = k?.moonRashi ?? '';
    final sat = k == null ? null : _find(k, 'शनि');
    return UmaVidvanReply(
      text: _wrap(
        '**शनि व साढ़ेसाती:**\n'
        '${moon.isEmpty ? '' : 'चंद्र राशि **$moon** है।\n'}'
        '${sat == null ? '' : 'शनि ${sat.rashi} राशि, भाव ${sat.house} में हैं।\n'}'
        'शनि न्याय और कर्मफल के देवता हैं। साढ़ेसाती भय नहीं — अनुशासन की पाठशाला है।\n\n'
        '**शनि शांति:** शनिवार पीपल पर सरसों तेल का दीप, ॐ प्रां प्रीं प्रौं सः शनैश्चराय नमः का १०२ जप, काले तिल का दान, हनुमान चालीसा।\n\n$_shlokaShani',
      ),
      action: 'कुंडली में शनि देखें।',
    );
  }

  UmaVidvanReply _health(KundaliData? k) {
    final lagna = k == null ? '' : 'लग्न ${k.lagnaRashi}, सूर्य ${k.sunRashi}।\n';
    return UmaVidvanReply(
      text: _wrap(
        '**स्वास्थ्य:**\n$lagna'
        'आरोग्य लग्न, लग्नेश और सूर्य से देखा जाता है।\n\n'
        'महामृत्युंजय ११ या २१ बार, प्रातः ताम्र-जल, सोमवार शिवलिंग पर जल-बेलपत्र, सात्विक भोजन।\n\n$_shlokaMrityunjaya',
      ),
    );
  }

  UmaVidvanReply _panchangKaal(UmaPanchangSnap? p, {required String focus}) {
    if (p == null) {
      return UmaVidvanReply(text: _wrap('आज का पंचांग अभी स्थान से जुड़ रहा है। पंचांग पन्ना खोलें।'));
    }
    final body = StringBuffer()
      ..writeln('**आज का पंचांग — ${p.place}**')
      ..writeln('• वार: ${p.weekday} | ${p.paksha} ${p.tithi}')
      ..writeln('• नक्षत्र: ${p.nakshatra} | योग: ${p.yoga} | करण: ${p.karana}')
      ..writeln('• सूर्योदय ${p.sunrise} | सूर्यास्त ${p.sunset}')
      ..writeln('• ब्रह्म मुहूर्त: ${p.brahmaMuhurat}')
      ..writeln('• राहु काल: ${p.rahuKaal}')
      ..writeln('• यमगण्ड: ${p.yamaganda} | गुलिक: ${p.gulika}')
      ..writeln('• शुभ चौघड़िया: ${p.shubhChoghadiya}')
      ..writeln(p.currentChoghadiya.isEmpty ? '' : '• ${p.currentChoghadiya}');
    if (focus == 'rahu') {
      body.writeln('\nराहुकाल, यमगण्ड व गुलिक में नया शुभ कार्य आरंभ न करें।');
    } else if (focus == 'choghadiya') {
      body.writeln('\nअमृत, शुभ और लाभ चौघड़िया श्रेष्ठ हैं।');
    }
    body.writeln('\n$_shlokaGanesha');
    return UmaVidvanReply(
      text: _wrap(body.toString()),
      action: 'पंचांग पन्ना खोलें।',
      reasons: ['स्थान ${p.place}', 'तिथि ${p.tithi}', 'राहु ${p.rahuKaal}'],
    );
  }

  UmaVidvanReply _travel(UmaPanchangSnap? p) {
    final dir = p?.dishaShool ?? 'आज की वर्जित दिशा';
    return UmaVidvanReply(
      text: _wrap(
        'आज ${p?.weekday ?? ''} होने से **$dir** दिशा में दिशाशूल है।\n\n'
        'इस दिशा से नई यात्रा आरंभ न करें।\n\n'
        '${p == null ? '' : 'राहु काल: ${p.rahuKaal}\nशुभ चौघड़िया: ${p.shubhChoghadiya}\n\n'}'
        '$_shlokaVishnu',
      ),
      action: 'यात्रा कैलकुलेटर खोलें।',
    );
  }

  UmaVidvanReply _dasha(KundaliData? k) {
    if (k == null) return _needKundali('दशा फल');
    final remedy = dashaRemedies[k.mahadasha] ?? 'गायत्री जप करें।';
    return UmaVidvanReply(
      text: _wrap('**${k.name} जी की विंशोत्तरी दशा:**\nमहादशा **${k.mahadasha}**, अंतर्दशा **${k.antardasha}**। नक्षत्र ${k.nakshatra}, चरण ${k.charan}।\n\n$remedy\n\n$_shlokaGanesha'),
      action: 'दशा पन्ना खोलें।',
    );
  }

  UmaVidvanReply _graha(KundaliData? k) {
    if (k == null) return _needKundali('ग्रह स्थिति');
    final lines = k.planets.map((p) => '• ${p.planet}: ${p.rashi} ${p.degree.toStringAsFixed(1)}° — भाव ${p.house}${p.isRetrograde ? ' (वक्री)' : ''}').join('\n');
    return UmaVidvanReply(
      text: _wrap('**${k.name} — ग्रह स्थिति:**\nलग्न ${k.lagnaRashi} (${k.lagnaDegree.toStringAsFixed(1)}°)\n$lines\n\n$_shlokaGanesha'),
      action: 'कुंडली चक्र देखें।',
    );
  }

  UmaVidvanReply _manglik(KundaliData? k) {
    if (k == null) return _needKundali('मांगलिक विचार');
    return UmaVidvanReply(text: _wrap('${_manglikLine(k)}\n\nमिलान में दोनों कुंडलियाँ देखें। उपाय: मंगलवार हनुमान चालीसा।\n\n$_shlokaGanesha'));
  }

  UmaVidvanReply _remedy(KundaliData? k) {
    final lord = k?.mahadasha ?? 'सूर्य';
    final r = dashaRemedies[lord] ?? dashaRemedies['सूर्य']!;
    return UmaVidvanReply(
      text: _wrap('प्रिय यजमान, सात्विक उपाय भय नहीं — अनुशासन हैं।\n\n${k == null ? '' : 'आपकी दशा $lord है।\n'}• $r\n• नित्य गायत्री।\n• माता-पिता का आशीर्वाद।\n\n$_shlokaGanesha'),
    );
  }

  UmaVidvanReply _default(String query, KundaliData? k, UmaPanchangSnap? p) {
    final ctx = k == null
        ? 'सामान्य वैदिक विचार'
        : '${k.name} जी (लग्न ${k.lagnaRashi}, राशि ${k.moonRashi}, दशा ${k.mahadasha}/${k.antardasha})';
    final pan = p == null ? '' : '\nआज ${p.place} में ${p.weekday}, ${p.paksha} ${p.tithi}, नक्षत्र ${p.nakshatra}। राहु काल ${p.rahuKaal}।';
    return UmaVidvanReply(
      text: _wrap(
        'आपके प्रश्न *" $query "* पर मैंने वैदिक दृष्टि से विचार किया।\n\n'
        '• संदर्भ: $ctx$pan\n\n'
        'कार्य की सिद्धि तीन बातों से — शुभ काल, कुंडली का प्रारब्ध, और पुरुषार्थ।\n\n'
        'विवाह, करियर, धन, स्वास्थ्य, साढ़ेसाती, दशा या आज का पंचांग — विस्तार से पूछिए।\n\n$_shlokaGanesha',
      ),
    );
  }

  UmaVidvanReply _needKundali(String topic) {
    return UmaVidvanReply(
      text: _wrap('**$topic** के लिए जन्म कुंडली चाहिए।\n\nकुंडली अध्याय में जन्म तिथि, समय और स्थान भरें, अथवा सेव प्रोफाइल चुनें।\n\n$_shlokaGanesha'),
      action: 'कुंडली अध्याय खोलें।',
    );
  }

  String _yogas(KundaliData k) {
    final byHouse = <int, List<String>>{};
    for (final p in k.planets) {
      byHouse.putIfAbsent(p.house, () => []).add(p.planet);
    }
    final out = <String>[];
    final h1 = byHouse[1] ?? const [];
    if (h1.contains('गुरु') || h1.contains('शुक्र')) out.add('• लग्न में शुभ ग्रह — स्वभाव और शरीर को बल।');
    if ((byHouse[9] ?? []).contains('गुरु') || (byHouse[5] ?? []).contains('गुरु')) {
      out.add('• गुरु त्रिकोण में — धर्म-विद्या का संकेत।');
    }
    if ((byHouse[10] ?? []).isNotEmpty) out.add('• दशम भाव सग्रह — कर्म क्षेत्र सक्रिय।');
    if (out.isEmpty) out.add('• सामान्य शुभ ग्रह-स्थिति विद्यमान है।');
    return out.join('\n');
  }

  String _manglikLine(KundaliData k) {
    final mars = _find(k, 'मंगल');
    if (mars == null) return '• मांगलिक विचार: मंगल स्थिति उपलब्ध नहीं।';
    final bad = [1, 4, 7, 8, 12].contains(mars.house);
    return bad
        ? '• **मांगलिक विचार:** मंगल भाव ${mars.house} (${mars.rashi}) में है — शास्त्रीय संकेत।'
        : '• **मांगलिक विचार:** सामान्य संकेत नहीं मिला (मंगल भाव ${mars.house})।';
  }

  PlanetPosition? _find(KundaliData k, String name) {
    for (final p in k.planets) {
      if (p.planet == name) return p;
    }
    return null;
  }

  bool _has(String q, List<String> keys) => keys.any(q.contains);

  String _wrap(String body) => '॥ श्री गणेशाय नमः ॥\nआयुष्मान भव।\n\n$body\n\nकल्याणमस्तु।';

  static const String _shlokaGanesha =
      '**श्लोक:** वक्रतुण्ड महाकाय सूर्यकोटि समप्रभ। निर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥\n'
      '**भावार्थ:** गणेश जी सभी कार्यों से विघ्न हरें।';
  static const String _shlokaSurya =
      '**श्लोक:** ॐ घृणिः सूर्याय नमः।\n**भावार्थ:** सूर्यदेव तेज, यश और कर्म-बल दें।';
  static const String _shlokaVishnu =
      '**श्लोक:** ॐ नमो भगवते वासुदेवाय।\n**भावार्थ:** श्रीहरि पालन करें, सम्बन्ध और यात्रा निर्विघ्न हों।';
  static const String _shlokaLakshmi =
      '**श्लोक:** ॐ श्रीं ह्रीं क्लीं महालक्ष्म्यै नमः।\n**भावार्थ:** माँ लक्ष्मी स्थिर धन और विवेक दें।';
  static const String _shlokaShani =
      '**श्लोक:** नीलांजनसमाभासं रविपुत्रं यमाग्रजम्। छायामार्तण्डसम्भूतं तं नमामि शनैश्चरम्॥\n'
      '**भावार्थ:** शनिदेव को नमस्कार — कर्म शुद्ध हो तो फल भी शुद्ध।';
  static const String _shlokaMrityunjaya =
      '**श्लोक:** ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्॥\n'
      '**भावार्थ:** महामृत्युंजय रोग-भय से रक्षा और पुष्टि दें।';
}
