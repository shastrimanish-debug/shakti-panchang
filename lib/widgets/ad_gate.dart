import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/premium_screen.dart';
import '../services/license_service.dart';

/// ट्रायल खत्म + बिना सदस्यता: हर पेज खोलने पर विज्ञापन, फिर पेज।
class AdGate {
  static Future<bool> beforeOpen(BuildContext context) async {
    final lic = await LicenseService.instance.init();
    if (!context.mounted) return false;
    if (lic.entitled) return true;
    final go = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('7 दिन का परीक्षण समाप्त'),
        content: const Text(
          'पूरा ऐप चलाने के लिए ₹99/वर्ष सदस्यता लें। '
          'अभी नहीं तो हर पन्ने पर विज्ञापन आएगा।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'ad'),
            child: const Text('विज्ञापन देखकर चलूँ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'pay'),
            child: const Text('₹99 / वर्ष'),
          ),
        ],
      ),
    );
    if (!context.mounted) return false;
    if (go == 'pay') {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
      final again = await LicenseService.instance.init();
      if (again.entitled) return true;
      if (!context.mounted) return false;
    }
    await _showAd(context);
    return context.mounted;
  }

  static Future<void> _showAd(BuildContext context) async {
    var left = 5;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      pageBuilder: (ctx, _, __) {
        return _CountdownAd(
          seconds: left,
          onDone: () => Navigator.pop(ctx),
          onSubscribe: () {
            Navigator.pop(ctx);
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
          },
        );
      },
    );
  }
}

class _CountdownAd extends StatefulWidget {
  final int seconds;
  final VoidCallback onDone;
  final VoidCallback onSubscribe;
  const _CountdownAd({required this.seconds, required this.onDone, required this.onSubscribe});

  @override
  State<_CountdownAd> createState() => _CountdownAdState();
}

class _CountdownAdState extends State<_CountdownAd> {
  late int _left;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _left = widget.seconds;
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        widget.onDone();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1208),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(_left > 0 ? 'विज्ञापन $_left सेकंड' : 'बंद करें',
                    style: const TextStyle(color: Colors.white70)),
              ),
              const Spacer(),
              const Text('विज्ञापन', style: TextStyle(color: Colors.white54, letterSpacing: 4)),
              const SizedBox(height: 16),
              const Icon(Icons.workspace_premium, size: 72, color: Color(0xFFFFC107)),
              const SizedBox(height: 16),
              const Text('शक्ति पंचांग प्रीमियम',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('बिना विज्ञापन • उमा • पूरा पंचांग • ₹99/वर्ष',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: widget.onSubscribe,
                child: const Text('अभी सदस्यता लें — ₹99'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
