class UmaCommand {
  final String activity;
  final String normalizedQuestion;
  final UmaIntent intent;

  const UmaCommand(
    this.activity,
    this.normalizedQuestion, {
    this.intent = UmaIntent.activity,
  });
}

enum UmaIntent {
  activity,
  panchang,
  choghadiya,
  rahu,
  dishashool,
  sunriseSunset,
  explanation,
  dasha,
  sadesati,
  graha,
  kp,
  jaimini,
  festivals,
  kundali,
  saved,
  page,
  help,
}

class UmaCommandRouter {
  const UmaCommandRouter();

  UmaCommand route(String input) {
    final q = _normalize(input);
    if (q.isEmpty) return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.help);

    if (_has(q, ['इस पन्ने', 'इस पेज', 'page की', 'पन्ने की', 'इस अध्याय'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.page);
    }
    if (_has(q, ['राहु', 'rahu', 'राहुकाल', 'यमगंड', 'यमगण्ड', 'गुलिक'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.rahu);
    }
    if (_has(q, ['चौघड़िया', 'चौघड़िया', 'choghadiya', 'चोघड़िया'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.choghadiya);
    }
    if (_has(q, ['दिशाशूल', 'दिशा शूल', 'dishashool', 'किस दिशा', 'कौन सी दिशा'])) {
      return UmaCommand('यात्रा', input, intent: UmaIntent.dishashool);
    }
    if (_has(q, ['सूर्योदय', 'sunrise', 'सूर्यास्त', 'sunset', 'सूरज कब'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.sunriseSunset);
    }
    if (_has(q, ['त्योहार', 'festival', 'दिवाली', 'होली', 'नवरात्रि', 'एकादशी', 'व्रत'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.festivals);
    }
    if (_has(q, ['साढ़ेसाती', 'साढेसाती', 'sade sati', 'sadesati', 'ढैय्या'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.sadesati);
    }
    if (_has(q, ['महादशा', 'अंतरदशा', 'दशा', 'dasha', 'antardasha'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.dasha);
    }
    if (_has(q, ['kp', 'cusp', 'कृष्णमूर्ति', 'सब लॉर्ड', 'sub lord'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.kp);
    }
    if (_has(q, ['jaimini', 'जैमिनी', 'चर कारक', 'chara karaka'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.jaimini);
    }
    if (_has(q, ['मेरे ग्रह', 'ग्रह कहाँ', 'ग्रह कहा', 'planets', 'ग्रह स्थिति'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.graha);
    }
    if (_has(q, ['saved', 'सेव कुंडली', 'सेव प्रोफाइल', 'saved कुंडली'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.saved);
    }
    if (_has(q, ['कुंडली', 'kundali', 'लग्न', 'जन्म पत्रिका'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.kundali);
    }
    if (_has(q, ['पंचांग', 'panchang', 'तिथि', 'tithi', 'नक्षत्र', 'nakshatra', 'करण', 'पक्ष'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.panchang);
    }
    if (_has(q, ['क्या मतलब', 'समझाओ', 'explain', 'मतलब'])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.explanation);
    }
    if (_has(q, ['यात्रा', 'travel', 'जाना है', 'निकलना है'])) {
      return UmaCommand('यात्रा', input);
    }
    if (_has(q, ['विवाह', 'शादी', 'marriage', 'wedding'])) {
      return UmaCommand('विवाह', input);
    }
    if (_has(q, ['गृह प्रवेश', 'house warming', 'नए घर'])) {
      return UmaCommand('गृह प्रवेश', input);
    }
    if (_has(q, ['property', 'प्रॉपर्टी', 'भूमि', 'जमीन', 'प्लॉट'])) {
      return UmaCommand('भूमि / प्रॉपर्टी', input);
    }
    if (_has(q, ['गाड़ी', 'गाड़ी', 'वाहन', 'car', 'bike', 'स्कूटर'])) {
      return UmaCommand('वाहन खरीद', input);
    }
    if (_has(q, ['व्यापार', 'दुकान', 'business', 'धंधा'])) {
      return UmaCommand('नया व्यापार', input);
    }
    if (_has(q, ['नामकरण', 'नाम रखना', 'naming'])) {
      return UmaCommand('नामकरण', input);
    }
    if (_has(q, ['पढ़ाई', 'पढ़ाई', 'शिक्षा', 'exam', 'परीक्षा'])) {
      return UmaCommand('शिक्षा', input);
    }
    if (_has(q, ['मुहूर्त', 'muhurat', 'शुभ समय', 'अच्छा समय', 'कब करें'])) {
      return UmaCommand('सामान्य शुभ कार्य', input);
    }
    return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.help);
  }

  String _normalize(String value) {
    var q = value.toLowerCase().trim();
    q = q.replaceAll(RegExp(r'[!?.,;:]+'), ' ');
    q = q.replaceAll(RegExp(r'\s+'), ' ');
    return q;
  }

  bool _has(String q, List<String> words) => words.any(q.contains);
}
