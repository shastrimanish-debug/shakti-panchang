import 'kp_deep_engine.dart';

enum KpQuestionType { career, marriage, money, property, education, children, travel, legal, health, business, general }

class KpQuestionProfile {
  const KpQuestionProfile(this.type, this.supporting, this.denial);
  final KpQuestionType type;
  final List<int> supporting;
  final List<int> denial;

  static KpQuestionProfile of(KpQuestionType type) {
    switch (type) {
      case KpQuestionType.career: return const KpQuestionProfile(KpQuestionType.career,[2,6,10,11],[5,8,12]);
      case KpQuestionType.marriage: return const KpQuestionProfile(KpQuestionType.marriage,[2,7,11],[1,6,10]);
      case KpQuestionType.money: return const KpQuestionProfile(KpQuestionType.money,[2,6,11],[5,8,12]);
      case KpQuestionType.property: return const KpQuestionProfile(KpQuestionType.property,[4,11],[3,8,12]);
      case KpQuestionType.education: return const KpQuestionProfile(KpQuestionType.education,[4,5,9,11],[3,8,12]);
      case KpQuestionType.children: return const KpQuestionProfile(KpQuestionType.children,[2,5,11],[1,4,10]);
      case KpQuestionType.travel: return const KpQuestionProfile(KpQuestionType.travel,[3,9,12],[2,4,10]);
      case KpQuestionType.legal: return const KpQuestionProfile(KpQuestionType.legal,[6,11],[5,8,12]);
      case KpQuestionType.health: return const KpQuestionProfile(KpQuestionType.health,[1,5,11],[6,8,12]);
      case KpQuestionType.business: return const KpQuestionProfile(KpQuestionType.business,[2,7,10,11],[5,8,12]);
      case KpQuestionType.general: return const KpQuestionProfile(KpQuestionType.general,[1,2,5,7,9,10,11],[6,8,12]);
    }
  }
}

class KpHoraryVerdict {
  const KpHoraryVerdict({
    required this.number,
    required this.question,
    required this.decision,
    required this.reason,
    required this.supportScore,
    required this.denialScore,
    required this.relevantCusp,
  });
  final int number;
  final KpQuestionType question;
  final String decision;
  final String reason;
  final double supportScore;
  final double denialScore;
  final int relevantCusp;
}

class KpHoraryJudgementEngine {
  const KpHoraryJudgementEngine(this.deep);
  final KpDeepEngine deep;

  KpHoraryVerdict judge({
    required int number,
    required KpQuestionType question,
    required KpDeepReading reading,
  }) {
    if (number < 1 || number > 249) {
      throw ArgumentError.value(number, 'number', 'KP Horary number must be 1..249');
    }
    final profile = KpQuestionProfile.of(question);
    final primaryCusp = _primaryCusp(question);
    final cusp = reading.cusps.where((c) => c.cusp == primaryCusp).toList();
    final cuspSub = cusp.isEmpty ? '' : cusp.first.subLord;

    var support = 0.0;
    var denial = 0.0;
    final supporters = <String>[];
    final deniers = <String>[];

    for (final p in reading.significators) {
      final houses = p.houses.toSet();
      final s = profile.supporting.where(houses.contains).length;
      final d = profile.denial.where(houses.contains).length;
      if (s > 0) { support += s; supporters.add(p.planet); }
      if (d > 0) { denial += d; deniers.add(p.planet); }
    }

    // Cuspal Sub Lord is the decisive gate in KP. Give it additional weight,
    // but only when its planet is actually present in the calculated chart.
    final csl = reading.significators.where((p) => p.planet == cuspSub).toList();
    if (csl.isNotEmpty) {
      final h = csl.first.houses.toSet();
      support += profile.supporting.where(h.contains).length * 2.0;
      denial += profile.denial.where(h.contains).length * 2.0;
    }

    final decision = support > denial && support > 0
        ? 'YES'
        : denial > support && denial > 0
            ? 'NO'
            : 'MIXED';
    final reason = decision == 'YES'
        ? 'Relevant cusp sub-lord/significators favour the required houses.'
        : decision == 'NO'
            ? 'Relevant cusp sub-lord/significators favour the denying houses.'
            : 'Supporting and denying significators are mixed or insufficient.';

    return KpHoraryVerdict(
      number: number,
      question: question,
      decision: decision,
      reason: reason,
      supportScore: support,
      denialScore: denial,
      relevantCusp: primaryCusp,
    );
  }

  int _primaryCusp(KpQuestionType type) {
    switch (type) {
      case KpQuestionType.career: return 10;
      case KpQuestionType.marriage: return 7;
      case KpQuestionType.money: return 2;
      case KpQuestionType.property: return 4;
      case KpQuestionType.education: return 4;
      case KpQuestionType.children: return 5;
      case KpQuestionType.travel: return 9;
      case KpQuestionType.legal: return 6;
      case KpQuestionType.health: return 1;
      case KpQuestionType.business: return 7;
      case KpQuestionType.general: return 1;
    }
  }
}
