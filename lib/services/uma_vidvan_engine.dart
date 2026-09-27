import '../models/kundali_model.dart';

/// Live panchang snapshot so Uma can speak today's numbers without
/// depending on remote servers.
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
  final String? actionType;

  const UmaVidvanReply({
    required this.text,
    this.action = 'विवाह, करियर, धन, स्वास्थ्य, साढ़ेसाती, दशा या आज का पंचांग पूछ सकते हैं।',
    this.reasons = const ['काशी-उज्जैन परंपरा का विद्वान् दैवज्ञ इंजन'],
    this.checks = const ['यह मार्गदर्शन शास्त्रोक्त संकेत है, भय नहीं।'],
    this.actionType,
  });
}

/// Advanced Vedic Astrological Intelligence Engine for Uma
/// Mirrors deep astrological rules, Sanskrit shlokas, and remedies.
class UmaVidvanEngine {
  const UmaVidvanEngine();

  static const String greeting =
      'नमस्ते प्रिय यजमान, मैं उमा हूँ — शक्ति पंचांग की विदुषी ज्योतिषाचार्य। काशी-उज्जैन की सनातन परंपरा से पंचांग, जन्म पत्रिका, दशा, गोचर और सात्विक उपायों पर मार्गदर्शन के लिए उपस्थित हूँ। बोलिए, आज क्या विचार करना है?';

  static const Map<String, String> dashaRemedies = {
    'सूर्य':
        'नित्य प्रातः तांबे के लोटे से सूर्यदेव को अर्घ्य दें और ॐ सूर्याय नमः अथवा आदित्य हृदय स्तोत्र का पाठ करें।',
    'चंद्र':
        'सोमवार को शिवलिंग पर कच्चा दूध व जल अर्पित करें और ॐ नमः शिवाय का १०८ बार मानसिक जप करें।',
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

    // 1. FULL KUNDALI READING
    if (_has(q, [
      'सम्पूर्ण',
      'पूरा फलादेश',
      'फुल रीडिंग',
      'कुंडली चेक',
      'कुंडली देखो',
      'kundali check',
      'पूरी कुंडली',
      'कुंडली बता',
      'जन्म पत्रिका',
      'पत्रिका देखो',
    ])) {
      return _kundaliReading(kundali);
    }

    // 2. CAREER / JOB / BUSINESS
    if (_has(q, [
      'करियर',
      'नौकरी',
      'जॉब',
      'व्यापार',
      'बिज़्नेस',
      'बिजनेस',
      'career',
      'job',
      'business',
      'प्रमोशन',
      'आजीविका',
      'काम कैसा',
      'नौकरी कब',
    ])) {
      return _career(kundali);
    }

    // 3. MARRIAGE / VIVAH / MANGLIK / MILAN
    if (_has(q, [
      'विवाह',
      'शादी',
      'marriage',
      'wedding',
      'दाम्पत्य',
      'सगाई',
      'जीवनसाथी',
      'सप्तम भाव',
      'कब होगी शादी',
      'शादी कब',
    ])) {
      return _marriage(kundali);
    }

    // 4. MANGLIK DOSHA
    if (_has(q, ['मांगलिक', 'मंगल दोष', 'manglik', 'mangal'])) {
      return _manglik(kundali);
    }

    // 5. KUNDALI MILAN (36 GUNA)
    if (_has(q, ['मिलान', 'गुण मिलान', 'अष्टकूट', '36 गुण', '३६ गुण', 'matching', 'milan'])) {
      return _kundaliMilan(kundali);
    }

    // 6. WEALTH / FINANCE / MONEY
    if (_has(q, [
      'धन',
      'पैसा',
      'आय',
      'कर्ज',
      'संपत्ति',
      'wealth',
      'money',
      'finance',
      'लाभ',
      'लक्ष्मी',
      'रुपया',
      'आर्थिक',
    ])) {
      return _wealth(kundali);
    }

    // 7. SHANI / SADE SATI / DHAIYYA
    if (_has(q, [
      'शनि',
      'साढ़ेसाती',
      'साढेसाती',
      'ढैय्या',
      'sade sati',
      'sadesati',
      'saturn',
      'शनिदेव',
    ])) {
      return _shani(kundali, panchang);
    }

    // 8. HEALTH / ROG NIVARAN
    if (_has(q, [
      'स्वास्थ्य',
      'बीमारी',
      'रोग',
      'health',
      'तबीयत',
      'आरोग्य',
      'रोग निवारण',
      'दवा',
    ])) {
      return _health(kundali);
    }

    // 9. RAHU KAAL & INAUSPICIOUS TIMES
    if (_has(q, ['राहु काल', 'राहुकाल', 'राहु', 'यमगंड', 'यमगण्ड', 'गुलिक', 'rahu'])) {
      return _rahu(panchang);
    }

    // 10. CHOGHADIYA
    if (_has(q, ['चौघड़िया', 'चौघडिया', 'choghadiya', 'चोघड़िया', 'शुभ समय'])) {
      return _choghadiya(panchang);
    }

    // 11. TRAVEL & DISHASHOOL
    if (_has(q, ['यात्रा', 'दिशाशूल', 'दिशा शूल', 'travel', 'निकलना', 'सफर'])) {
      return _yatra(panchang);
    }

    // 12. PANCHANG / TITHI / NAKSHATRA
    if (_has(q, [
      'पंचांग',
      'panchang',
      'तिथि',
      'नक्षत्र',
      'आज का पंचांग',
      'आज की तिथि',
      'आज क्या है',
      'सूर्योदय',
      'सूर्यास्त',
    ])) {
      return _panchang(panchang);
    }

    // 13. DASHA / VIMSHOTTARI
    if (_has(q, ['महादशा', 'अंतरदशा', 'अन्तर्दशा', 'दशा', 'dasha', 'antardasha'])) {
      return _dasha(kundali);
    }

    // 14. PLANETS & HOUSES
    if (_has(q, ['ग्रह कहाँ', 'ग्रह कहा', 'मेरे ग्रह', 'planets', 'ग्रह स्थिति', 'लग्न', 'भाव'])) {
      return _graha(kundali);
    }

    // 15. FESTIVALS & VRAT
    if (_has(q, ['त्योहार', 'त्यौहार', 'पर्व', 'व्रत', 'एकादशी', 'पूर्णिमा', 'अमावस्या', 'festivals'])) {
      return _festivals(panchang);
    }

    // 16. REMEDIES / UPAY
    if (_has(q, ['उपाय', 'remedy', 'remedies', 'क्या करूँ', 'क्या करूं', 'निवारण', 'शांति'])) {
      return _remedy(kundali);
    }

    // 17. PAGE CONTEXT
    if (pageContext != null && _has(q, ['इस पन्ने', 'इस पेज', 'पन्ने की', 'इस अध्याय'])) {
      return UmaVidvanReply(
        text: _wrap(
          'प्रिय यजमान, आप अभी **$pageContext** अध्याय में हैं।\n\n'
          'यह ग्रंथ का प्रामाणिक पृष्ठ है। आप मुझसे पंचांग, जन्म पत्रिका, गोचर, दशा, मुहूर्त, यात्रा अथवा सात्विक उपायों के संबंध में कोई भी शास्त्रीय प्रश्न पूछ सकते हैं।',
        ),
        action: '$pageContext से जुड़ा प्रश्न पूछें।',
      );
    }

    return _default(query, kundali, panchang);
  }

