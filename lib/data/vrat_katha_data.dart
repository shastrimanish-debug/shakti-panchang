class VratKathaChapter {
  final String title;
  final String content;
  const VratKathaChapter({required this.title, required this.content});
}

class VratKathaItem {
  final String id;
  final String title;
  final String subtitle;
  final String deity;
  final String category;
  final String tithiInfo;
  final String significance;
  final List<String> poojaVidhi;
  final String fullText;
  final String? mantra;
  final String? aartiText;
  final List<VratKathaChapter> chapters;
  const VratKathaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.deity,
    required this.category,
    required this.tithiInfo,
    required this.significance,
    required this.poojaVidhi,
    required this.fullText,
    this.mantra,
    this.aartiText,
    this.chapters = const [],
  });
}

/// Port of shakti_panchang `src/data/vratKathaData.ts` (granth collection).
class VratKathaData {
  static const categories = [
    ('all', 'समस्त संग्रह'),
    ('ekadashi', 'एकादशी कथाएँ'),
    ('pradosh', 'प्रदोष व्रत'),
    ('satyanarayan', 'सत्यनारायण कथा'),
    ('suhag', 'सुहाग व पर्व व्रत'),
    ('chalisa_stotra', 'स्तोत्र व चालीसा'),
    ('aarti', 'आरती संग्रह'),
  ];

  static List<VratKathaItem> byCategory(String id) {
    if (id == 'all') return items;
    return items.where((e) => e.category == id).toList();
  }

