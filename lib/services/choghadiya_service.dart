import '../models/panchang_models.dart';

class ChoghadiyaService {
  static const _cycle = [
    'Udveg', 'Char', 'Labh', 'Amrit', 'Kaal', 'Shubh', 'Rog'
  ];

  static const _dayStart = {
    1: 'Amrit', // Monday
    2: 'Rog',
    3: 'Labh',
    4: 'Shubh',
    5: 'Char',
    6: 'Kaal',
    7: 'Udveg',
  };

  // This is the mainstream Drik Panchang night table.
  static const _night = {
    7: ['Shubh','Amrit','Char','Rog','Kaal','Labh','Udveg','Shubh'],
    1: ['Char','Rog','Kaal','Labh','Udveg','Shubh','Amrit','Char'],
    2: ['Kaal','Labh','Udveg','Shubh','Amrit','Char','Rog','Kaal'],
    3: ['Udveg','Shubh','Amrit','Char','Rog','Kaal','Labh','Udveg'],
    4: ['Amrit','Char','Rog','Kaal','Labh','Udveg','Shubh','Amrit'],
    5: ['Rog','Kaal','Labh','Udveg','Shubh','Amrit','Char','Rog'],
    6: ['Labh','Udveg','Shubh','Amrit','Char','Rog','Kaal','Labh'],
  };

  static List<ChoghadiyaPeriod> day(SolarTimes s, int weekday) {
    final first = _dayStart[weekday]!;
    final startIndex = _cycle.indexOf(first);
    final duration = s.sunset.difference(s.sunrise).inMilliseconds ~/ 8;
    return List.generate(8, (i) {
      final start = s.sunrise.add(Duration(milliseconds: duration * i));
      final end = i == 7
          ? s.sunset
          : s.sunrise.add(Duration(milliseconds: duration * (i + 1)));
      final name = _cycle[(startIndex + i) % _cycle.length];
      return _period(name, start, end);
    });
  }

  static List<ChoghadiyaPeriod> night(SolarTimes s, int weekday) {
    final names = _night[weekday]!;
    final duration = s.nextSunrise.difference(s.sunset).inMilliseconds ~/ 8;
    return List.generate(8, (i) {
      final start = s.sunset.add(Duration(milliseconds: duration * i));
      final end = i == 7
          ? s.nextSunrise
          : s.sunset.add(Duration(milliseconds: duration * (i + 1)));
      return _period(names[i], start, end);
    });
  }

  static ChoghadiyaPeriod _period(String name, DateTime start, DateTime end) {
    final nature = switch (name) {
      'Amrit' || 'Shubh' || 'Labh' => ChoghadiyaNature.auspicious,
      'Char' => ChoghadiyaNature.neutral,
      _ => ChoghadiyaNature.inauspicious,
    };
    final meaning = switch (name) {
      'Amrit' => 'सर्व प्रकार के शुभ कार्य',
      'Shubh' => 'पूजा, मांगलिक व शुभ कार्य',
      'Labh' => 'व्यापार, धन और शिक्षा',
      'Char' => 'यात्रा व चल कार्य',
      'Rog' => 'शुभ कार्य से बचें',
      'Kaal' => 'महत्वपूर्ण शुरुआत से बचें',
      _ => 'अशुभ/अस्थिर समय',
    };
    return ChoghadiyaPeriod(
      name: name, start: start, end: end, nature: nature, meaning: meaning,
    );
  }
}

