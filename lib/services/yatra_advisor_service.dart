import '../models/panchang_models.dart';
import 'choghadiya_service.dart';
import 'inauspicious_service.dart';

class YatraAdvice {
  final String direction;
  final bool directionBlocked;
  final List<ChoghadiyaPeriod> suitable;
  final String summary;
  final List<ChoghadiyaPeriod> blockedTimes;

  const YatraAdvice({
    required this.direction,
    required this.directionBlocked,
    required this.suitable,
    required this.summary,
    required this.blockedTimes,
  });
}

class YatraAdvisorService {
  static YatraAdvice advise({
    required SolarTimes solar,
    required int weekday,
    required String direction,
    required String blockedDirection,
  }) {
    final day = ChoghadiyaService.day(solar, weekday);
    final night = ChoghadiyaService.night(solar, weekday);
    final bad = InauspiciousService.daytime(
      solar.sunrise, solar.sunset, weekday,
    );

    final candidates = [...day, ...night].where((p) {
      final name = p.name.toLowerCase();
      final badName = name == 'kaal' || name == 'rog' || name == 'udveg';
      final overlapsBad = bad.any((b) =>
        p.start.isBefore(b.end) && p.end.isAfter(b.start));
      return !badName && !overlapsBad;
    }).toList();

    final blocked = direction == blockedDirection;
    return YatraAdvice(
      direction: direction,
      directionBlocked: blocked,
      suitable: candidates,
      blockedTimes: bad.map((w) => ChoghadiyaPeriod(
        name: w.title,
        start: w.start,
        end: w.end,
        nature: ChoghadiyaNature.inauspicious,
        meaning: w.description,
      )).toList(),
      summary: blocked
          ? 'दिशा $direction है और आज दिशाशूल भी इसी दिशा में है। यात्रा का समय/दिशा बदलना बेहतर है।'
          : 'दिशा $direction आज के सीधे दिशाशूल से प्रभावित नहीं है। नीचे अपेक्षाकृत बेहतर चौघड़िया दिए हैं।',
    );
  }
}
