class KundaliData {
  final String name;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  final double timezoneHours;
  final List<PlanetPosition> planets;
  final double lagnaDegree;
  final String lagnaRashi;
  final String moonRashi;
  final String sunRashi;
  final String nakshatra;
  final String charan;
  final String nadi;
  final String gana;
  final String yoni;
  final String varna;
  final String mahadasha;
  final String antardasha;
  final List<DashaPeriod> dashaPeriods;
  final List<DashaSubPeriod> antarPeriods;
  final List<DashaPratyantar> pratyantarPeriods;

  KundaliData({
    required this.name,
    required this.birthDate,
    required this.birthTime,
    required this.birthPlace,
    required this.latitude,
    required this.longitude,
    this.timezoneHours = 5.5,
    required this.planets,
    required this.lagnaDegree,
    required this.lagnaRashi,
    required this.moonRashi,
    required this.sunRashi,
    required this.nakshatra,
    required this.charan,
    required this.nadi,
    required this.gana,
    required this.yoni,
    required this.varna,
    required this.mahadasha,
    required this.antardasha,
    required this.dashaPeriods,
    required this.antarPeriods,
    required this.pratyantarPeriods,
  });
}

class PlanetPosition {
  final String planet;
  final String rashi;
  final double degree;
  final int house;
  final bool isRetrograde;
  final double latitude;
  final double speed;

  PlanetPosition({
    required this.planet,
    required this.rashi,
    required this.degree,
    required this.house,
    this.isRetrograde = false,
    this.latitude = 0,
    this.speed = 0,
  });
}

class DashaPeriod {
  final String planet;
  final DateTime startDate;
  final DateTime endDate;
  final double years;

  DashaPeriod({
    required this.planet,
    required this.startDate,
    required this.endDate,
    required this.years,
  });
}

class DashaSubPeriod {
  final String maha;
  final String antar;
  final DateTime startDate;
  final DateTime endDate;
  final double years;

  DashaSubPeriod({
    required this.maha,
    required this.antar,
    required this.startDate,
    required this.endDate,
    required this.years,
  });
}

class DashaPratyantar {
  final String maha;
  final String antar;
  final String pratyantar;
  final DateTime startDate;
  final DateTime endDate;
  final double years;

  DashaPratyantar({
    required this.maha,
    required this.antar,
    required this.pratyantar,
    required this.startDate,
    required this.endDate,
    required this.years,
  });
}
