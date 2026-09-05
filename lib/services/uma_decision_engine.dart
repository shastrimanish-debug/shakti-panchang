import '../models/uma_decision.dart';
import '../models/panchang_boundaries.dart';
import '../models/muhurat_result.dart';
import 'muhurat_rules_v9.dart';

class UmaDecisionEngine {
  const UmaDecisionEngine();

  UmaDecision decide({
    required String question,
    required String activity,
    required DateTime when,
    required DailyPanchangBoundaries panchang,
    required String? dishaShool,
  }) {
    final r = const MuhuratRulesV9().evaluate(
      activity: activity,
      when: when,
      panchang: panchang,
      dishaShool: dishaShool,
    );

    final reasons = <String>[
      ...r.positives,
      ...r.cautions,
    ];

    final checks = <String>[];
    if (activity == 'यात्रा') {
      checks.add('गंतव्य की वास्तविक दिशा और आज का दिशाशूल अलग से verify करें।');
    }
    if (activity == 'विवाह' || activity == 'गृह प्रवेश' ||
        activity == 'नामकरण' || activity == 'भूमि / प्रॉपर्टी') {
      checks.add('विशेष मुहूर्त के लिए लग्न, दोष और चुनी हुई पंचांग परंपरा के नियम भी verify करें।');
    }
    checks.add('समय स्थान और स्थानीय सूर्योदय के अनुसार ही final करें।');

    final level = switch (r.grade) {
      MuhuratGrade.excellent => UmaDecisionLevel.excellent,
      MuhuratGrade.good => UmaDecisionLevel.recommended,
      MuhuratGrade.neutral => UmaDecisionLevel.caution,
      MuhuratGrade.avoid => UmaDecisionLevel.avoid,
    };

    final short = switch (level) {
      UmaDecisionLevel.excellent => 'बहुत शुभ संकेत',
      UmaDecisionLevel.recommended => 'प्रारंभिक रूप से शुभ',
      UmaDecisionLevel.caution => 'सावधानी के साथ',
      UmaDecisionLevel.avoid => 'अभी टालना बेहतर',
      UmaDecisionLevel.insufficientData => 'अधिक जानकारी चाहिए',
    };

    final spoken = 'उमा बता रही हूँ। $activity के लिए $short। '
        '${reasons.take(2).join(' ')} '
        '${checks.isNotEmpty ? checks.first : ''}';

    return UmaDecision(
      userQuestion: question,
      shortAnswer: short,
      spokenAnswer: spoken,
      level: level,
      reasons: reasons,
      checks: checks,
      action: 'Shubh Samay स्क्रीन में जाकर $activity चुनें और final समय verify करें।',
    );
  }
}
