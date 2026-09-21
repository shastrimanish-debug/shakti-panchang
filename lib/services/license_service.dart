import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'license_persist.dart';

/// 7 दिन निःशुल्क → ₹99/वर्ष। ट्रायल फ़ाइल डिवाइस पर कई जगह सेव ताकि
/// अनइंस्टॉल-रीइंस्टॉल से घड़ी रीसेट न हो। खरीद के बिना विज्ञापन।
class LicenseSnapshot {
  final DateTime trialStart;
  final DateTime? paidUntil;
  const LicenseSnapshot({required this.trialStart, this.paidUntil});

  bool get paid => paidUntil != null && paidUntil!.isAfter(DateTime.now());
  bool get trialActive {
    if (paid) return false;
    return DateTime.now().isBefore(trialStart.add(const Duration(days: 7)));
  }

  int get trialDaysLeft {
    if (!trialActive) return 0;
    return trialStart.add(const Duration(days: 7)).difference(DateTime.now()).inDays + 1;
  }

  bool get entitled => paid || trialActive;
  bool get showAds => !entitled;

  Map<String, dynamic> toJson() => {
        'trialStart': trialStart.millisecondsSinceEpoch,
        'paidUntil': paidUntil?.millisecondsSinceEpoch,
      };

  factory LicenseSnapshot.fromJson(Map<String, dynamic> j) => LicenseSnapshot(
        trialStart: DateTime.fromMillisecondsSinceEpoch((j['trialStart'] as num).toInt()),
        paidUntil: j['paidUntil'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((j['paidUntil'] as num).toInt()),
      );
}

class LicenseService {
  LicenseService._();
  static final LicenseService instance = LicenseService._();

  static const _prefKey = 'sp_license_v2';
  static const _secret = 'shakti-panchang-99-year-uma';

  LicenseSnapshot? _snap;
  final _changes = StreamController<LicenseSnapshot>.broadcast();
  Stream<LicenseSnapshot> get changes => _changes.stream;
  LicenseSnapshot get current =>
      _snap ?? LicenseSnapshot(trialStart: DateTime.now());

  Future<LicenseSnapshot> init() async {
    if (_snap != null) return _snap!;
    final prefs = await SharedPreferences.getInstance();
    final blobs = <String>[
      if (prefs.getString(_prefKey) != null) prefs.getString(_prefKey)!,
      ...await LicensePersist.readAll(),
    ];
    LicenseSnapshot? best;
    for (final raw in blobs) {
      final s = _decode(raw);
      if (s == null) continue;
      if (best == null || s.trialStart.isBefore(best.trialStart)) best = s;
      if (s.paid && (best.paidUntil == null || s.paidUntil!.isAfter(best.paidUntil!))) {
        best = LicenseSnapshot(trialStart: best.trialStart, paidUntil: s.paidUntil);
      }
    }
    best ??= LicenseSnapshot(trialStart: DateTime.now());
    _snap = best;
    await _save(best);
    return best;
  }

  Future<void> markPaid({int days = 365}) async {
    final cur = await init();
    final until = DateTime.now().add(Duration(days: days));
    final next = LicenseSnapshot(trialStart: cur.trialStart, paidUntil: until);
    _snap = next;
    await _save(next);
  }

  Future<void> _save(LicenseSnapshot s) async {
    final raw = _encode(s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, raw);
    await LicensePersist.write(raw);
    if (!_changes.isClosed) _changes.add(s);
  }

  String _encode(LicenseSnapshot s) {
    final body = jsonEncode(s.toJson());
    return jsonEncode({'body': body, 'sig': _sig(body)});
  }

  LicenseSnapshot? _decode(String raw) {
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final body = m['body'] as String;
      if (m['sig'] != _sig(body)) return null;
      return LicenseSnapshot.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  String _sig(String body) {
    var h = 5381;
    for (final c in (_secret + body).codeUnits) {
      h = ((h << 5) + h + c) & 0x7fffffff;
    }
    return h.toRadixString(16);
  }
}
