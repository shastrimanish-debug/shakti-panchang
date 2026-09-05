import '../models/kundali_model.dart';
import 'astrology_advanced_service.dart';
import 'kundali_calculator.dart';

class KpPlanetSignificator {
  const KpPlanetSignificator({
    required this.planet,
    required this.occupationHouse,
    required this.ownedHouses,
    required this.starLord,
    required this.starLordHouses,
    required this.subLord,
    required this.significatorHouses,
    required this.nodeAgencyHouses,
  });
  final String planet;
  final int occupationHouse;
  final List<int> ownedHouses;
  final String starLord;
  final List<int> starLordHouses;
  final String subLord;
  final List<int> significatorHouses;
  final List<int> nodeAgencyHouses;
}

class KpEventJudgement {
  const KpEventJudgement({
    required this.event,
    required this.supportingHouses,
    required this.opposingHouses,
    required this.supportScore,
    required this.oppositionScore,
    required this.decision,
  });
  final String event;
  final List<int> supportingHouses;
  final List<int> opposingHouses;
  final double supportScore;
  final double oppositionScore;
  final String decision;
}

class KpFullDepthReading {
  const KpFullDepthReading({
    required this.cusps,
    required this.planets,
    required this.rulingPlanets,
  });
  final List<KpCuspResult> cusps;
  final List<KpPlanetSignificator> planets;
  final List<String> rulingPlanets;
}

class KpFullDepthEngine {
  const KpFullDepthEngine();

  static const _lords = <String, String>{
    'मेष': 'मंगल', 'वृषभ': 'शुक्र', 'मिथुन': 'बुध', 'कर्क': 'चंद्र',
    'सिंह': 'सूर्य', 'कन्या': 'बुध', 'तुला': 'शुक्र', 'वृश्चिक': 'मंगल',
    'धनु': 'गुरु', 'मकर': 'शनि', 'कुंभ': 'शनि', 'मीन': 'गुरु',
  };
  static const _kpPlanets = ['सूर्य','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','राहु','केतु'];

  Future<KpFullDepthReading> calculate(KundaliData d) async {
    final cusps = await AstrologyAdvancedService.kpCusps(d);
    final byName = {for (final p in d.planets) p.planet: p};
    final result = <KpPlanetSignificator>[];

    for (final name in _kpPlanets) {
      final p = byName[name];
      if (p == null) continue;
      final star = _starLord(p.degree);
      final sub = _subLord(p.degree, star);
      final starPlanet = byName[star];
      final starHouses = <int>{};
      if (starPlanet != null) {
        starHouses.add(starPlanet.house);
        starHouses.addAll(_ownedHouses(d, starPlanet));
      }
      final own = _ownedHouses(d, p);
      final nodeAgency = (name == 'राहु' || name == 'केतु')
          ? _nodeAgencyHouses(d, p)
          : const <int>[];
      final sig = <int>{...starHouses, p.house, ...own, ...nodeAgency}.toList()..sort();
      result.add(KpPlanetSignificator(
        planet: name,
        occupationHouse: p.house,
        ownedHouses: own,
        starLord: star,
        starLordHouses: starHouses.toList()..sort(),
        subLord: sub,
        significatorHouses: sig,
        nodeAgencyHouses: nodeAgency,
      ));
    }

    return KpFullDepthReading(
      cusps: cusps,
      planets: result,
      rulingPlanets: _rulingPlanets(d),
    );
  }

  KpEventJudgement judgeEvent({
    required KpFullDepthReading reading,
    required String event,
    required List<int> favourableHouses,
    required List<int> unfavourableHouses,
  }) {
    final fav = favourableHouses.toSet();
    final bad = unfavourableHouses.toSet();
    var support = 0.0;
    var opposition = 0.0;
    final supporting = <int>{};
    final opposing = <int>{};
    for (final p in reading.planets) {
      for (final h in p.significatorHouses) {
        if (fav.contains(h)) { support += 1; supporting.add(h); }
        if (bad.contains(h)) { opposition += 1; opposing.add(h); }
      }
    }
    final decision = support == 0 && opposition == 0
        ? 'Insufficient KP signals'
        : support > opposition
            ? 'Supporting KP signals dominate'
            : opposition > support
                ? 'Opposing KP signals dominate'
                : 'Mixed KP signals';
    return KpEventJudgement(
      event: event,
      supportingHouses: supporting.toList()..sort(),
      opposingHouses: opposing.toList()..sort(),
      supportScore: support,
      oppositionScore: opposition,
      decision: decision,
    );
  }

  List<String> _rulingPlanets(KundaliData d) {
    final moon = d.planets.firstWhere((p) => p.planet == 'चंद्र');
    final values = <String>[
      _weekdayLord(d.birthDate.weekday),
      _starLord(moon.degree),
      _signLord(moon.rashi),
      _starLord(d.lagnaDegree),
      _signLord(d.lagnaRashi),
    ];
    final seen = <String>{};
    return values.where((v) => seen.add(v)).toList();
  }

  List<int> _ownedHouses(KundaliData d, PlanetPosition p) {
    final asc = KundaliCalculator.rashis.indexOf(d.lagnaRashi);
    final houses = <int>[];
    for (var i = 0; i < KundaliCalculator.rashis.length; i++) {
      if (_signLord(KundaliCalculator.rashis[i]) == p.planet) {
        houses.add(((i - asc + 12) % 12) + 1);
      }
    }
    return houses;
  }

  List<int> _nodeAgencyHouses(KundaliData d, PlanetPosition node) {
    final result = <int>{node.house};
    final signLord = _signLord(node.rashi);
    final lordPlanet = d.planets.where((p) => p.planet == signLord).toList();
    if (lordPlanet.isNotEmpty) {
      result.add(lordPlanet.first.house);
      result.addAll(_ownedHouses(d, lordPlanet.first));
    }
    return result.toList()..sort();
  }

  String _signLord(String sign) => _lords[sign] ?? '';

  String _starLord(double degree) {
    final idx = (degree / (360.0 / 27.0)).floor().clamp(0, 26);
    const lords = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
    return lords[idx % 9];
  }

  String _subLord(double degree, String starLord) {
    const order = ['केतु','शुक्र','सूर्य','चंद्र','मंगल','राहु','गुरु','शनि','बुध'];
    const years = {'केतु':7.0,'शुक्र':20.0,'सूर्य':6.0,'चंद्र':10.0,'मंगल':7.0,'राहु':18.0,'गुरु':16.0,'शनि':19.0,'बुध':17.0};
    final span = 360.0 / 27.0;
    final offset = (degree % span) / span;
    var cumulative = 0.0;
    final start = order.indexOf(starLord);
    for (var i = 0; i < 9; i++) {
      final lord = order[(start + i) % 9];
      cumulative += years[lord]! / 120.0;
      if (offset <= cumulative) return lord;
    }
    return order[(start + 8) % 9];
  }

  String _weekdayLord(int weekday) =>
      const ['','चंद्र','मंगल','बुध','गुरु','शुक्र','शनि','सूर्य'][weekday];
}
