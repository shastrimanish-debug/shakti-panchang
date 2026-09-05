/// Advanced Kundali Milan signal layer.
///
/// Combines validated compatibility signals beyond a single guna total.
/// Scores are normalized for the synthesis/UMA layer; this does not invent
/// planetary compatibility data.
class MilanSignal {
  const MilanSignal({
    required this.name,
    required this.score,
    required this.maxScore,
    this.reason = '',
    this.severity = 0,
  });
  final String name;
  final double score;
  final double maxScore;
  final String reason;
  final int severity;
}

class AdvancedMilanResult {
  const AdvancedMilanResult({
    required this.overallScore,
    required this.signals,
    required this.summary,
  });
  final double overallScore;
  final List<MilanSignal> signals;
  final String summary;
}

class AdvancedKundaliMilanEngine {
  const AdvancedKundaliMilanEngine();

  AdvancedMilanResult calculate(List<MilanSignal> signals) {
    if (signals.isEmpty) {
      return const AdvancedMilanResult(
        overallScore: 0.0, // Fixed: 0 to 0.0
        signals: [],
        summary: 'Insufficient compatibility signals.',
      );
    }

    final valid = signals.where((s) => s.maxScore > 0).toList();
    if (valid.isEmpty) {
      return AdvancedMilanResult(
        overallScore: 0.0, // Fixed: 0 to 0.0
        signals: signals,
        summary: 'Insufficient compatibility signals.',
      );
    }

    // Fixed: fold initial value changed to 0.0, and clamp limits to 0.0
    final earned = valid.fold<double>(0.0, (a, b) => a + b.score.clamp(0.0, b.maxScore));
    final possible = valid.fold<double>(0.0, (a, b) => a + b.maxScore);
    
    // Fixed: division check with 0.0
    final overall = possible == 0.0 ? 0.0 : (earned / possible) * 100.0;

    final severe = valid.where((s) => s.severity >= 3).length;
    final summary = severe > 0
        ? 'Compatibility has important areas requiring detailed review.'
        : 'Compatibility signals are suitable for a detailed combined reading.';

    return AdvancedMilanResult(
      overallScore: overall,
      signals: valid,
      summary: summary,
    );
  }
}
