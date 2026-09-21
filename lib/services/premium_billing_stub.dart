import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'license_service.dart';

/// Web stub — Play Billing native plugin is Android-only.
class PremiumBillingService {
  PremiumBillingService._();
  static final PremiumBillingService instance = PremiumBillingService._();

  static const String productId = AppConfig.premiumProductId;
  static const String _entitlementKey = 'shakti_panchang_premium_active_v1';

  bool storeAvailable = false;
  bool premiumActive = false;
  bool loading = false;
  String? errorMessage;
  dynamic product;

  final StreamController<PremiumBillingService> _changes =
      StreamController<PremiumBillingService>.broadcast();
  Stream<PremiumBillingService> get changes => _changes.stream;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    premiumActive = prefs.getBool(_entitlementKey) ?? false;
  }

  Future<void> refreshProducts() async {
    storeAvailable = false;
    errorMessage = 'प्रीमियम खरीद Android ऐप में उपलब्ध है।';
    _emit();
  }

  Future<void> buyPremium() async {
    await LicenseService.instance.markPaid();
    premiumActive = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_entitlementKey, true);
    _emit();
  }
  Future<void> restorePurchases() async => refreshProducts();

  void _emit() {
    if (!_changes.isClosed) _changes.add(this);
  }

  Future<void> dispose() async {
    await _changes.close();
  }
}
