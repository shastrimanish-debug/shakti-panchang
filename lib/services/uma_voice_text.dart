/// बोलने के लिए सादी भारतीय हिन्दी। अंग्रेज़ी शब्द हटाओ।
class UmaVoiceText {
  static const _en = {
    'data': 'जानकारी',
    'app': 'ऐप',
    'software': 'ऐप',
    'module': 'हिस्सा',
    'modules': 'हिस्से',
    'pdf': 'पी डी एफ',
    'kp': 'के पी',
    'uma': 'उमा',
    'shakti panchang': 'शक्ति पंचांग',
    'choghadiya': 'चौघड़िया',
    'muhurat': 'मुहूर्त',
    'panchang': 'पंचांग',
    'kundali': 'कुंडली',
    'jaimini': 'जैमिनी',
    'profile': 'खाता',
    'saved': 'सेव',
    'feature': 'सुविधा',
    'features': 'सुविधाएँ',
  };

  static String forSpeech(String raw) {
    var t = raw.replaceAll(RegExp(r'[*#`_]'), ' ');
    t = t.replaceAll('\n', '। ');
    _en.forEach((k, v) {
      t = t.replaceAll(RegExp(k, caseSensitive: false), v);
    });
    t = t
        .replaceAll('बताऊँगी', 'बताती हूँ')
        .replaceAll('समझाएगी', 'समझाती हूँ')
        .replaceAll('देखेंगे', 'देखो')
        .replaceAll('आप मुझसे', 'मुझसे')
        .replaceAll(RegExp(r'[A-Za-z]{2,}'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'।+'), '।')
        .trim();
    if (t.length > 280) {
      final cut = t.substring(0, 280);
      final last = cut.lastIndexOf('।');
      t = last > 60 ? cut.substring(0, last + 1) : cut;
    }
    return t;
  }

  static List<String> chunks(String t, [int max = 160]) {
    if (t.length <= max) return [t];
    final out = <String>[];
    var buf = StringBuffer();
    for (final part in t.split('।')) {
      final s = part.trim();
      if (s.isEmpty) continue;
      if (buf.length + s.length > max && buf.isNotEmpty) {
        out.add(buf.toString().trim());
        buf = StringBuffer();
      }
      buf.write('$s। ');
    }
    if (buf.isNotEmpty) out.add(buf.toString().trim());
    return out;
  }
}
