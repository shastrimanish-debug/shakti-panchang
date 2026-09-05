/// Personalized upay recommendation primitives.
///
/// This layer ranks remedies from the actual prediction context:
/// rashi, graha, dasha/antardasha, house, nakshatra and prediction category.
/// A web-research adapter can enrich the catalog later; the UI never needs to
/// know where the remedy text originated.
class UpayContext {
  const UpayContext({
    this.rashi = '',
    this.mahadasha = '',
    this.antardasha = '',
    this.affectedGraha = const [],
    this.affectedBhava = const [],
    this.nakshatra = '',
    this.predictionCategory = '',
    this.predictionLevel = '',
  });

  final String rashi;
  final String mahadasha;
  final String antardasha;
  final List<String> affectedGraha;
  final List<int> affectedBhava;
  final String nakshatra;
  final String predictionCategory;
  final String predictionLevel;
}

class PersonalizedUpay {
  const PersonalizedUpay({
    required this.title,
    required this.reason,
    required this.steps,
    required this.priority,
    this.duration = '',
    this.caution = '',
    this.source = 'Shakti Panchang knowledge base',
  });

  final String title;
  final String reason;
  final List<String> steps;
  final int priority;
  final String duration;
  final String caution;
  final String source;
}

class PersonalizedUpayEngine {
  const PersonalizedUpayEngine();

  List<PersonalizedUpay> recommend(
    UpayContext context, {
    List<PersonalizedUpay> researched = const [],
  }) {
    final catalog = <PersonalizedUpay>[
      ..._graha(context.affectedGraha),
      ..._category(context.predictionCategory),
      ...researched,
    ];

    final ranked = [...catalog]
      ..sort((a, b) => b.priority.compareTo(a.priority));

    // Avoid giving the same generic remedy repeatedly.
    final seen = <String>{};
    return ranked.where((u) => seen.add(u.title)).take(5).toList();
  }

  List<PersonalizedUpay> _graha(List<String> grahas) {
    final result = <PersonalizedUpay>[];
    for (final raw in grahas) {
      final g = raw.trim().toLowerCase();
      if (g.contains('shani') || g.contains('saturn')) {
        result.add(const PersonalizedUpay(
          title: 'Shani-focused discipline and seva',
          reason: 'Recommendation is tied to the Saturn signal in the chart.',
          steps: ['Follow consistent daily discipline.', 'Do suitable seva/daan on Saturday.'],
          priority: 90,
          duration: 'Follow consistently and reassess with the next dasha/transit.',
        ));
      } else if (g.contains('mangal') || g.contains('mars')) {
        result.add(const PersonalizedUpay(
          title: 'Mangal-focused seva and self-control',
          reason: 'Recommendation is tied to the Mars signal in the chart.',
          steps: ['Prefer constructive physical activity.', 'Do suitable seva/daan on Tuesday.'],
          priority: 90,
          duration: 'Follow consistently and reassess with the next dasha/transit.',
        ));
      } else if (g.contains('budh') || g.contains('mercury')) {
        result.add(const PersonalizedUpay(
          title: 'Budh-focused learning and communication',
          reason: 'Recommendation is tied to the Mercury signal in the chart.',
          steps: ['Maintain clear communication and study discipline.', 'Do suitable seva/daan on Wednesday.'],
          priority: 85,
        ));
      } else if (g.contains('guru') || g.contains('jupiter')) {
        result.add(const PersonalizedUpay(
          title: 'Guru-focused learning and seva',
          reason: 'Recommendation is tied to the Jupiter signal in the chart.',
          steps: ['Support learning/teaching activities.', 'Do suitable seva/daan on Thursday.'],
          priority: 85,
        ));
      } else if (g.contains('shukra') || g.contains('venus')) {
        result.add(const PersonalizedUpay(
          title: 'Shukra-focused harmony and seva',
          reason: 'Recommendation is tied to the Venus signal in the chart.',
          steps: ['Keep relationships and finances balanced.', 'Do suitable seva/daan on Friday.'],
          priority: 80,
        ));
      } else if (g.contains('surya') || g.contains('sun')) {
        result.add(const PersonalizedUpay(
          title: 'Surya-focused routine and respect',
          reason: 'Recommendation is tied to the Sun signal in the chart.',
          steps: ['Maintain a disciplined morning routine.', 'Practice respectful conduct toward mentors and elders.'],
          priority: 80,
        ));
      } else if (g.contains('chandra') || g.contains('moon')) {
        result.add(const PersonalizedUpay(
          title: 'Chandra-focused calm and routine',
          reason: 'Recommendation is tied to the Moon signal in the chart.',
          steps: ['Keep sleep and daily routine steady.', 'Use simple calming practices regularly.'],
          priority: 80,
        ));
      } else if (g.contains('rahu')) {
        result.add(const PersonalizedUpay(
          title: 'Rahu-focused clarity and restraint',
          reason: 'Recommendation is tied to the Rahu signal in the chart.',
          steps: ['Avoid impulsive decisions.', 'Prefer transparent, documented choices.'],
          priority: 88,
        ));
      } else if (g.contains('ketu')) {
        result.add(const PersonalizedUpay(
          title: 'Ketu-focused grounding and service',
          reason: 'Recommendation is tied to the Ketu signal in the chart.',
          steps: ['Keep routines grounded and practical.', 'Include regular selfless service.'],
          priority: 82,
        ));
      }
    }
    return result;
  }

  List<PersonalizedUpay> _category(String category) {
    final c = category.toLowerCase();
    if (c.contains('career') || c.contains('job')) {
      return const [
        PersonalizedUpay(
          title: 'Career-focused practical action plan',
          reason: 'The remedy is selected for a career-related prediction.',
          steps: ['Strengthen one job-relevant skill.', 'Review decisions after the indicated timing window.'],
          priority: 60,
        ),
      ];
    }
    if (c.contains('finance') || c.contains('money')) {
      return const [
        PersonalizedUpay(
          title: 'Finance-focused discipline',
          reason: 'The remedy is selected for a finance-related prediction.',
          steps: ['Avoid unnecessary speculative decisions.', 'Track cash flow and commitments carefully.'],
          priority: 60,
        ),
      ];
    }
    if (c.contains('health')) {
      return const [
        PersonalizedUpay(
          title: 'Wellness-focused routine',
          reason: 'The remedy is selected for a wellness-related prediction.',
          steps: ['Keep a regular routine.', 'For health concerns, consult a qualified medical professional.'],
          priority: 60,
          caution: 'Astrology is not a substitute for medical diagnosis or treatment.',
        ),
      ];
    }
    return const [];
  }
}
