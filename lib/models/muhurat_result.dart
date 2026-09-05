enum MuhuratGrade { excellent, good, neutral, avoid }

class MuhuratResult {
  final String activity;
  final MuhuratGrade grade;
  final String title;
  final DateTime? start;
  final DateTime? end;
  final List<String> positives;
  final List<String> cautions;

  const MuhuratResult({
    required this.activity,
    required this.grade,
    required this.title,
    required this.start,
    required this.end,
    required this.positives,
    required this.cautions,
  });
}
