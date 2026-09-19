import 'package:shared_preferences/shared_preferences.dart';

class CalcSettings {
  final String ayanamsha; // lahiri | raman | kp
  final String nodeType; // mean | true
  final String houseSystem; // whole | sripati
  const CalcSettings({
    this.ayanamsha = 'lahiri',
    this.nodeType = 'mean',
    this.houseSystem = 'whole',
  });

  CalcSettings copyWith({String? ayanamsha, String? nodeType, String? houseSystem}) =>
      CalcSettings(
        ayanamsha: ayanamsha ?? this.ayanamsha,
        nodeType: nodeType ?? this.nodeType,
        houseSystem: houseSystem ?? this.houseSystem,
      );
}

class CalcSettingsStore {
  static const _kAya = 'sp_calc_ayanamsha';
  static const _kNode = 'sp_calc_node';
  static const _kHouse = 'sp_calc_house';

  Future<CalcSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return CalcSettings(
      ayanamsha: p.getString(_kAya) ?? 'lahiri',
      nodeType: p.getString(_kNode) ?? 'mean',
      houseSystem: p.getString(_kHouse) ?? 'whole',
    );
  }

  Future<void> save(CalcSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kAya, s.ayanamsha);
    await p.setString(_kNode, s.nodeType);
    await p.setString(_kHouse, s.houseSystem);
  }
}
