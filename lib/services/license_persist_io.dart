import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LicensePersist {
  static const _name = 'shakti_panchang.lic';

  static Future<void> write(String raw) async {
    final paths = <String>[
      '/storage/emulated/0/Download/.$_name',
      '/storage/emulated/0/Documents/.$_name',
    ];
    try {
      final dir = await getApplicationDocumentsDirectory();
      paths.add('${dir.path}/$_name');
    } catch (_) {}
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) paths.add('${ext.path}/$_name');
    } catch (_) {}
    for (final p in paths) {
      try {
        final f = File(p);
        await f.parent.create(recursive: true);
        await f.writeAsString(raw, flush: true);
      } catch (_) {}
    }
  }

  static Future<List<String>> readAll() async {
    final out = <String>[];
    final paths = <String>[
      '/storage/emulated/0/Download/.$_name',
      '/storage/emulated/0/Documents/.$_name',
    ];
    try {
      final dir = await getApplicationDocumentsDirectory();
      paths.add('${dir.path}/$_name');
    } catch (_) {}
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) paths.add('${ext.path}/$_name');
    } catch (_) {}
    for (final p in paths) {
      try {
        final f = File(p);
        if (await f.exists()) {
          final s = await f.readAsString();
          if (s.trim().isNotEmpty) out.add(s);
        }
      } catch (_) {}
    }
    return out;
  }
}
