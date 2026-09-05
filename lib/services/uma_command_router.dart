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
  help,
}

class UmaCommandRouter {
  const UmaCommandRouter();

  UmaCommand? route(String input) {
    final q = _normalize(input);
    if (q.isEmpty) return null;

    if (_has(q, [
      'राहु', 'rahu', 'राहुकाल', 'राहु काल', 'यमगंड', 'यमगण्ड',
      'गुलिक', 'गुलिक काल',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.rahu);
    }

    if (_has(q, [
      'चौघड़िया', 'चौघड़िया', 'choghadiya', 'choghariya', 'चोघड़िया',
      'दिन का चौघड़िया', 'रात का चौघड़िया',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.choghadiya);
    }

    if (_has(q, [
      'दिशाशूल', 'दिशा शूल', 'dishashool', 'disha shool',
      'किस दिशा', 'कौन सी दिशा', 'कौनसी दिशा',
    ])) {
      return UmaCommand('यात्रा', input, intent: UmaIntent.dishashool);
    }

    if (_has(q, [
      'सूर्योदय', 'sunrise', 'सूरज कब निकले', 'सूरज निकल',
      'सूर्यास्त', 'sunset', 'सूरज कब डूबे',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.sunriseSunset);
    }

    if (_has(q, [
      'पंचांग', 'panchang', 'तिथि', 'tithi', 'नक्षत्र', 'nakshatra',
      'योग', 'yog', 'करण', 'karan', 'पक्ष', 'paksha', 'वार', 'दिन कौन',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.panchang);
    }

    if (_has(q, [
      'क्या मतलब', 'मतलब क्या', 'क्या होता है', 'समझाओ', 'समझा दो',
      'explain', 'meaning', 'मतलब', 'क्यों', 'kyu', 'क्योंकि',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.explanation);
    }

    // Activity understanding with Hindi, Hinglish and natural phrases.
    if (_has(q, ['यात्रा', 'travel', 'jana hai', 'जाना है', 'निकलना है', 'जाना चाहता'])) {
      return UmaCommand('यात्रा', input);
    }
    if (_has(q, ['विवाह', 'शादी', 'शुभ शादी', 'marriage', 'wedding'])) {
      return UmaCommand('विवाह', input);
    }
    if (_has(q, ['गृह प्रवेश', 'house warming', 'house entry', 'नए घर में', 'घर में प्रवेश'])) {
      return UmaCommand('गृह प्रवेश', input);
    }
    if (_has(q, ['property', 'प्रॉपर्टी', 'भूमि', 'जमीन', 'प्लॉट', 'plot', 'मकान खरीद'])) {
      return UmaCommand('भूमि / प्रॉपर्टी', input);
    }
    if (_has(q, ['vehicle', 'गाड़ी', 'गाड़ी', 'वाहन', 'car', 'bike', 'स्कूटर', 'ट्रैक्टर'])) {
      return UmaCommand('वाहन खरीद', input);
    }
    if (_has(q, ['business', 'व्यापार', 'दुकान', 'business start', 'काम शुरू', 'धंधा'])) {
      return UmaCommand('नया व्यापार', input);
    }
    if (_has(q, ['नामकरण', 'नाम रखना', 'नाम रख', 'naming'])) {
      return UmaCommand('नामकरण', input);
    }
    if (_has(q, ['पढ़ाई', 'पढ़ाई', 'शिक्षा', 'education', 'study', 'स्कूल', 'परीक्षा', 'exam'])) {
      return UmaCommand('शिक्षा', input);
    }

    if (_has(q, [
      'शुभ', 'muhurat', 'मुहूर्त', 'काम', 'शुभ समय', 'अच्छा समय',
      'best time', 'good time', 'कब करें', 'कब करना',
    ])) {
      return UmaCommand('सामान्य शुभ कार्य', input);
    }

    // Don't reject a normal question just because it has no known keyword.
    // Let the screen's contextual fallback explain what Uma needs next.
    return UmaCommand('सामान्य शुभ कार्य', input, intent: UmaIntent.help);
  }

  String _normalize(String value) {
    var q = value.toLowerCase().trim();
    q = q.replaceAll(RegExp(r'[!?.,;:]+'), ' ');
    q = q.replaceAll(RegExp(r'\\s+'), ' ');
    return q;
  }

  bool _has(String q, List<String> words) => words.any(q.contains);
}
