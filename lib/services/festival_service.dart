import 'meeus_engine.dart';

class FestivalItem {
  final DateTime date;
  final String name;
  final String type;
  final String? description;

  const FestivalItem({
    required this.date,
    required this.name,
    required this.type,
    this.description,
  });
}

class CenturySearchResult {
  final int year;
  final FestivalItem festival;
  const CenturySearchResult({required this.year, required this.festival});
}

/// Astronomical Hindu festivals for any Gregorian year (same mapping as web app).
class FestivalService {
  static const _rashis = [
    'मेष', 'वृषभ', 'मिथुन', 'कर्क', 'सिंह', 'कन्या',
    'तुला', 'वृश्चिक', 'धनु', 'मकर', 'कुंभ', 'मीन',
  ];
  static final Map<int, List<FestivalItem>> _cache = {};

  static List<FestivalItem> forYear(int year) {
    final hit = _cache[year];
    if (hit != null) return hit;
    final list = _computeYear(year);
    _cache[year] = list;
    return list;
  }

  static List<FestivalItem> upcoming(DateTime from, {int count = 12}) {
    final y = from.year;
    final day = DateTime(from.year, from.month, from.day);
    final all = [...forYear(y), ...forYear(y + 1)];
    all.sort((a, b) => a.date.compareTo(b.date));
    return all.where((x) => !x.date.isBefore(day)).take(count).toList();
  }

  static List<CenturySearchResult> searchAcross({
    required String query,
    int startYear = 1925,
    int endYear = 2125,
  }) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return const [];
    final syn = <String>{q};
    void addAll(Iterable<String> xs) => syn.addAll(xs);
    if (q.contains('दिवाली') || q.contains('diwali') || q.contains('दीपावली')) {
      addAll(['दीपावली', 'दिवाली', 'diwali', 'महालक्ष्मी']);
    }
    if (q.contains('शिवरात्रि') || q.contains('shivratri')) syn.add('महाशिवरात्रि');
    if (q.contains('राखी') || q.contains('rakhi')) syn.add('रक्षाबंधन');
    if (q.contains('करवा')) syn.add('करवा चौथ');
    if (q.contains('जन्माष्टमी') || q.contains('janmashtami')) addAll(['कृष्ण', 'जन्माष्टमी']);
    if (q.contains('दशहरा') || q.contains('dussehra')) syn.add('विजयादशमी');
    if (q.contains('छठ')) addAll(['छठ पूजा']);
    if (q.contains('राम')) syn.add('राम नवमी');
    if (q.contains('गणेश') || q.contains('ganesh')) syn.add('गणेश चतुर्थी');
    if (q.contains('होली') || q.contains('holi')) addAll(['होलिका', 'होली']);
    if (q.contains('नवरात्रि')) addAll(['नवरात्रि', 'घटस्थापना']);

