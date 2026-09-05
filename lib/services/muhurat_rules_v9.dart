import '../models/muhurat_result.dart';
import '../models/panchang_boundaries.dart';

class MuhuratRulesV9 {
  const MuhuratRulesV9();

  MuhuratResult evaluate({
    required String activity,
    required DateTime when,
    required DailyPanchangBoundaries panchang,
    required String? dishaShool,
  }) {
    final cautions = <String>[];
    final positives = <String>[];

    final tithi = panchang.tithi.currentName;
    final yoga = panchang.yoga.currentName;

    // Conservative filtering layer. It intentionally avoids claiming a
    // universal shastriya rule for every activity; the selected methodology
    // can be tightened later without changing the UI.
    const generallyCautiousTithis = {
      'कृष्ण चतुर्दशी',
      'अमावस्या',
      'शुक्ल चतुर्थी',
    };
    const generallySupportiveYogas = {
      'सिद्धि', 'सिद्ध', 'शुभ', 'सौभाग्य', 'धृति', 'प्रीति', 'शिव',
    };

    if (generallyCautiousTithis.contains(tithi)) {
      cautions.add('$tithi सामान्य शुभ कार्य के लिए सावधानी का संकेत है।');
    } else {
      positives.add('$tithi को सामान्यतः सीधे निषिद्ध नहीं माना गया।');
    }

    if (generallySupportiveYogas.contains(yoga)) {
      positives.add('योग $yoga सकारात्मक संकेत देता है।');
    } else {
      cautions.add('योग $yoga के कारण विशेष कार्य में अतिरिक्त जाँच रखें।');
    }

    if (activity.contains('यात्रा') && dishaShool != null) {
      cautions.add('आज दिशाशूल: $dishaShool — यात्रा की वास्तविक दिशा अलग से जाँचें।');
    }

    if (activity.contains('विवाह') || activity.contains('गृह प्रवेश')) {
      cautions.add('यह विशेष मुहूर्त है: लग्न, नक्षत्र, दोष और स्थानीय पंचांग नियम भी जाँचना जरूरी है।');
    }

    final grade = cautions.isEmpty
        ? MuhuratGrade.good
        : (positives.length >= cautions.length
            ? MuhuratGrade.neutral
            : MuhuratGrade.avoid);

    return MuhuratResult(
      activity: activity,
      grade: grade,
      title: grade == MuhuratGrade.avoid ? 'आज सावधानी रखें' : 'प्रारंभिक मुहूर्त संकेत',
      start: when,
      end: when.add(const Duration(hours: 1)),
      positives: positives,
      cautions: cautions,
    );
  }
}
