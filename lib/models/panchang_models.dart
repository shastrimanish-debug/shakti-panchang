enum ChoghadiyaNature { auspicious, neutral, inauspicious }

class ChoghadiyaPeriod {
  final String name;
  final DateTime start;
  final DateTime end;
  final ChoghadiyaNature nature;
  final String meaning;

  const ChoghadiyaPeriod({
    required this.name,
    required this.start,
    required this.end,
    required this.nature,
    required this.meaning,
  });
}

class SolarTimes {
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime nextSunrise;

  const SolarTimes({
    required this.sunrise,
    required this.sunset,
    required this.nextSunrise,
  });
}

class MuhuratWindow {
  final String title;
  final DateTime start;
  final DateTime end;
  final String description;

  const MuhuratWindow({
    required this.title,
    required this.start,
    required this.end,
    required this.description,
  });
}
