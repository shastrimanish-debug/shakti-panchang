import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/premium_billing_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _billing = PremiumBillingService.instance;
  StreamSubscription<PremiumBillingService>? _changes;

  @override
  void initState() {
    super.initState();
    _changes = _billing.changes.listen((_) {
      if (mounted) setState(() {});
    });
    unawaited(_billing.init());
  }

  @override
  void dispose() {
    _changes?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = _billing.product?.price ?? AppConfig.priceLabel;
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Shakti Panchang Premium')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Image.asset('assets/shakti_panchang_logo.png', width: 120, height: 120),
                  const SizedBox(height: 10),
                  const Text(AppConfig.planName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text(AppConfig.tagline, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 18),
                  Text(price, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  const Text(AppConfig.planDescription, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  ...AppConfig.features.map((x) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.check_circle_rounded),
                        title: Text(x),
                      )),
                  const SizedBox(height: 10),
                  if (_billing.premiumActive)
                    const Card(
                      child: ListTile(
                        leading: Icon(Icons.verified_rounded),
                        title: Text('Premium active'),
                        subtitle: Text('Your Google Play purchase is recognised on this device.'),
                      ),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _billing.loading ? null : _buy,
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: Text(_billing.loading ? 'Please wait…' : 'Subscribe — $price'),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _billing.loading ? null : _restore,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Restore purchase'),
                  ),
                  if (_billing.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _billing.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(child: Text(AppConfig.poweredBy, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13))),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Payment is processed securely by Google Play. The app does not receive your card, UPI or other payment instrument details. The subscription product must be active in Google Play Console before purchase testing.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _buy() async {
    await _billing.buyPremium();
    if (!mounted) return;
    if (_billing.premiumActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium activated.')));
    }
  }

  Future<void> _restore() async {
    await _billing.restorePurchases();
    if (!mounted) return;
    if (_billing.premiumActive) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Purchase restored.')));
    }
  }
}
