import 'package:flutter/material.dart';
import '../services/deep_daily_rashifal_service.dart';
import '../services/license_service.dart';
import 'premium_screen.dart';

const Color _reportBg = Color(0xFFF4E8D1);
const Color _reportCard = Color(0xFFFAF2E4);
const Color _reportBrown = Color(0xFF5C3A21);

/// Long-form premium daily report assembled from the real personalized
/// calculation layers already used by Daily Rashifal.
class PremiumDailyReportScreen extends StatefulWidget {
  final DeepDailyReading reading;
  const PremiumDailyReportScreen({super.key, required this.reading});

  @override
  State<PremiumDailyReportScreen> createState() => _PremiumDailyReportScreenState();
}

class _PremiumDailyReportScreenState extends State<PremiumDailyReportScreen> {
  bool _checking = true;
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    _checkEntitlement();
  }

  Future<void> _checkEntitlement() async {
    final license = await LicenseService.instance.init();
    if (!mounted) return;
    if (!license.entitled) {
      setState(() { _checking = false; _allowed = false; });
      return;
    }
    setState(() { _checking = false; _allowed = true; });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!_allowed) {
      return Scaffold(
        appBar: AppBar(title: const Text('Premium Daily Report')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_rounded, size: 64, color: _reportBrown),
              const SizedBox(height: 12),
              const Text('यह विस्तृत रिपोर्ट Premium में उपलब्ध है।', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Premium देखें'),
              ),
            ]),
          ),
        ),
      );
    }
    final d = widget.reading;
    return Scaffold(
      backgroundColor: _reportBg,
      appBar: AppBar(
        backgroundColor: _reportBrown,
        foregroundColor: Colors.white,
        title: const Text('Premium Daily Report', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _section('व्यक्तिगत आधार', [
            'कुंडली: ${d.profileName}',
            'तारीख: ${d.date.day}-${d.date.month}-${d.date.year}',
            'दशा: ${d.dasha}',
          ]),
          _section('मुख्य निष्कर्ष', [d.headline]),
          _section('करियर', [d.career]),
          _section('धन', [d.money]),
          _section('संबंध', [d.relationship]),
          _section('स्वास्थ्य', [d.health]),
          _section('सूक्ष्म समय-स्तर', [
            'सूक्ष्मदशा: ${d.sukshmaDasha ?? 'उपलब्ध नहीं'}',
            'प्राणदशा: ${d.pranaDasha ?? 'उपलब्ध नहीं'}',
          ]),
          _section('अष्टकवर्ग Daily Layer', [
            d.ashtakavargaSummary,
            'मुख्य transit strength: ${d.ashtakavargaStrongest}',
          ]),
          _section('Lucky Calculation', [
            'शुभ अंक: ${d.luckyNumbers.join(' • ')}',
            'Method: ${d.luckyMethod}',
            'Basis: ${d.luckyBasis.join(' | ')}',
          ]),
          _section('गोचर', [d.transitSummary]),
          _section('क्यों?', d.evidence),
          const Card(
            color: _reportCard,
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text('यह रिपोर्ट पारंपरिक वैदिक ज्योतिषीय गणना और interpretation पर आधारित है। इसे निश्चित भविष्यवाणी या चिकित्सा/वित्तीय सलाह न मानें।', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: Text('Powered by SHIV SHAKTI', style: TextStyle(fontWeight: FontWeight.w900, color: _reportBrown))),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> lines) => Card(
    color: _reportCard,
    margin: const EdgeInsets.only(bottom: 10),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: _reportBrown)),
        const SizedBox(height: 8),
        ...lines.map((x) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $x'))),
      ]),
    ),
  );
}
