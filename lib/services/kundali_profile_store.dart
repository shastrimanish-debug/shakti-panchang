import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kundali_model.dart';

class SavedKundaliProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String birthTime;
  final String birthPlace;
  final double latitude;
  final double longitude;
  const SavedKundaliProfile({required this.id,required this.name,required this.birthDate,required this.birthTime,required this.birthPlace,required this.latitude,required this.longitude});
  Map<String,dynamic> toJson()=>{'id':id,'name':name,'birthDate':birthDate.toIso8601String(),'birthTime':birthTime,'birthPlace':birthPlace,'latitude':latitude,'longitude':longitude};
  factory SavedKundaliProfile.fromJson(Map<String,dynamic> j)=>SavedKundaliProfile(id:j['id'] as String,name:j['name'] as String,birthDate:DateTime.parse(j['birthDate'] as String),birthTime:j['birthTime'] as String,birthPlace:j['birthPlace'] as String,latitude:(j['latitude'] as num).toDouble(),longitude:(j['longitude'] as num).toDouble());
}

class KundaliProfileStore {
  static const _key='shakti_saved_kundali_profiles_v1';
  static Future<List<SavedKundaliProfile>> load() async { final p=await SharedPreferences.getInstance(); final raw=p.getStringList(_key)??[]; return raw.map((x)=>SavedKundaliProfile.fromJson(jsonDecode(x) as Map<String,dynamic>)).toList(); }
  static Future<void> save(KundaliData d) async { final p=await SharedPreferences.getInstance(); final list=await load(); final profile=SavedKundaliProfile(id:'${d.name}_${d.birthDate.millisecondsSinceEpoch}',name:d.name,birthDate:d.birthDate,birthTime:d.birthTime,birthPlace:d.birthPlace,latitude:d.latitude,longitude:d.longitude); list.removeWhere((x)=>x.id==profile.id); list.insert(0,profile); await p.setStringList(_key,list.map((x)=>jsonEncode(x.toJson())).toList()); }
  static Future<void> remove(String id) async { final p=await SharedPreferences.getInstance(); final list=await load(); list.removeWhere((x)=>x.id==id); await p.setStringList(_key,list.map((x)=>jsonEncode(x.toJson())).toList()); }

  // Backward-compatible map API used by older screens. This keeps one canonical
  // profile store while preserving profiles written by previous releases.
  static Future<List<Map<String, dynamic>>> getSavedProfiles() async {
    final p = await SharedPreferences.getInstance();
    final raw = <String>[];
    // Legacy storage is kept first because it preserves the newest-first order
    // used by the existing Saved Profiles screen.
    raw.addAll(p.getStringList('saved_kundali_profiles') ?? const <String>[]);
    raw.addAll(p.getStringList(_key) ?? const <String>[]);

    String normalizeDate(dynamic value) {
      final text = (value ?? '').toString().trim();
      if (text.isEmpty) return '';
      final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
      if (iso != null) return '${iso.group(3)}-${iso.group(2)}-${iso.group(1)}';
      return text;
    }

    String normalizeTime(dynamic value) {
      final text = (value ?? '').toString().trim();
      if (text.isEmpty) return '';
      final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(text);
      if (m == null) return text;
      return '${(int.tryParse(m.group(1)!) ?? 0).toString().padLeft(2, '0')}:${m.group(2)}';
    }

    final out = <Map<String, dynamic>>[];
    final seen = <String>{};
    for (final value in raw) {
      try {
        final j = Map<String, dynamic>.from(jsonDecode(value) as Map);
        final name = (j['name'] ?? '').toString();
        final date = normalizeDate(j['date'] ?? j['birthDate']);
        final time = normalizeTime(j['time'] ?? j['birthTime']);
        final place = (j['place'] ?? j['birthPlace'] ?? '').toString();
        final key = '$name|$date|$time|$place';
        if (!seen.add(key)) continue;
        out.add({
          'id': j['id'] ?? key,
          'name': name,
          'place': place,
          'lat': (j['lat'] ?? j['latitude'] as num?)?.toDouble() ?? 0.0,
          'lng': (j['lng'] ?? j['longitude'] as num?)?.toDouble() ?? 0.0,
          'date': date,
          'time': time,
          'birthDate': j['birthDate'] ?? date,
          'birthTime': j['birthTime'] ?? time,
          'birthPlace': j['birthPlace'] ?? place,
        });
      } catch (_) {}
    }
    return out;
  }

  static Future<void> saveProfile(Map<String, dynamic> profileData) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('saved_kundali_profiles') ?? <String>[];
    raw.removeWhere((x) {
      try {
        final old = jsonDecode(x) as Map<String, dynamic>;
        return old['name'] == profileData['name'] && old['date'] == profileData['date'] && old['time'] == profileData['time'];
      } catch (_) { return false; }
    });
    raw.insert(0, jsonEncode(profileData));
    await p.setStringList('saved_kundali_profiles', raw);
  }

  static Future<void> deleteProfile(int index, int totalLength) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList('saved_kundali_profiles') ?? <String>[];
    final realIndex = totalLength - 1 - index;
    if (realIndex >= 0 && realIndex < raw.length) {
      raw.removeAt(realIndex);
      await p.setStringList('saved_kundali_profiles', raw);
    }
  }
  static Future<void> deleteProfileData(Map<String, dynamic> profile) async {
    final p = await SharedPreferences.getInstance();
    final keys = ['saved_kundali_profiles', _key];
    final targetName = (profile['name'] ?? '').toString();
    final targetDate = (profile['date'] ?? profile['birthDate'] ?? '').toString();
    final targetTime = (profile['time'] ?? profile['birthTime'] ?? '').toString();
    final targetPlace = (profile['place'] ?? profile['birthPlace'] ?? '').toString();
    for (final key in keys) {
      final raw = p.getStringList(key) ?? <String>[];
      raw.removeWhere((x) {
        try {
          final j = jsonDecode(x) as Map<String, dynamic>;
          final name = (j['name'] ?? '').toString();
          final date = (j['date'] ?? j['birthDate'] ?? '').toString();
          final time = (j['time'] ?? j['birthTime'] ?? '').toString();
          final place = (j['place'] ?? j['birthPlace'] ?? '').toString();
          return name == targetName && (date == targetDate || date.startsWith(targetDate) || targetDate.startsWith(date)) && time == targetTime && place == targetPlace;
        } catch (_) { return false; }
      });
      await p.setStringList(key, raw);
    }
  }

}
