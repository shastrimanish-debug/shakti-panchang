import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Google Play subscription integration for Shakti Panchang Premium.
///
/// The product ID must exactly match the active subscription/base plan in
/// Google Play Console. Google Play handles the user's payment instrument.
/// This service stores the latest client-side entitlement locally so the UI
/// remains useful offline. Production deployments should additionally verify
/// purchase tokens on a trusted server before granting server-side benefits.
class PremiumBillingService {
  PremiumBillingService._();
  static final PremiumBillingService instance = PremiumBillingService._();

  static const String productId = AppConfig.premiumProductId;
  static const String _entitlementKey = 'shakti_panchang_premium_active_v1';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? product;
  bool storeAvailable = false;
  bool premiumActive = false;
  bool loading = false;
  String? errorMessage;

  final StreamController<PremiumBillingService> _changes =
      StreamController<PremiumBillingService>.broadcast();
  Stream<PremiumBillingService> get changes => _changes.stream;

  Future<void> init() async {
    if (_purchaseSubscription != null) return;
    final prefs = await SharedPreferences.getInstance();
    premiumActive = prefs.getBool(_entitlementKey) ?? false;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error) {
        errorMessage = error.toString();
        loading = false;
        _emit();
      },
    );

    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    loading = true;
    errorMessage = null;
    _emit();

    try {
      storeAvailable = await _iap.isAvailable();
      if (!storeAvailable) {
        errorMessage = 'Google Play billing is not available on this device.';
        return;
      }

      final response = await _iap.queryProductDetails({productId});
      if (response.error != null) {
        errorMessage = response.error!.message;
        return;
      }
      if (response.notFoundIDs.contains(productId) ||
          response.productDetails.isEmpty) {
        errorMessage =
            'Premium product is not available yet. Activate the subscription '
            'base plan in Google Play Console.';
        return;
      }
      product = response.productDetails.firstWhere(
        (item) => item.id == productId,
        orElse: () => response.productDetails.first,
      );
    } finally {
      loading = false;
      _emit();
    }
  }

  Future<void> buyPremium() async {
    await init();
    if (product == null) {
      await refreshProducts();
    }
    final item = product;
    if (item == null) {
      return;
    }

    loading = true;
    errorMessage = null;
    _emit();

    try {
      // Google Play subscriptions are purchased through the non-consumable
      // purchase API in Flutter's in_app_purchase abstraction.
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: item),
      );
    } catch (e) {
      loading = false;
      errorMessage = 'Purchase could not be started: $e';
      _emit();
    }
  }

  Future<void> restorePurchases() async {
    await init();
    loading = true;
    errorMessage = null;
    _emit();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      loading = false;
      errorMessage = 'Restore failed: $e';
      _emit();
      return;
    }
    // The purchase stream may emit asynchronously; keep the current state
    // until an update arrives, but do not leave the UI in a spinner if the
    // store has nothing to restore.
    loading = false;
    _emit();
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;

      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _setPremiumActive(true);
          break;
        case PurchaseStatus.error:
          errorMessage = purchase.error?.message ?? 'Purchase failed.';
          break;
        case PurchaseStatus.canceled:
          errorMessage = 'Purchase cancelled.';
          break;
        case PurchaseStatus.pending:
          errorMessage = 'Purchase is pending in Google Play.';
          break;
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
    loading = false;
    _emit();
  }

  Future<void> _setPremiumActive(bool active) async {
    premiumActive = active;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_entitlementKey, active);
  }

  void _emit() {
    if (!_changes.isClosed) _changes.add(this);
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    await _changes.close();
  }
}
