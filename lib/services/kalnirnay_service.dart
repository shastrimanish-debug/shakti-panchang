import 'festival_service.dart';
import 'meeus_engine.dart';

class KalnirnayDay {
  final DateTime date;
  final int dayNumber;
  final String weekday;
  final String tithi;
  final String paksha;
  final String nakshatra;
  final bool today;
  final bool ekadashi;
  final bool pradosh;
  final bool purnima;
  final bool amavasya;
  final List<String> festivals;
  final String? badge;
  const KalnirnayDay({
    required this.date,
    required this.dayNumber,
    required this.weekday,
    required this.tithi,
    required this.paksha,
    required this.nakshatra,
    required this.today,
    required this.ekadashi,
    required this.pradosh,
    required this.purnima,
    required this.amavasya,
    required this.festivals,
    this.badge,
  });
}

class KalnirnayMonth {
  final int year;
  final int monthIndex;
  final String titleHi;
  final int vikramSamvat;
  final int firstWeekday;
  final List<KalnirnayDay> days;
  const KalnirnayMonth({
    required this.year,
    required this.monthIndex,
    required this.titleHi,
    required this.vikramSamvat,
    required this.firstWeekday,
    required this.days,
  });
}

/// Port of shakti_panchang `src/services/kalnirnay.ts`.
class KalnirnayService {
  static const _tithis = [
    'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पंचमी', 'षष्ठी', 'सप्तमी',
    'अष्टमी', 'नवमी', 'दशमी', 'एकादशी', 'द्वादशी', 'त्रयोदशी', 'चतुर्दशी', 'पूर्णिमा',
  ];
  static const _nak = [
    'अश्विनी', 'भरणी', 'कृत्तिका', 'रोहिणी', 'मृगशिरा', 'आर्द्रा', 'पुनर्वसु',
    'पुष्य', 'अश्लेषा', 'मघा', 'पूर्वाफाल्गुनी', 'उत्तराफाल्गुनी', 'हस्त', 'चित्रा',
    'स्वाती', 'विशाखा', 'अनुराधा', 'ज्येष्ठा', 'मूल', 'पूर्वाषाढ़ा', 'उत्तराषाढ़ा',
    'श्रवण', 'धनिष्ठा', 'शतभिषा', 'पूर्वाभाद्रपद', 'उत्तराभाद्रपद', 'रेवती',
  ];
  static const _week = ['रवि', 'सोम', 'मंगल', 'बुध', 'गुरु', 'शुक्र', 'शनि'];
  static const _months = [
    'जनवरी (पौष-माघ)', 'फरवरी (माघ-फाल्गुन)', 'मार्च (फाल्गुन-चैत्र)',
    'अप्रैल (चैत्र-वैशाख)', 'मई (वैशाख-ज्येष्ठ)', 'जून (ज्येष्ठ-आषाढ़)',
    'जुलाई (आषाढ़-श्रावण)', 'अगस्त (श्रावण-भाद्रपद)', 'सितम्बर (भाद्रपद-आश्विन)',
    'अक्टूबर (आश्विन-कार्तिक)', 'नवम्बर (कार्तिक-मार्गशीर्ष)', 'दिसम्बर (मार्गशीर्ष-पौष)',
  ];

  static KalnirnayMonth month(int year, int monthIndex) {
    final last = DateTime(year, monthIndex + 2, 0);
    final first = DateTime(year, monthIndex + 1, 1);
    final today = DateTime.now();
    final fests = FestivalService.forYear(year)
        .where((f) => f.date.year == year && f.date.month == monthIndex + 1)
        .toList();
    final days = <KalnirnayDay>[];
    for (var d = 1; d <= last.day; d++) {
      final dt = DateTime(year, monthIndex + 1, d, 6);
      final ayan = MeeusEngine.lahiriAyanamsha(dt);
      final sun = MeeusEngine.norm(MeeusEngine.sunTropical(dt) - ayan);
      final moon = MeeusEngine.norm(MeeusEngine.moonTropical(dt) - ayan);
      final diff = MeeusEngine.norm(moon - sun);
      final tithiIndex = (diff / 12).floor();
      final paksha = tithiIndex < 15 ? 'शुक्ल' : 'कृष्ण';
      var tithiName = _tithis[tithiIndex % 15];
      if (tithiIndex == 14) tithiName = 'पूर्णिमा';
      if (tithiIndex == 29) tithiName = 'अमावस्या';
      final nak = _nak[(moon / (360 / 27)).floor() % 27];
      final dayFests = fests.where((f) => f.date.day == d).map((f) => f.name).toList();
      final ek = tithiName == 'एकादशी';
      final pr = tithiName == 'त्रयोदशी';
      final pu = tithiName == 'पूर्णिमा';
      final am = tithiName == 'अमावस्या';
      String? badge;
      if (dayFests.isNotEmpty) {
        badge = dayFests.first;
      } else if (pu) {
        badge = 'पूर्णिमा';
      } else if (am) {
        badge = 'अमावस्या';
      } else if (ek) {
        badge = '$paksha एकादशी';
      } else if (pr) {
        badge = 'प्रदोष';
      }
      days.add(KalnirnayDay(
        date: dt,
        dayNumber: d,
        weekday: _week[dt.weekday % 7],
        tithi: tithiName,
        paksha: paksha,
        nakshatra: nak,
        today: today.year == year && today.month == monthIndex + 1 && today.day == d,
        ekadashi: ek,
        pradosh: pr,
        purnima: pu,
        amavasya: am,
        festivals: dayFests,
        badge: badge,
      ));
    }
    return KalnirnayMonth(
      year: year,
      monthIndex: monthIndex,
      titleHi: _months[monthIndex],
      vikramSamvat: year + (monthIndex >= 3 ? 57 : 56),
      firstWeekday: first.weekday % 7,
      days: days,
    );
  }
}