  // --- TOPIC IMPLEMENTATIONS ---

  UmaVidvanReply _kundaliReading(KundaliData? k) {
    if (k == null) return _needKundali('सम्पूर्ण फलादेश');
    final yogas = _yogas(k);
    final dosha = _manglikLine(k);
    final remedy = dashaRemedies[k.mahadasha] ?? 'नित्य गायत्री मंत्र का १०८ बार जप करें।';

    return UmaVidvanReply(
      text: _wrap(
        '**जातक:** ${k.name} | **लग्न:** ${k.lagnaRashi} (${k.lagnaDegree.toStringAsFixed(1)}°) | '
        '**चंद्र राशि:** ${k.moonRashi} (${k.nakshatra} नक्षत्र, चरण ${k.charan})\n'
        '**सूर्य राशि:** ${k.sunRashi}\n\n'
        '**१. व्यक्तित्व व लग्न बल:**\n'
        'आपका लग्न ${k.lagnaRashi} है। यह लग्न आपको दृढ़ संकल्प, आत्मबल, वैचारिक स्पष्टता एवं स्वाभिमान प्रदान करता है।\n\n'
        '**२. प्रमुख ग्रहीय योग:**\n$yogas\n$dosha\n\n'
        '**३. वर्तमान विंशोत्तरी दशा:**\n'
        'वर्तमान में आपकी **${k.mahadasha}** की महादशा में **${k.antardasha}** की अंतर्दशा प्रभावी है। यह कालखंड आपके कर्मक्षेत्र और जीवनशैली में महत्वपूर्ण परिवर्तन का संकेत देता है।\n\n'
        '**४. शास्त्रीय सात्विक उपाय (Remedies):**\n'
        '• **दशा शांति:** $remedy\n'
        '• **इष्टदेव आराधना:** अपने कुलदेवता व इष्टदेव का नित्य प्रातः स्मरण करें।\n'
        '• **दान:** शनिवार व मंगलवार को असहायों की सेवा अथवा अन्नदान करें।\n'
        '• **सात्विक आचरण:** प्रातः सूर्य नमस्कार करें और संध्या समय घर में कर्पूर अथवा घी का दीप प्रज्वलित करें।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'सम्पूर्ण कुंडली चक्र विस्तार से देखें',
      actionType: 'open_kundali',
      reasons: ['लग्न ${k.lagnaRashi}, चंद्र ${k.moonRashi}', 'दशा ${k.mahadasha}/${k.antardasha}'],
      checks: ['१२ भावों और नवग्रहों की सूक्ष्म स्थिति जांची गई है।'],
    );
  }

  UmaVidvanReply _career(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(
        text: _wrap(
          'वैदिक ज्योतिष में करियर और आजीविका का विचार जन्म पत्रिका के **दशम भाव (कर्म भाव)**, दशमेश, सूर्यदेव (प्रतिष्ठा व पद) तथा शनिदेव (कर्मकारक) से किया जाता है।\n\n'
          'सटीक नौकरी या व्यापार विश्लेषण हेतु कृपया कुंडली अध्याय में अपनी जन्म पत्रिका लोड करें।\n\n'
          '$_shlokaSurya',
        ),
        action: 'जन्म कुंडली बनाएँ',
        actionType: 'open_kundali',
      );
    }
    final tenth = k.planets.where((p) => p.house == 10).toList();
    final sun = _find(k, 'सूर्य');
    final sat = _find(k, 'शनि');
    final tenthText = tenth.isEmpty
        ? 'दशम भाव रिक्त है — अतः दशमेश ग्रह की स्थिति व दृष्टि का मुख्य प्रभाव रहेगा।'
        : 'दशम भाव में ${tenth.map((p) => '${p.planet} (${p.rashi} राशि)').join(', ')} स्थित हैं।';

    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी की कुंडली में करियर व आजीविका विश्लेषण:**\n\n'
        '• **दशम भाव (कर्म क्षेत्र):** $tenthText\n'
        '• **सूर्य व शनि स्थिति:** सूर्य (${sun?.rashi ?? '—'}, भाव ${sun?.house ?? '—'}) एवं कर्मकारक शनि (${sat?.rashi ?? '—'}, भाव ${sat?.house ?? '—'}) विराजमान हैं।\n'
        '• **दशा प्रभाव:** वर्तमान **${k.mahadasha}–${k.antardasha}** काल में पद-प्रतिष्ठा में वृद्धि तथा उत्तरदायित्व मिलने के शास्त्रीय योग हैं।\n\n'
        '**मार्गदर्शन व भविष्यकथन:**\n'
        'धैर्यपूर्वक अपने कौशल को निखारें। कार्यस्थल पर अनावश्यक अहंकार अथवा टकराव से बचें। यदि नौकरी में पदोन्नति या व्यापार में विस्तार चाहते हैं तो शुभ मुहूर्त में कदम बढ़ाएं।\n\n'
        '**करियर उन्नति के सात्विक उपाय:**\n'
        '१. नित्य प्रातः तांबे के पात्र से सूर्यदेव को जल अर्पित करें (ॐ घृणिः सूर्याय नमः)।\n'
        '२. शनिवार को संध्या समय पीपल के पास सरसों के तेल का दीपक जलाएं।\n'
        '३. श्री आदित्य हृदय स्तोत्र या विष्णु सहस्रनाम का पाठ आत्मविश्वास और कार्य-सिद्धि प्रदान करेगा।\n\n'
        '$_shlokaSurya',
      ),
      action: 'दशम भाव व ग्रह चक्र देखें',
      actionType: 'open_kundali',
      reasons: ['दशम भाव विचार', 'सूर्य व शनि कर्मकारक स्थिति'],
      checks: ['शुभ मुहूर्त में कार्य आरंभ करें।'],
    );
  }

  UmaVidvanReply _marriage(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(
        text: _wrap(
          'वैदिक शास्त्र में विवाह का विचार जन्म कुंडली के **सप्तम भाव (जाया भाव)**, सप्तमेश, गुरु (कन्या हेतु पति कारक) तथा शुक्र (वर हेतु पत्नी कारक) के बल से किया जाता है।\n\n'
          'विवाह योग, दांपत्य सुख व मांगलिक विचार हेतु कृपया अपनी जन्म कुंडली लोड करें।\n\n'
          '$_shlokaVishnu',
        ),
        action: 'जन्म कुंडली बनाएँ',
        actionType: 'open_kundali',
      );
    }
    final seventh = k.planets.where((p) => p.house == 7).toList();
    final venus = _find(k, 'शुक्र');
    final jup = _find(k, 'गुरु');

    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी की कुंडली में विवाह व दांपत्य विचार:**\n\n'
        '• **सप्तम भाव स्थिति:** ${seventh.isEmpty ? 'सप्तम भाव शुभ दृष्ट है — सप्तमेश स्वामी का प्रभाव प्रधान है।' : 'सप्तम भाव में ' + seventh.map((p) => '${p.planet} (${p.rashi})').join(', ') + ' स्थित हैं।'}\n'
        '• **कारक बल:** गुरु (${jup?.rashi ?? '—'}, भाव ${jup?.house ?? '—'}) तथा शुक्र (${venus?.rashi ?? '—'}, भाव ${venus?.house ?? '—'}) हैं।\n'
        '• ${_manglikLine(k)}\n'
        '• **दशा प्रभाव:** वर्तमान दशा **${k.mahadasha}/${k.antardasha}** विवाह संबंधी वार्ताओं और संबंधों को गति प्रदान कर सकती है।\n\n'
        '**दांपत्य सुख के सिद्ध उपाय:**\n'
        '१. प्रत्येक शुक्रवार को माँ लक्ष्मी अथवा माता पार्वती को लाल पुष्प व इत्र अर्पित करें।\n'
        '२. बृहस्पतिवार को भगवान विष्णु के समक्ष घी का दीपक जलाएं और ॐ नमो भगवते वासुदेवाय जपें।\n'
        '३. यदि मांगलिक प्रभाव हो तो नित्य श्री हनुमान चालीसा व मंगल कवच का पाठ करें।\n\n'
        '$_shlokaVishnu',
      ),
      action: 'कुंडली मिलान व सप्तम भाव देखें',
      actionType: 'open_milan',
      reasons: ['सप्तम भाव व कारक ग्रह विश्लेषण', 'मांगलिक स्थिति परीक्षण'],
    );
  }

  UmaVidvanReply _manglik(KundaliData? k) {
    if (k == null) return _needKundali('मांगलिक विचार');
    return UmaVidvanReply(
      text: _wrap(
        '${_manglikLine(k)}\n\n'
        '**शास्त्रीय विचार:**\n'
        'मंगल यदि लग्न से १, ४, ७, ८ या १२वें भाव में हो तो मांगलिक योग बनता है। २८ वर्ष की आयु के बाद मंगल का उग्र प्रभाव स्वतः शांत होने लगता है।\n\n'
        '**मंगल शांति के सात्विक उपाय:**\n'
        '• नित्य प्रातः श्री हनुमान चालीसा का पाठ करें।\n'
        '• मंगलवार को बंदरों या गाय को गुड़ और भुने चने खिलाएं।\n'
        '• विवाह के समय अष्टकूट गुण मिलान में नाड़ी व भकूट का विशेष ध्यान रखें।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'मंगल की भाव स्थिति देखें',
      actionType: 'open_kundali',
    );
  }

  UmaVidvanReply _kundaliMilan(KundaliData? k) {
    return UmaVidvanReply(
      text: _wrap(
        '**अष्टकूट ३६ गुण मिलान विचार:**\n\n'
        'वैदिक परंपरा में विवाह मिलान हेतु आठ कूटों का विचार किया जाता है:\n'
        '१. वर्ण (१ अंक) • २. वश्य (२ अंक) • ३. तारा (३ अंक) • ४. योनि (४ अंक)\n'
        '५. ग्रहमैत्री (५ अंक) • ६. गण (६ अंक) • ७. भकूट (७ अंक) • ८. नाड़ी (८ अंक)\n\n'
        'कुल ३६ गुणों में से १८ से अधिक गुण मिलने पर मिलान उत्तम माना जाता है। नाड़ी दोष परिहार का सूक्ष्म विचार अनिवार्य है।\n\n'
        '$_shlokaVishnu',
      ),
      action: 'कुंडली मिलान मॉड्यूल खोलें',
      actionType: 'open_milan',
    );
  }

  UmaVidvanReply _wealth(KundaliData? k) {
    if (k == null) {
      return UmaVidvanReply(
        text: _wrap(
          'वैदिक ज्योतिष में धन व वैभव का विचार **द्वितीय भाव (धन संग्रह)** और **एकादश भाव (आय व लाभ)** तथा गुरु-शुक्र की दृष्टि से होता है।\n\n'
          'सटीक गणना हेतु कुंडली अध्याय में जन्म विवरण दर्ज करें।\n\n'
          '$_shlokaLakshmi',
        ),
        action: 'जन्म कुंडली बनाएँ',
        actionType: 'open_kundali',
      );
    }
    final second = k.planets.where((p) => p.house == 2).map((p) => p.planet).join(', ');
    final eleventh = k.planets.where((p) => p.house == 11).map((p) => p.planet).join(', ');

    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी की कुंडली में धन व आर्थिक योग:**\n\n'
        '• **द्वितीय भाव (धन संचय):** ${second.isEmpty ? 'शुभ दृष्टि / स्वामी ग्रह प्रधान' : second} स्थित हैं।\n'
        '• **एकादश भाव (आय व लाभ):** ${eleventh.isEmpty ? 'कर्म अनुसार फल' : eleventh} स्थित हैं।\n'
        '• **दशा प्रभाव:** वर्तमान **${k.mahadasha}** की महादशा में धन के अपव्यय पर नियंत्रण रखना और निवेश में विवेक से काम लेना लाभप्रद रहेगा।\n\n'
        '**धन वृद्धि व समृद्धि के वैदिक उपाय:**\n'
        '१. शुक्रवार को श्री कनकधारा स्तोत्र अथवा श्री सूक्त का पाठ करें।\n'
        '२. घर की उत्तर दिशा (कुबेर स्थान) को सदैव स्वच्छ, प्रकाशमान व व्यवस्थित रखें।\n'
        '३. बुधवार को गाय को हरी घास या पालक खिलाएं, इससे बुध ग्रह की अनुकूलता से व्यापारिक लाभ बढ़ता है।\n\n'
        '$_shlokaLakshmi',
      ),
      action: 'द्वितीय व एकादश भाव चक्र देखें',
      actionType: 'open_kundali',
      reasons: ['द्वितीय भाव (संचित धन)', 'एकादश भाव (लाभ व आय)'],
    );
  }

  UmaVidvanReply _shani(KundaliData? k, UmaPanchangSnap? p) {
    final moon = k?.moonRashi ?? (p?.weekday ?? 'कर्क');
    final sat = k == null ? null : _find(k, 'शनि');

    return UmaVidvanReply(
      text: _wrap(
        '**शनि व साढ़ेसाती विचार:**\n'
        'जातक की चंद्र राशि **$moon** है।\n'
        '${sat == null ? '' : 'आपकी कुंडली में शनि ${sat.rashi} राशि, भाव ${sat.house} में विराजमान हैं।\n'}'
        'शनिदेव न्याय के देवता और कर्मफलदाता हैं। साढ़ेसाती अथवा ढैय्या व्यक्ति को अनुशासित, विनम्र और परिश्रमी बनाने के लिए आती है, भयभीत होने की आवश्यकता नहीं है।\n\n'
        '**शनि शांति के सिद्ध सात्विक उपाय:**\n'
        '१. प्रत्येक शनिवार को सूर्यास्त के बाद पीपल के वृक्ष के नीचे सरसों के तेल का दीपक जलाएं।\n'
        '२. ॐ प्रां प्रीं प्रौं सः शनैश्चराय नमः मंत्र का १०८ बार रुद्राक्ष माला से जप करें।\n'
        '३. शनिवार को काले तिल, उड़द की दाल अथवा कंबल का किसी जरूरतमंद को दान करें।\n'
        '४. प्रतिदिन हनुमान चालीसा का पाठ करें — श्री हनुमान जी के भक्तों पर शनिदेव सदा कृपालु रहते हैं।\n\n'
        '$_shlokaShani',
      ),
      action: 'शनि साढ़े साती का पूर्ण चक्र देखें',
      actionType: 'open_sadesati',
      reasons: ['शनि गोचर व चंद्र राशि संबंध', 'कर्मफल शुद्धि विचार'],
    );
  }

  UmaVidvanReply _health(KundaliData? k) {
    final lagna = k == null ? '' : '• जातक लग्न: ${k.lagnaRashi}, सूर्य राशि: ${k.sunRashi}।\n';

    return UmaVidvanReply(
      text: _wrap(
        '**स्वास्थ्य व आरोग्य विचार:**\n$lagna'
        'आरोग्य का विचार लग्न (तनु भाव), लग्नेश और सूर्यदेव (आत्मकारक व जीवनी शक्ति) से किया जाता है। रोग मुक्ति हेतु षष्ठ भाव का परिहार आवश्यक है।\n\n'
        '**स्वास्थ्य लाभ हेतु शास्त्रोक्त उपाय:**\n'
        '१. नित्य भगवान शिव का स्मरण करते हुए महामृत्युंजय मंत्र का ११ या २१ बार जप करें:\n'
        '*"ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्॥"*\n'
        '२. प्रातः सूर्योदय के समय तांबे के पात्र से जल ग्रहण करें।\n'
        '३. सोमवार को शिवलिंग पर जल व बेलपत्र अर्पित करें।\n'
        '४. सात्विक भोजन ग्रहण करें और तनाव से मुक्ति हेतु प्राणायाम व ध्यान का अभ्यास करें।\n\n'
        '$_shlokaMrityunjaya',
      ),
      action: 'लग्न व षष्ठ भाव स्थिति देखें',
      actionType: 'open_kundali',
      reasons: ['लग्न बल व सूर्य आत्मकारक स्थिति'],
    );
  }

  UmaVidvanReply _rahu(UmaPanchangSnap? p) {
    final r = p?.rahuKaal ?? 'प्रभावी';
    final y = p?.yamaganda ?? '—';
    final g = p?.gulika ?? '—';

    return UmaVidvanReply(
      text: _wrap(
        '**आज के अशुभ कालखंड (राहुकाल विचार):**\n\n'
        '• **राहु काल:** $r (इस समय नया कार्य प्रारंभ न करें)\n'
        '• **यमगण्ड काल:** $y\n'
        '• **गुलिक काल:** $g\n\n'
        '**शास्त्र निर्देश:**\n'
        'राहु काल में यात्रा, अनुबंध, गृहप्रवेश, नया व्यापार अथवा धन का लेन-देन टालना चाहिए। इस काल में केवल दैनिक नित्यकर्म अथवा ईश-आराधना करें।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'शुभ मुहूर्त व चौघड़िया चक्र देखें',
      actionType: 'open_muhurat',
      reasons: ['दैनिक राहुकाल खण्ड गणना'],
      checks: ['राहुकाल में शुभ कार्य आरंभ न करें।'],
    );
  }

  UmaVidvanReply _choghadiya(UmaPanchangSnap? p) {
    if (p == null) {
      return UmaVidvanReply(
        text: _wrap('चौघड़िया गणना तैयार हो रही है। कृपया चौघड़िया तालिका खोलें।'),
        action: 'चौघड़िया तालिका देखें',
        actionType: 'open_choghadiya',
      );
    }
    return UmaVidvanReply(
      text: _wrap(
        '**आज का चौघड़िया चक्र (${p.place}):**\n\n'
        '• **${p.currentChoghadiya}**\n'
        '• **शुभ चौघड़िया:** ${p.shubhChoghadiya}\n'
        '• **राहु काल:** ${p.rahuKaal}\n\n'
        '**मार्गदर्शन:**\n'
        'अमृत, शुभ और लाभ चौघड़िया किसी भी नए कार्य, यात्रा अथवा पूजन हेतु सर्वश्रेष्ठ हैं। उद्वेग, काल और रोग चौघड़िया में नए कार्य टालें। चर चौघड़िया यात्रा हेतु अनुकूल है।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'सम्पूर्ण चौघड़िया तालिका देखें',
      actionType: 'open_choghadiya',
      reasons: ['सूर्य समय अनुसार अष्टम भाग विभाजन'],
    );
  }

  UmaVidvanReply _yatra(UmaPanchangSnap? p) {
    final d = p?.dishaShool ?? 'उत्तर';
    return UmaVidvanReply(
      text: _wrap(
        '**यात्रा व दिशाशूल विचार:**\n\n'
        'आज **$d दिशा** में दिशाशूल है।\n\n'
        '**शास्त्र निर्देश:**\n'
        'इस दिशा में नई यात्रा प्रारंभ करने से बचें।\n\n'
        '**सात्विक परिहार (Remedy before travel):**\n'
        'अत्यावश्यक होने पर प्रस्थान से पूर्व थोड़ा सा दही अथवा मीठा जल/गुड़ ग्रहण करें। इसके बाद पूर्व दिशा में पाँच पग चलकर यात्रा प्रारंभ करें, यात्रा निर्विघ्न और शुभ होगी।\n\n'
        '${p == null ? '' : 'राहु काल: ${p.rahuKaal}\n'}'
        '$_shlokaVishnu',
      ),
      action: 'यात्रा व दिशाशूल कैलकुलेटर खोलें',
      actionType: 'open_yatra',
      reasons: ['वार आधारित दिशाशूल विचार'],
    );
  }

  UmaVidvanReply _panchang(UmaPanchangSnap? p) {
    if (p == null) {
      return UmaVidvanReply(
        text: _wrap('दैनिक पंचांग गणना की जा रही है।'),
        action: 'पंचांग विस्तार देखें',
        actionType: 'open_panchang',
      );
    }
    return UmaVidvanReply(
      text: _wrap(
        '**आज का दैनिक वैदिक पंचांग (${p.place}):**\n\n'
        '• **वार व तिथि:** ${p.weekday}, ${p.paksha} पक्ष, ${p.tithi} तिथि\n'
        '• **नक्षत्र:** ${p.nakshatra}\n'
        '• **योग व करण:** ${p.yoga} योग, ${p.karana} करण\n'
        '• **सूर्योदय-सूर्यास्त:** प्रातः ${p.sunrise} | सायं ${p.sunset}\n'
        '• **ब्रह्म मुहूर्त:** ${p.brahmaMuhurat}\n'
        '• **राहु काल:** ${p.rahuKaal}\n\n'
        '${p.currentChoghadiya}\n\n'
        '$_shlokaGanesha',
      ),
      action: 'सम्पूर्ण पंचांग विस्तार देखें',
      actionType: 'open_panchang',
      reasons: ['सूर्य-चंद्र कोणीय अंतर (१२° प्रति तिथि)'],
    );
  }

  UmaVidvanReply _dasha(KundaliData? k) {
    if (k == null) return _needKundali('दशा फल');
    final remedy = dashaRemedies[k.mahadasha] ?? 'गायत्री जप करें।';
    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी की विंशोत्तरी दशा:**\n\n'
        'वर्तमान में महादशा **${k.mahadasha}** में अंतर्दशा **${k.antardasha}** प्रभावी है।\n'
        'नक्षत्र: ${k.nakshatra}, चरण ${k.charan}।\n\n'
        '**दशा प्रभाव व फल:**\n'
        '${k.mahadasha} महादशा जातक के जीवन में नई दिशा, आंतरिक रूपांतरण और कर्मफल का विशेष कालखंड है।\n\n'
        '**दशा शांति उपाय:**\n'
        '$remedy\n\n'
        '$_shlokaGanesha',
      ),
      action: 'विंशोत्तरी दशा चक्र देखें',
      actionType: 'open_kundali',
      reasons: ['१२० वर्षीय विंशोत्तरी दशा चक्र'],
    );
  }

  UmaVidvanReply _graha(KundaliData? k) {
    if (k == null) return _needKundali('ग्रह स्थिति');
    final lines = k.planets.map((p) => '• ${p.planet}: ${p.rashi} राशि ${p.degree.toStringAsFixed(1)}° — भाव ${p.house}${p.isRetrograde ? ' (वक्री)' : ''}').join('\n');
    return UmaVidvanReply(
      text: _wrap(
        '**${k.name} जी — ग्रह स्थिति व भाव चक्र:**\n'
        '• लग्न: ${k.lagnaRashi} (${k.lagnaDegree.toStringAsFixed(1)}°)\n'
        '$lines\n\n'
        '$_shlokaGanesha',
      ),
      action: 'कुंडली चक्र विस्तार से देखें',
      actionType: 'open_kundali',
      reasons: ['चित्रापक्षीय / लाहिड़ी अयनांश गणना'],
    );
  }

  UmaVidvanReply _festivals(UmaPanchangSnap? p) {
    return UmaVidvanReply(
      text: _wrap(
        '**सनातन व्रत एवं त्योहार विचार:**\n\n'
        'शक्ति पंचांग में वर्ष भर के समस्त एकादशी, प्रदोष, पूर्णिमा, अमावस्या, संक्रांति, नवरात्रि, शिवरात्रि एवं प्रमुख हिन्दू पर्वों की सटीक सूर्योदयकालीन तिथि गणना उपलब्ध है।\n\n'
        'विस्तृत तिथि व पारण समय देखने हेतु व्रत व त्योहार अध्याय खोलें।\n\n'
        '$_shlokaVishnu',
      ),
      action: 'व्रत एवं त्योहार सूची खोलें',
      actionType: 'open_festivals',
    );
  }

  UmaVidvanReply _remedy(KundaliData? k) {
    final lord = k?.mahadasha ?? 'सूर्य';
    final r = dashaRemedies[lord] ?? dashaRemedies['सूर्य']!;
    return UmaVidvanReply(
      text: _wrap(
        'प्रिय यजमान, सनातन वैदिक उपाय भय का निवारण और आत्मिक अनुशासन हैं।\n\n'
        '${k == null ? '' : 'आपकी वर्तमान दशा स्वामी ग्रह: **$lord** है।\n'}'
        '• **दशा शांति:** $r\n'
        '• **नित्य उपासना:** प्रातः गायत्री मंत्र का १०८ बार जप।\n'
        '• **पितृ व मातृ चरण स्पर्श:** माता-पिता का आशीर्वाद समस्त अनिष्टों को हर लेता है।\n'
        '• **अन्न व जल सेवा:** गौ-माता, पक्षियों व असहायों की सेवा करें।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'कुंडली विस्तार देखें',
      actionType: 'open_kundali',
    );
  }

  UmaVidvanReply _default(String query, KundaliData? k, UmaPanchangSnap? p) {
    final ctx = k == null
        ? 'सामान्य वैदिक विचार'
        : '${k.name} जी (लग्न ${k.lagnaRashi}, चंद्र ${k.moonRashi}, दशा ${k.mahadasha}/${k.antardasha})';
    final pan = p == null ? '' : '\nआज ${p.place} में ${p.weekday}, ${p.paksha} ${p.tithi}, नक्षत्र ${p.nakshatra}। राहु काल ${p.rahuKaal}।';
    return UmaVidvanReply(
      text: _wrap(
        'आपके प्रश्न *" $query "* पर मैंने वैदिक दैवज्ञ दृष्टि से विचार किया है।\n\n'
        '• **संदर्भ:** $ctx$pan\n\n'
        '**शास्त्रीय सिद्धांत:**\n'
        'किसी भी कार्य की सिद्धि तीन बातों के समन्वय से होती है — शुभ काल (मुहूर्त), जातक का पूर्वार्जित प्रारब्ध (कुंडली ग्रह बल), और वर्तमान पुरुषार्थ।\n\n'
        'आप मुझसे विवाह, करियर, धन, स्वास्थ्य, साढ़ेसाती, मांगलिक विचार, दशा या आज के शुभ चौघड़िया के विषय में विस्तार से पूछ सकते हैं।\n\n'
        '$_shlokaGanesha',
      ),
      action: k != null ? 'कुंडली चक्र देखें' : 'दैनिक पंचांग देखें',
      actionType: k != null ? 'open_kundali' : 'open_panchang',
    );
  }

  UmaVidvanReply _needKundali(String topic) {
    return UmaVidvanReply(
      text: _wrap(
        '**$topic** के सटीक विश्लेषण हेतु जातक की जन्म पत्रिका आवश्यक है।\n\n'
        'कृपया कुंडली अध्याय में जाकर अपनी जन्म तिथि, समय और स्थान दर्ज करें, अथवा सहेजी गई प्रोफाइल चुनें। इसके पश्चात मैं सभी १२ भावों और ग्रहों का सूक्ष्म फलादेश करूँगी।\n\n'
        '$_shlokaGanesha',
      ),
      action: 'जन्म कुंडली बनाएँ',
      actionType: 'open_kundali',
    );
  }

  String _yogas(KundaliData k) {
    final byHouse = <int, List<String>>{};
    for (final p in k.planets) {
      byHouse.putIfAbsent(p.house, () => []).add(p.planet);
    }
    final out = <String>[];
    final h1 = byHouse[1] ?? const [];
    if (h1.contains('गुरु') || h1.contains('शुक्र')) out.add('• लग्न में शुभ ग्रह — सौम्य स्वभाव, आकर्षक व्यक्तित्व और दीर्घायु।');
    if ((byHouse[9] ?? []).contains('गुरु') || (byHouse[5] ?? []).contains('गुरु')) {
      out.add('• गुरु त्रिकोण में — उच्च विद्या, धर्मनिष्ठ आचरण एवं ईश्वरीय कृपा।');
    }
    if ((byHouse[10] ?? []).isNotEmpty) out.add('• दशम भाव में ग्रह उपस्थिति — कर्मठता, यश एवं आजीविका में प्रगति।');
    if (out.isEmpty) out.add('• कुंडली में सामान्य शुभ ग्रह-स्थिति विद्यमान है।');
    return out.join('\n');
  }

  String _manglikLine(KundaliData k) {
    final mars = _find(k, 'मंगल');
    if (mars == null) return '• **मांगलिक विचार:** मंगल स्थिति का विश्लेषण सामान्य है।';
    final bad = [1, 4, 7, 8, 12].contains(mars.house);
    return bad
        ? '• **मांगलिक विचार:** मंगल भाव ${mars.house} (${mars.rashi}) में स्थित होकर मांगलिक योग बना रहा है। विवाह के समय गुण मिलान में सावधानी आवश्यक है।'
        : '• **मांगलिक विचार:** जातक अमंगल (Non-Manglik) है — कोई मुख्य मांगलिक दोष नहीं है।';
  }

  PlanetPosition? _find(KundaliData k, String name) {
    for (final p in k.planets) {
      if (p.planet == name) return p;
    }
    return null;
  }

  bool _has(String q, List<String> keys) => keys.any(q.contains);

  String _wrap(String body) =>
      '॥ श्री गणेशाय नमः ॥\nआयुष्मान भव।\n\n$body\n\n॥ शुभम् भवतु • आपका कल्याण हो ॥';

  static const String _shlokaGanesha =
      '**श्लोक:** वक्रतुण्ड महाकाय सूर्यकोटि समप्रभ। निर्विघ्नं कुरु मे देव सर्वकार्येषु सर्वदा॥\n'
      '**भावार्थ:** हे महाकाय, सूर्य के समान तेजस्वी श्री गणेश जी, मेरे सभी कार्यों को सदा निर्विघ्न पूर्ण करें।';

  static const String _shlokaSurya =
      '**श्लोक:** ॐ घृणिः सूर्याय नमः। आदित्याय विद्महे प्रभाकराय धीमहि तन्नः सूर्यः प्रचोदयात्॥\n'
      '**भावार्थ:** सूर्यदेव तेज, आरोग्यता, यश, विद्या और कर्म-बल प्रदान करते हैं।';

  static const String _shlokaVishnu =
      '**श्लोक:** शान्ताकारं भुजगशयनं पद्मनाभं सुरेशं विश्वाधारं गगनसदृशं मेघवर्णं शुभाङ्गम्।\n'
      '**भावार्थ:** भगवान श्रीहरि विष्णु सभी संबंधों, यात्राओं और कार्यों को मंगलमय बनाते हैं।';

  static const String _shlokaLakshmi =
      '**श्लोक:** ॐ श्रीं ह्रीं क्लीं महालक्ष्म्यै नमः। नमस्ते सर्वगेहेषु नित्यं वसतु मे गृहे॥\n'
      '**भावार्थ:** माँ महालक्ष्मी घर में स्थिर सुख, समृद्धि, वैभव और सात्विक धन प्रदान करें।';

  static const String _shlokaShani =
      '**श्लोक:** नीलांजनसमाभासं रविपुत्रं यमाग्रजम्। छायामार्तण्डसम्भूतं तं नमामि शनैश्चरम्॥\n'
      '**भावार्थ:** भगवान शनिदेव न्याय के देवता हैं — सत्य और धर्म पर चलने वालों पर सदा कृपा करते हैं।';

  static const String _shlokaMrityunjaya =
      '**श्लोक:** ॐ त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्। उर्वारुकमिव बन्धनान्मृत्योर्मुक्षीय माऽमृतात्॥\n'
      '**भावार्थ:** त्रिनेत्रधारी भगवान शिव अकाल मृत्यु और सभी व्याधियों से रक्षा कर अमरत्व प्रदान करें।';
}
