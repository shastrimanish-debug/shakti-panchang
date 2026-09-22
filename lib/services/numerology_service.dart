class NumerologyResult {
  final int mulank;
  final int bhagyank;
  final int expression;
  final int soul;
  final int personality;
  final int chaldeanName;
  final List<int> luckyNumbers;

  const NumerologyResult({
    required this.mulank,
    required this.bhagyank,
    required this.expression,
    required this.soul,
    required this.personality,
    required this.chaldeanName,
    required this.luckyNumbers,
  });
}

class NumerologyService {
  static NumerologyResult calculate({required String name, required DateTime birthDate}) {
    final normalized = name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final life = _reduce(birthDate.day + birthDate.month + birthDate.year);
    final mulank = _reduce(birthDate.day);
    final expression = _reduce(normalized.codeUnits.fold<int>(0, (s, c) => s + (c - 64)));
    final vowels = normalized.split('').where((c) => 'AEIOU'.contains(c)).join();
    final consonants = normalized.split('').where((c) => RegExp(r'[A-Z]').hasMatch(c) && !'AEIOU'.contains(c)).join();
    final soul = _reduce(vowels.codeUnits.fold<int>(0, (s, c) => s + (c - 64)));
    final personality = _reduce(consonants.codeUnits.fold<int>(0, (s, c) => s + (c - 64)));
    final chaldean = _reduce(normalized.split('').fold<int>(0, (s, c) => s + _chaldean[c]!));
    final set = <int>{mulank, bhagyankSafe(life), expression, chaldean};
    return NumerologyResult(
      mulank: mulank,
      bhagyank: bhagyankSafe(life),
      expression: expression,
      soul: soul,
      personality: personality,
      chaldeanName: chaldean,
      luckyNumbers: set.where((n) => n > 0).take(4).toList(),
    );
  }

  static int bhagyankSafe(int n) => n;

  static int _reduce(int n) {
    if (n <= 0) return 0;
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      n = n.toString().split('').fold(0, (s, c) => s + int.parse(c));
    }
    return n;
  }

  static const Map<String, int> _chaldean = {
    'A':1,'I':1,'J':1,'Q':1,'Y':1,
    'B':2,'K':2,'R':2,
    'C':3,'G':3,'L':3,'S':3,
    'D':4,'M':4,'T':4,
    'E':5,'H':5,'N':5,'X':5,
    'U':6,'V':6,'W':6,
    'O':7,'Z':7,
    'F':8,'P':8,
  };
}