  static const items = [
    VratKathaItem(
      id: 'satyanarayan',
      title: 'श्री सत्यनारायण भगवान व्रत कथा',
      subtitle: 'सम्पूर्ण ५ अध्याय, माहात्म्य एवं आरती सहित',
      deity: 'भगवान श्री सत्यनारायण',
      category: 'satyanarayan',
      tithiInfo: 'पूर्णिमा, संक्रान्ति, गुरुवार अथवा किसी शुभ कार्य के आरम्भ में',
      significance: 'कलियुग में सरल और फलदायी व्रत — गृह-शान्ति, धन-धान्य, संतान सुख।',
      poojaVidhi: [
        'प्रातः स्नान कर स्वच्छ वस्त्र धारण करें और व्रत का संकल्प लें।',
        'केले के स्तम्भों से मण्डप सजाकर पीला वस्त्र बिछाएँ।',
        'कलश स्थापना, गौरी-गणेश, नवग्रह एवं सत्यनारायण की प्रतिमा स्थापित करें।',
        'पंचामृत से अभिषेक करें।',
        'पंजरी व केले का भोग लगाएँ, कथा श्रवण कर आरती करें।',
      ],
      mantra: 'ओं नमो भगवते सत्यनारायणाय नमः । ओं विष्णवे नमः ।',
      chapters: [
        VratKathaChapter(
          title: 'प्रथम अध्याय',
          content: 'नैमिषारण्य में शौनकादि ऋषियों ने सूत जी से सरल व्रत पूछा। सूत जी ने नारद-विष्णु संवाद सुनाया — सत्यनारायण व्रत कलियुग में सर्वाधिक फलदायी है।',
        ),
        VratKathaChapter(
          title: 'द्वितीय अध्याय',
          content: 'काशी के दरिद्र ब्राह्मण शतानन्द ने वृद्ध ब्राह्मण रूप में भगवान का दर्शन पाया। व्रत से वह धनवान हुआ। लकड़हारे ने भी कथा सुनकर व्रत किया और समृद्ध हुआ।',
        ),
        VratKathaChapter(
          title: 'तृतीय-चतुर्थ अध्याय',
          content: 'वैश्य साधु ने संतान होने पर भी व्रत टाल दिया। व्यापार में बन्दी बना। पत्नी-पुत्री ने व्रत किया तो मुक्ति मिली। प्रसाद का अनादर करने पर नाव डूबी; प्रसाद ग्रहण करते ही सब सकुशल हुए।',
        ),
        VratKathaChapter(
          title: 'पञ्चम अध्याय',
          content: 'राजा तुंगध्वज ने गोपबालकों का प्रसाद नहीं लिया तो राज्य-पुत्र खोए। क्षमा और प्रसाद से सब लौट आया। जो यह कथा श्रद्धा से सुनता है उसके मनोरथ सिद्ध होते हैं।',
        ),
      ],
      fullText: 'श्री सत्यनारायण भगवान की जय। श्रद्धापूर्वक कथा श्रवण से समस्त मनोरथ सिद्ध होते हैं।',
      aartiText: 'जय लक्ष्मीरमणा, श्री जय लक्ष्मीरमणा।\nसत्यनारायण स्वामी, जन-पातक-हरणा॥',
    ),
    VratKathaItem(
      id: 'nirjala-ekadashi',
      title: 'निर्जला एकादशी व्रत कथा (भीमसेनी)',
      subtitle: 'ज्येष्ठ शुक्ल एकादशी — २४ एकादशियों का पुण्य',
      deity: 'भगवान श्री विष्णु',
      category: 'ekadashi',
      tithiInfo: 'ज्येष्ठ शुक्ल एकादशी',
      significance: 'एक निर्जल व्रत से वर्ष की समस्त एकादशियों का फल।',
      poojaVidhi: [
        'दशमी रात्रि से ब्रह्मचर्य व सात्विक आहार।',
        'एकादशी सूर्योदय से द्वादशी सूर्योदय तक जल भी न लें।',
        'ओं नमो भगवते वासुदेवाय का जप व विष्णु पूजन।',
        'द्वादशी को ब्राह्मण भोजन कराकर पारण करें।',
      ],
      mantra: 'ओं नमो भगवते वासुदेवाय ।',
      fullText: 'भीमसेन ने व्यास जी से एक ईसा व्रत माँगा जिसे वर्ष में एक बार करके सब एकादशियों का फल मिले। व्यास जी ने ज्येष्ठ शुक्ल निर्जला एकादशी बताई। भीम ने व्रत किया और पुण्य प्राप्त किया।',
    ),
    VratKathaItem(
      id: 'devshayani-devuthani',
      title: 'देवशयनी व देवउठनी एकादशी',
      subtitle: 'चातुर्मास आरम्भ और तुलसी विवाह',
      deity: 'भगवान श्री विष्णु',
      category: 'ekadashi',
      tithiInfo: 'आषाढ़ शुक्ल एकादशी तथा कार्तिक शुक्ल एकादशी',
      significance: 'चातुर्मास में विष्णु शयन; देवउठनी पर जागरण व तुलसी विवाह।',
      poojaVidhi: [
        'देवशयनी पर हरि-शयन कथा सुनें, चातुर्मास संकल्प लें।',
        'देवउठनी पर विष्णु को जगाएँ, तुलसी-शालिग्राम विवाह करें।',
      ],
      mantra: 'ओं विष्णवे नमः ।',
      fullText: 'आषाढ़ शुक्ल एकादशी को भगवान क्षीरसागर में शयन करते हैं। कार्तिक शुक्ल एकादशी को जागते हैं — चातुर्मास का समापन और शुभ कार्यों का आरम्भ।',
    ),
    VratKathaItem(
      id: 'pradosh-vrat',
      title: 'श्री प्रदोष व्रत कथा',
      subtitle: 'त्रयोदशी सांध्यकाल — शिव आराधना',
      deity: 'भगवान शिव-पार्वती',
      category: 'pradosh',
      tithiInfo: 'प्रत्येक पक्ष की त्रयोदशी, सूर्यास्त के बाद प्रदोष काल',
      significance: 'पाप क्षय, रोग शान्ति, दाम्पत्य सुख और अभीष्ट सिद्धि।',
      poojaVidhi: [
        'त्रयोदशी को उपवास रखें।',
        'संध्या समय शिवलिंग पर जल, बेलपत्र, धतूरा अर्पित करें।',
        'महामृत्युंजय या ओं नमः शिवाय का जप करें।',
      ],
      mantra: 'ओं नमः शिवाय ।',
      fullText: 'प्रदोष काल में शिव-पार्वती नन्दी पर विराजते हैं। जो इस समय पूजन करता है उसके विघ्न हरते हैं। सोम प्रदोष विशेष शुभ, शनि प्रदोष कष्ट-निवारक माना जाता है।',
    ),
    VratKathaItem(
      id: 'karwa-chauth',
      title: 'करवा चौथ व्रत कथा',
      subtitle: 'कार्तिक कृष्ण चतुर्थी — सौभाग्य व्रत',
      deity: 'कार्तिकेय / चन्द्रमा / पार्वती',
      category: 'suhag',
      tithiInfo: 'कार्तिक कृष्ण चतुर्थी',
      significance: 'पति की दीर्घायु, अखण्ड सुहाग और गृह-कल्याण।',
      poojaVidhi: [
        'सगी रात्रि से निर्जल या फलाहार व्रत।',
        'संध्या करवा पूजन, १६ श्रृंगार।',
        'चन्द्र दर्शन कर छलनी से जल अर्घ्य देकर पारण।',
      ],
      mantra: 'ओं गौरी शंकराय नमः ।',
      fullText: 'वीरवती ने करवा चौथ का व्रत पूर्ण श्रद्धा से किया। चन्द्र से पूर्व पारण की भूल पर पति मूर्छित हुए; पार्वती-शिव कृपा और सही विधि से प्राण लौटे। अतः चन्द्र दर्शन के बाद ही पारण करें।',
    ),
    VratKathaItem(
      id: 'hanuman-chalisa',
      title: 'श्री हनुमान चालीसा',
      subtitle: 'संकट मोचन स्तोत्र',
      deity: 'श्री हनुमान',
      category: 'chalisa_stotra',
      tithiInfo: 'मंगलवार, शनिवार अथवा नित्य',
      significance: 'भय, शनि पीड़ा और विघ्न नाश।',
      poojaVidhi: [
        'स्नान कर लाल/केसर वस्त्र में पाठ करें।',
        'सिंदूर, गेरु, बोला व जलेबी का भोग।',
      ],
      mantra: 'ओं हनुमते नमः ।',
      fullText: 'श्रीगुरु चरन सरोज रज निज मनु मुकुरु सुधारि।\nबरनउँ रघुबर बिमल जसु जो दायकु फल चारि॥\nबुद्धिहीन तनु जानिके सुमिरौं पवन-कुमार।\nबल बुद्धि विद्या देहु मोहिं हरहु कलेस विकार॥\nजय हनुमान ज्ञान गुन सागर। जय कपीस तिहुँ लोक उजागर॥',
    ),
    VratKathaItem(
      id: 'daily-aarti-sangrah',
      title: 'नित्य आरती संग्रह',
      subtitle: 'गणेश, दुर्गा, शिव, विष्णु, लक्ष्मी',
      deity: 'इष्टदेव',
      category: 'aarti',
      tithiInfo: 'नित्य संध्या दीप-आरती',
      significance: 'गृह में सात्विक वातावरण और इष्ट कृपा।',
      poojaVidhi: [
        'संध्या दीप जलाएँ।',
        'इष्ट की आरती गाएँ, पुष्प अर्पित करें।',
      ],
      mantra: 'ओं श्री गणेशाय नमः ।',
      fullText: 'जय गणेश जय गणेश जय गणेश देवा। माता जाकी पार्वती पिता महादेवा॥\nएकदन्त दयावन्त चारभुजाधारी। माथे सिन्दूर सोहे मूसे की सवारी॥',
      aartiText: 'ओं जय जगदीश हरे, स्वामी जय जगदीश हरे।\nभक्त जनों के संकट, दास जनों के संकट, क्षण में दूर करे॥',
    ),
  ];
}
