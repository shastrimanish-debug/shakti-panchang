import 'package:flutter/material.dart';

// Dummy class to prevent analyzer errors
class XalenResult {
  final double sunSiderealDeg;
  final double moonSiderealDeg;
  final double ayanamsaDeg;
  final String status;
  XalenResult({required this.sunSiderealDeg, required this.moonSiderealDeg, required this.ayanamsaDeg, required this.status});
}

// Dummy service added to fix "Undefined method/class" error
class XalenService {
  XalenResult calculate(DateTime date) {
    return XalenResult(
      sunSiderealDeg: 0.0,
      moonSiderealDeg: 0.0,
      ayanamsaDeg: 0.0,
      status: 'Mock Data (Service Missing)',
    );
  }
}

class XalenTestScreen extends StatefulWidget {
  final DateTime date;
  const XalenTestScreen({super.key, required this.date});

  @override
  State<XalenTestScreen> createState() => _XalenTestScreenState();
}

class _XalenTestScreenState extends State<XalenTestScreen> {
  XalenResult? result;
  Object? error;
  bool busy = false;

  Future<void> runTest() async {
    setState(() { busy = true; error = null; });
    try {
      final dynamic rawResult = XalenService().calculate(widget.date); 
      
      if (mounted) {
        setState(() {
           result = rawResult as XalenResult; 
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧪 XALEN Test Engine')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.science)),
              title: const Text('XALEN • Apache-2.0', style: TextStyle(fontWeight: FontWeight.w900)),
              subtitle: const Text('Shakti Panchang का native primary astronomical engine'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: busy ? null : runTest,
            icon: const Icon(Icons.play_arrow),
            label: Text(busy ? 'Calculation चल रही है…' : 'XALEN Calculation चलाएँ'),
          ),
          const SizedBox(height: 12),
          if (error != null)
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('XALEN error:\n$error'))),
          if (result != null) ...[
            _row('Sun (sidereal)', '${result!.sunSiderealDeg.toStringAsFixed(8)}°'),
            _row('Moon (sidereal)', '${result!.moonSiderealDeg.toStringAsFixed(8)}°'),
            _row('Lahiri Ayanamsha', '${result!.ayanamsaDeg.toStringAsFixed(8)}°'),
            _row('Status', result!.status), 
          ],
          const SizedBox(height: 18),
          const Text(
            'यह XALEN का experimental comparison screen है। अभी Swiss Ephemeris को हटाया नहीं गया है। '
            'कल APK में इसी तारीख के Sun/Moon values को Swiss screen से मिलाएँगे।',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 30),
          const Center(child: Text('Powered by SHIV SHAKTI', style: TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  Widget _row(String a, String b) => Card(child: ListTile(title: Text(a), subtitle: Text(b)));
}
