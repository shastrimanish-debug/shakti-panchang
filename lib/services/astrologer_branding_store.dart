import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/astrologer_branding.dart';

class AstrologerBrandingStore {
  static const _key = 'astrologer_branding_v1';

  static Future<AstrologerBranding> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const AstrologerBranding();
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) return AstrologerBranding.fromJson(map);
      if (map is Map) {
        return AstrologerBranding.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (_) {}
    return const AstrologerBranding();
  }

  static Future<void> save(AstrologerBranding branding) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(branding.toJson()));
  }
}
