import 'package:flutter/material.dart';
import '../config/app_config.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⭐ Shakti Panchang Premium'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Image.asset('assets/shakti_panchang_logo.png',
                      width: 120, height: 120),
                  const SizedBox(height: 10),
                  const Text(
                    AppConfig.planName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppConfig.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    AppConfig.priceLabel,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    AppConfig.planDescription,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  ...AppConfig.features.map((x) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.check_circle_rounded),
                    title: Text(x),
                  )),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('₹99 / वर्ष'),
                        content: const Text(
                          'Commercial purchase flow तैयार है। '
                          'Live Play Store/App Store payment gateway को SDK/build '
                          'और store-account setup के बाद connect किया जाएगा।',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('ठीक है'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium_rounded),
                    label: const Text('₹99 / वर्ष — Premium लें'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              AppConfig.poweredBy,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'नोट: ₹99/year pricing app में commercial plan के रूप में configured है। '
                'Actual payment/restore/subscription verification को production store '
                'billing integration के साथ जोड़ना होगा।',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