    final out = <CenturySearchResult>[];
    for (var y = startYear; y <= endYear; y++) {
      for (final f in forYear(y)) {
        final blob = '${f.name} ${f.description ?? ''}'.toLowerCase();
        if (syn.any(blob.contains)) {
          out.add(CenturySearchResult(year: y, festival: f));
        }
      }
    }
    return out;
  }

  static List<FestivalItem> _computeYear(int year) {
    final amas = _collectPhases(year, 0);
    final purs = _collectPhases(year, 180);
    DateTime? findAm(String rashi) {
      for (final a in amas) {
        if (a.rashi == rashi && a.date.year == year) return a.date;
      }
      for (final a in amas) {
        if (a.rashi == rashi) return a.date;
      }
      return null;
    }

    DateTime? findPu(int month0) {
      for (final p in purs) {
        if (p.date.year == year && p.date.month == month0 + 1) return p.date;
      }
      return null;
    }

    DateTime add(DateTime d, int days) => d.add(Duration(days: days));
    final f = <FestivalItem>[];
    void push(DateTime? d, String name, String type, String desc) {
      if (d == null || d.year != year) return;
      f.add(FestivalItem(date: d, name: name, type: type, description: desc));
    }

    // Solar
    final makar = _sankrantiDay(year, 270) ?? DateTime(year, 1, 14);
    push(makar.subtract(const Duration(days: 1)), 'लोहड़ी', 'पर्व', 'मकर संक्रांति से पूर्व अग्नि पूजन।');
    push(makar, 'मकर संक्रांति', 'पर्व', 'सूर्य का मकर राशि प्रवेश, उत्तरायण पुण्य काल।');
    final mesha = _sankrantiDay(year, 0) ?? DateTime(year, 4, 14);
    push(mesha, 'बैसाखी (मेष संक्रांति)', 'पर्व', 'सौर नववर्ष, सूर्य का मेष राशि प्रवेश।');

    final maghaAm = findAm('मकर');
    push(maghaAm, 'मौनी अमावस्या', 'अमावस्या', 'माघ कृष्ण अमावस्या, संगम स्नान।');
    if (maghaAm != null) {
      push(add(maghaAm, 5), 'वसंत पंचमी (सरस्वती पूजा)', 'पर्व', 'माघ शुक्ल पंचमी, मां सरस्वती पूजन।');
    }
    push(findPu(1) ?? findPu(0), 'माघ पूर्णिमा', 'पूर्णिमा', 'माघ स्नान, सत्यनारायण पूजन।');

    final phalgunaAm = findAm('कुंभ');
    if (phalgunaAm != null) {
      push(add(phalgunaAm, -1), 'महाशिवरात्रि', 'व्रत', 'फाल्गुन कृष्ण चतुर्दशी, रुद्राभिषेक।');
      push(phalgunaAm, 'फाल्गुन अमावस्या', 'अमावस्या', 'दर्श अमावस्या, पितर तर्पण।');
    }
    final holiPu = findPu(2) ?? findPu(1);
    push(holiPu, 'होलिका दहन', 'पर्व', 'फाल्गुन पूर्णिमा संध्या, अग्नि पूजन।');
    if (holiPu != null) push(add(holiPu, 1), 'होली (धुलेंडी)', 'पर्व', 'रंगों का महापर्व।');

    if (phalgunaAm != null) {
      final nav = add(phalgunaAm, 1);
      push(nav, 'चैत्र नवरात्रि / नव संवत्सर (वि॰सं॰ ${year + 57})', 'पर्व', 'गुड़ी पड़वा, घटस्थापना।');
      push(add(nav, 8), 'श्री राम नवमी', 'पर्व', 'चैत्र शुक्ल नवमी, श्री राम जन्म।');
    }
    push(findPu(3) ?? findPu(2), 'श्री हनुमान जयंती', 'पर्व', 'चैत्र पूर्णिमा, हनुमान जन्मोत्सव।');

    final chaitraAm = findAm('मीन');
    if (chaitraAm != null) {
      push(add(chaitraAm, 3), 'अक्षय तृतीया', 'पर्व', 'वैशाख शुक्ल तृतीया, अबूझ मुहूर्त।');
    }
    push(findPu(4) ?? findPu(3), 'बुद्ध पूर्णिमा', 'पर्व', 'वैशाख पूर्णिमा, भगवान बुद्ध जयन्ती।');

    final vaishakhaAm = findAm('मेष');
    if (vaishakhaAm != null) {
      push(add(vaishakhaAm, 10), 'गंगा दशहरा', 'पर्व', 'ज्येष्ठ शुक्ल दशमी, गंगा अवतरण।');
      push(add(vaishakhaAm, 11), 'निर्जला एकादशी', 'एकादशी', 'ज्येष्ठ शुक्ल एकादशी, निर्जल व्रत।');
    }

    final jyeshthaAm = findAm('वृषभ');
    if (jyeshthaAm != null) {
      push(add(jyeshthaAm, 2), 'जगन्नाथ रथयात्रा', 'पर्व', 'आषाढ़ शुक्ल द्वितीया, पुरी रथयात्रा।');
      push(add(jyeshthaAm, 11), 'देवशयनी एकादशी', 'एकादशी', 'चातुर्मास आरंभ, विष्णु शयन।');
    }
    push(findPu(6) ?? findPu(5), 'गुरु पूर्णिमा', 'पर्व', 'आषाढ़ पूर्णिमा, व्यास जयंती।');

    final ashadhaAm = findAm('मिथुन');
    if (ashadhaAm != null) {
      push(add(ashadhaAm, 3), 'हरियाली तीज', 'व्रत', 'श्रावण शुक्ल तृतीया, सौभाग्य व्रत।');
      push(add(ashadhaAm, 5), 'नाग पंचमी', 'पर्व', 'श्रावण शुक्ल पंचमी, नाग पूजन।');
    }
    final shravanaPu = findPu(7) ?? findPu(8);
    push(shravanaPu, 'रक्षाबंधन', 'पर्व', 'श्रावण पूर्णिमा, रक्षा सूत्र।');
    if (shravanaPu != null) {
      push(add(shravanaPu, 8), 'श्री कृष्ण जन्माष्टमी', 'पर्व', 'भाद्रपद कृष्ण अष्टमी, श्री कृष्ण जन्म।');
    }

    final shravanaAm = findAm('कर्क') ?? findAm('सिंह');
    if (shravanaAm != null) {
      push(add(shravanaAm, 3), 'हरतालिका तीज', 'व्रत', 'भाद्रपद शुक्ल तृतीया।');
      push(add(shravanaAm, 4), 'गणेश चतुर्थी', 'पर्व', 'विघ्नहर्ता श्री गणेश जन्मोत्सव।');
      push(add(shravanaAm, 14), 'अनंत चतुर्दशी / गणेश विसर्जन', 'पर्व', 'गणेश विसर्जन, अनंत सूत्र।');
    }
    push(findPu(8) ?? findPu(7), 'पितृ पक्ष आरंभ', 'श्राद्ध', 'भाद्रपद पूर्णिमा से महालय।');

    final ashwinAm = findAm('कन्या');
    if (ashwinAm != null) {
      push(ashwinAm, 'सर्वपितृ अमावस्या', 'अमावस्या', 'महालया, समस्त पितर श्राद्ध।');
      final nav = add(ashwinAm, 1);
      push(nav, 'शारदीय नवरात्रि घटस्थापना', 'पर्व', 'आश्विन शुक्ल प्रतिपदा।');
      push(add(nav, 7), 'दुर्गा महाष्टमी', 'पर्व', 'कन्या पूजन, संधि पूजा।');
      push(add(nav, 8), 'महानवमी', 'पर्व', 'मां सिद्धिदात्री पूजन।');
      push(add(nav, 9), 'दशहरा (विजयादशमी)', 'पर्व', 'धर्म की विजय, शस्त्र पूजन।');
    }
    final ashwinPu = findPu(9) ?? findPu(10);
    push(ashwinPu, 'शरद पूर्णिमा', 'पूर्णिमा', 'कोजागरी, महालक्ष्मी भ्रमण।');
    if (ashwinPu != null) {
      push(add(ashwinPu, 4), 'करवा चौथ', 'व्रत', 'कार्तिक कृष्ण चतुर्थी, सुहाग व्रत।');
      push(add(ashwinPu, 8), 'अहोई अष्टमी', 'व्रत', 'संतान कल्याण व्रत।');
    }

    final kartikaAm = findAm('तुला');
    if (kartikaAm != null) {
      push(add(kartikaAm, -2), 'धनतेरस', 'पर्व', 'धन्वंतरि जयंती, यम दीपदान।');
      push(add(kartikaAm, -1), 'नरक चतुर्दशी (छोटी दीवाली)', 'पर्व', 'रूप चौदस, उबटन स्नान।');
      push(kartikaAm, 'दीपावली (महालक्ष्मी पूजन)', 'पर्व', 'कार्तिक अमावस्या, लक्ष्मी-गणेश पूजन।');
      push(add(kartikaAm, 1), 'गोवर्धन पूजा / अन्नकूट', 'पर्व', 'कार्तिक शुक्ल प्रतिपदा।');
      push(add(kartikaAm, 2), 'भाई दूज', 'पर्व', 'यम द्वितीया, तिलक पर्व।');
      push(add(kartikaAm, 6), 'छठ पूजा', 'व्रत', 'कार्तिक शुक्ल षष्ठी, सूर्य अर्घ्य।');
      push(add(kartikaAm, 11), 'देवउठनी एकादशी / तुलसी विवाह', 'एकादशी', 'प्रबोधिनी, चातुर्मास समापन।');
    }
    push(findPu(10) ?? findPu(11), 'कार्तिक पूर्णिमा (देव दीपावली)', 'पूर्णिमा', 'त्रिपुरारी पूर्णिमा, काशी दीप।');

    final margAm = findAm('वृश्चिक');
    if (margAm != null) {
      push(add(margAm, 11), 'गीता जयंती / मोक्षदा एकादशी', 'एकादशी', 'मार्गशीर्ष शुक्ल एकादशी।');
    }
    push(findPu(11) ?? findPu(0), 'पौष पूर्णिमा', 'पूर्णिमा', 'माघ मेला आरंभ, पुण्य स्नान।');

    f.sort((a, b) => a.date.compareTo(b.date));
    return f;
  }

  static DateTime? _sankrantiDay(int year, double targetLon) {
    final month = targetLon == 0 ? 4 : 1;
    for (var d = 12; d <= 16; d++) {
      final t = DateTime.utc(year, month, d, 6);
      final ayan = MeeusEngine.lahiriAyanamsha(t);
      final sun = MeeusEngine.norm(MeeusEngine.sunTropical(t) - ayan);
      if (targetLon == 0) {
        if (sun < 2 || sun > 358) return DateTime(year, month, d);
      } else if (sun >= targetLon && sun < targetLon + 2) {
        return DateTime(year, month, d);
      }
    }
    return null;
  }

  static List<_PhaseHit> _collectPhases(int year, double target) {
    final start = DateTime.utc(year - 1, 12, 10);
    final end = DateTime.utc(year + 1, 1, 20);
    final out = <_PhaseHit>[];
    var cur = start;
    while (cur.isBefore(end) && out.length < 18) {
      final found = _searchPhase(target, cur, end);
      if (found == null) break;
      final ist = found.toUtc().add(const Duration(hours: 5, minutes: 30));
      final ayan = MeeusEngine.lahiriAyanamsha(found);
      final sun = MeeusEngine.norm(MeeusEngine.sunTropical(found) - ayan);
      final rashi = _rashis[(sun / 30).floor() % 12];
      out.add(_PhaseHit(DateTime(ist.year, ist.month, ist.day), rashi));
      cur = found.add(const Duration(days: 20));
    }
    return out;
  }

  static double _elong(DateTime d) =>
      MeeusEngine.norm(MeeusEngine.moonTropical(d) - MeeusEngine.sunTropical(d));

  static double _signed(double p, double t) {
    var d = p - t;
    if (d > 180) d -= 360;
    if (d < -180) d += 360;
    return d;
  }

  static DateTime? _searchPhase(double target, DateTime after, DateTime limit) {
    var prev = after;
    var prevP = _elong(after);
    var t = after.add(const Duration(hours: 6));
    while (t.isBefore(limit)) {
      final p = _elong(t);
      final da = _signed(prevP, target);
      final db = _signed(p, target);
      if (da <= 0 && db >= 0) {
        var lo = prev;
        var hi = t;
        for (var i = 0; i < 24; i++) {
          final midMs = (lo.millisecondsSinceEpoch + hi.millisecondsSinceEpoch) ~/ 2;
          final mid = DateTime.fromMillisecondsSinceEpoch(midMs, isUtc: true);
          if (_signed(_elong(mid), target) < 0) {
            lo = mid;
          } else {
            hi = mid;
          }
        }
        return DateTime.fromMillisecondsSinceEpoch(
          (lo.millisecondsSinceEpoch + hi.millisecondsSinceEpoch) ~/ 2,
          isUtc: true,
        );
      }
      prev = t;
      prevP = p;
      t = t.add(const Duration(hours: 6));
    }
    return null;
  }
}

class _PhaseHit {
  final DateTime date;
  final String rashi;
  const _PhaseHit(this.date, this.rashi);
}
