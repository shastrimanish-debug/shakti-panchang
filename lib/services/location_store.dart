import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedLocation {
  final String name;
  final double latitude;
  final double longitude;

  const SavedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory SavedLocation.fromJson(Map<String, dynamic> j) => SavedLocation(
    name: j['name'] as String,
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
  );
}

class LocationStore {
  static const _key = 'shakti_saved_locations_v1';
  static const _selectedKey = 'shakti_selected_location_v1';

  Future<List<SavedLocation>> all() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_key) ?? const [];
    return raw.map((x) {
      try {
        return SavedLocation.fromJson(jsonDecode(x) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<SavedLocation>().toList();
  }

  Future<void> save(SavedLocation location) async {
    final p = await SharedPreferences.getInstance();
    final list = await all();
    final filtered = list.where((x) =>
      x.name.toLowerCase() != location.name.toLowerCase()).toList();
    filtered.insert(0, location);
    await p.setStringList(_key, filtered.map((x) => jsonEncode(x.toJson())).toList());
  }

  Future<void> remove(SavedLocation location) async {
    final p = await SharedPreferences.getInstance();
    final list = await all();
    list.removeWhere((x) =>
      x.name.toLowerCase() == location.name.toLowerCase() &&
      (x.latitude - location.latitude).abs() < 0.000001 &&
      (x.longitude - location.longitude).abs() < 0.000001);
    await p.setStringList(_key, list.map((x) => jsonEncode(x.toJson())).toList());
  }

  Future<void> setSelected(SavedLocation location) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_selectedKey, jsonEncode(location.toJson()));
  }

  Future<SavedLocation?> selected() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_selectedKey);
    if (raw == null) return null;
    try {
      return SavedLocation.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
