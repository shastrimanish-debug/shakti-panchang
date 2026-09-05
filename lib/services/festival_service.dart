class FestivalItem {
  final DateTime date;
  final String name;
  final String type;

  const FestivalItem({
    required this.date,
    required this.name,
    required this.type,
  });
}

class FestivalService {
  static final List<FestivalItem> _items = [
    FestivalItem(date: DateTime(2026,1,3), name:'पौष पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,1,6), name:'सकट चौथ', type:'व्रत'),
    FestivalItem(date: DateTime(2026,1,14), name:'मकर संक्रांति • षटतिला एकादशी', type:'पर्व / व्रत'),
    FestivalItem(date: DateTime(2026,1,18), name:'मौनी अमावस्या', type:'अमावस्या'),
    FestivalItem(date: DateTime(2026,1,23), name:'वसंत पंचमी', type:'पर्व'),
    FestivalItem(date: DateTime(2026,1,29), name:'जया एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,2,1), name:'माघ पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,2,15), name:'महाशिवरात्रि', type:'पर्व / व्रत'),
    FestivalItem(date: DateTime(2026,2,27), name:'आमलकी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,3,3), name:'होली', type:'पर्व'),
    FestivalItem(date: DateTime(2026,3,15), name:'पापमोचिनी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,3,19), name:'चैत्र नवरात्रि / गुड़ी पड़वा', type:'पर्व'),
    FestivalItem(date: DateTime(2026,3,26), name:'राम नवमी', type:'पर्व'),
    FestivalItem(date: DateTime(2026,3,29), name:'कामदा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,4,2), name:'हनुमान जयंती / चैत्र पूर्णिमा', type:'पर्व / पूर्णिमा'),
    FestivalItem(date: DateTime(2026,4,19), name:'अक्षय तृतीया', type:'पर्व'),
    FestivalItem(date: DateTime(2026,4,27), name:'मोहिनी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,5,1), name:'बुद्ध पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,5,13), name:'अपरा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,5,16), name:'वट सावित्री व्रत / शनि जयंती', type:'व्रत'),
    FestivalItem(date: DateTime(2026,5,27), name:'पद्मिनी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,5,31), name:'ज्येष्ठ अधिक पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,6,11), name:'परमा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,6,25), name:'निर्जला एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,6,29), name:'वट पूर्णिमा व्रत', type:'पूर्णिमा / व्रत'),
    FestivalItem(date: DateTime(2026,7,10), name:'योगिनी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,7,16), name:'जगन्नाथ रथयात्रा', type:'पर्व'),
    FestivalItem(date: DateTime(2026,7,25), name:'देवशयनी एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,7,29), name:'गुरु पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,8,23), name:'श्रावण पुत्रदा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,8,26), name:'ओणम', type:'पर्व'),
    FestivalItem(date: DateTime(2026,8,28), name:'रक्षा बंधन / श्रावण पूर्णिमा', type:'पर्व / पूर्णिमा'),
    FestivalItem(date: DateTime(2026,8,31), name:'कजरी तीज', type:'व्रत'),
    FestivalItem(date: DateTime(2026,9,4), name:'कृष्ण जन्माष्टमी', type:'पर्व'),
    FestivalItem(date: DateTime(2026,9,7), name:'अजा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,9,14), name:'गणेश चतुर्थी / हरतालिका तीज', type:'पर्व / व्रत'),
    FestivalItem(date: DateTime(2026,9,25), name:'गणेश विसर्जन / अनंत चतुर्दशी', type:'पर्व'),
    FestivalItem(date: DateTime(2026,9,27), name:'पितृपक्ष आरंभ', type:'श्राद्ध'),
    FestivalItem(date: DateTime(2026,10,6), name:'इंदिरा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,10,10), name:'सर्व पितृ अमावस्या', type:'अमावस्या'),
    FestivalItem(date: DateTime(2026,10,11), name:'शारदीय नवरात्रि आरंभ', type:'पर्व'),
    FestivalItem(date: DateTime(2026,10,20), name:'विजयादशमी / दशहरा', type:'पर्व'),
    FestivalItem(date: DateTime(2026,10,22), name:'पापांकुशा एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,10,25), name:'शरद पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,10,29), name:'करवा चौथ', type:'व्रत'),
    FestivalItem(date: DateTime(2026,11,6), name:'धनतेरस', type:'पर्व'),
    FestivalItem(date: DateTime(2026,11,8), name:'दीवाली / लक्ष्मी पूजा', type:'पर्व / अमावस्या'),
    FestivalItem(date: DateTime(2026,11,9), name:'गोवर्धन पूजा', type:'पर्व'),
    FestivalItem(date: DateTime(2026,11,11), name:'भाई दूज', type:'पर्व'),
    FestivalItem(date: DateTime(2026,11,15), name:'छठ पूजा', type:'पर्व / व्रत'),
    FestivalItem(date: DateTime(2026,11,20), name:'देवउठनी एकादशी / गीता जयंती', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,11,21), name:'तुलसी विवाह', type:'पर्व'),
    FestivalItem(date: DateTime(2026,11,24), name:'कार्तिक पूर्णिमा', type:'पूर्णिमा'),
    FestivalItem(date: DateTime(2026,12,4), name:'उत्पन्ना एकादशी', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,12,20), name:'मोक्षदा एकादशी / गीता जयंती', type:'एकादशी'),
    FestivalItem(date: DateTime(2026,12,23), name:'दत्तात्रेय जयंती / मार्गशीर्ष पूर्णिमा', type:'पूर्णिमा'),
  ];

  static List<FestivalItem> forYear(int year) =>
      _items.where((x) => x.date.year == year).toList();

  static List<FestivalItem> upcoming(DateTime from, {int count = 8}) {
    final list = _items.where((x) =>
      !x.date.isBefore(DateTime(from.year, from.month, from.day))).toList();
    return list.take(count).toList();
  }
}
