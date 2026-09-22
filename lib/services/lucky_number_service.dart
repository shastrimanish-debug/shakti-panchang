import '../models/kundali_model.dart';

/// Deterministic lucky-number layer based on traditional planetary-number
/// correspondences. It deliberately avoids the old modulo/random-style formula.
///
/// Planet -> number:
/// Sun 1, Moon 2, Jupiter 3, Rahu 4, Mercury 5, Venus 6, Ketu 7,
/// Saturn 8, Mars 9.
class LuckyNumberService {
  static const Map<String, int> planetNumbers = {
    'सूर्य': 1,
    'चंद्र': 2,
    'गुरु': 3,
    'राहु': 4,
    'बुध': 5,
    'शुक्र': 6,
    'केतु': 7,
    'शनि': 8,
    'मंगल': 9,
  };

  static const Map<String, String> rashiLords = {
    'मेष': 'मंगल', 'वृषभ': 'शुक्र', 'मिथुन': 'बुध', 'कर्क': 'चंद्र',
    'सिंह': 'सूर्य', 'कन्या': 'बुध', 'तुला': 'शुक्र', 'वृश्चिक': 'मंगल',
    'धनु': 'गुरु', 'मकर': 'शनि', 'कुंभ': 'शनि', 'मीन': 'गुरु',
  };

  static const Map<int, String> weekdayLords = {
    DateTime.monday: 'चंद्र',
    DateTime.tuesday: 'मंगल',
    DateTime.wednesday: 'बुध',
    DateTime.thursday: 'गुरु',
    DateTime.friday: 'शुक्र',
    DateTime.saturday: 'शनि',
    DateTime.sunday: 'सूर्य',
  };

  static LuckyNumberResult daily({
    required DateTime date,
    required String rashi,
    required String transitMoonRashi,
  }) {
    final scores = <int, int>{for (var n = 1; n <= 9; n++) n: 0};
    final reasons = <String>[];

    _addPlanet(scores, rashiLords[rashi], 3, reasons, 'जन्म/आधार राशि स्वामी');
    _addPlanet(scores, rashiLords[transitMoonRashi], 2, reasons, 'आज के चंद्र गोचर की राशि स्वामी');
    _addPlanet(scores, weekdayLords[date.weekday], 2, reasons, 'वार स्वामी');

    final dayRoot = _reduce(date.year + date.month + date.day);
    scores[dayRoot] = (scores[dayRoot] ?? 0) + 1;
    reasons.add('तारीख का अंक-मूल: $dayRoot');

    return _rank(scores, reasons, 'Daily planetary-number calculation');
  }

  static LuckyNumberResult personalized({
    required DateTime date,
    required KundaliData natal,
    required String? maha,
    required String? antar,
    required String? pratyantar,
  }) {
    final scores = <int, int>{for (var n = 1; n <= 9; n++) n: 0};
    final reasons = <String>[];

    final mulank = _reduce(natal.birthDate.day);
    final bhagyank = _reduce(natal.birthDate.year + natal.birthDate.month + natal.birthDate.day);
    scores[mulank] = scores[mulank]! + 4;
    scores[bhagyank] = scores[bhagyank]! + 3;
    reasons.add('मूलांक $mulank और भाग्यांक $bhagyank');

    _addPlanet(scores, rashiLords[natal.moonRashi], 3, reasons, 'जन्म चंद्र राशि स्वामी');
    _addPlanet(scores, rashiLords[natal.lagnaRashi], 2, reasons, 'लग्न राशि स्वामी');
    _addPlanet(scores, weekdayLords[date.weekday], 1, reasons, 'आज का वार स्वामी');

    for (final entry in <MapEntry<String?, int>>[
      MapEntry(maha, 4),
      MapEntry(antar, 3),
      MapEntry(pratyantar, 2),
    ]) {
      if (entry.key != null) {
        _addPlanet(scores, entry.key, entry.value, reasons, 'सक्रिय दशा स्वामी');
      }
    }

    return _rank(scores, reasons, 'Birth-chart + Vimshottari Dasha calculation');
  }

  static void _addPlanet(Map<int, int> scores, String? planet, int weight,
      List<String> reasons, String label) {
    if (planet == null) return;
    final n = planetNumbers[planet];
    if (n == null) return;
    scores[n] = scores[n]! + weight;
    reasons.add('$label: $planet → $n');
  }

  static LuckyNumberResult _rank(Map<int, int> scores, List<String> reasons, String method) {
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value != a.value ? b.value.compareTo(a.value) : a.key.compareTo(b.key));
    final numbers = ranked.where((e) => e.value > 0).take(4).map((e) => e.key).toList();
    return LuckyNumberResult(
      primary: numbers.isEmpty ? 1 : numbers.first,
      numbers: numbers.isEmpty ? const [1] : numbers,
      method: method,
      basis: reasons,
    );
  }

  static int _reduce(int n) {
    n = n.abs();
    while (n > 9) {
      n = n.toString().split('').fold(0, (s, c) => s + int.parse(c));
    }
    return n == 0 ? 9 : n;
  }
}

class LuckyNumberResult {
  final int primary;
  final List<int> numbers;
  final String method;
  final List<String> basis;

  const LuckyNumberResult({
    required this.primary,
    required this.numbers,
    required this.method,
    required this.basis,
  });
}
