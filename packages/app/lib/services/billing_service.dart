import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// What happened to a purchase attempt, surfaced to the paywall UI.
enum BillingEvent { pending, purchased, restored, error, canceled }

/// Wraps the Play Billing / StoreKit purchase flow via `in_app_purchase`.
///
/// Two products, both granting full premium for v1:
///  - [monthlyId]  — auto-renewing monthly subscription
///  - [lifetimeId] — one-time non-consumable "lifetime CAIIB" unlock
///
/// Entitlement is reported via [onPremiumUnlocked]; the app persists it.
///
/// NOTE: this acknowledges + persists locally. Server-side receipt
/// verification (a Cloud Function validating the purchase token) is the
/// recommended hardening step before scaling — see docs.
class BillingService {
  static const monthlyId = 'caiib_premium_monthly';
  static const lifetimeId = 'caiib_premium_lifetime';
  static const _ids = <String>{monthlyId, lifetimeId};

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final StreamController<BillingEvent> _events =
      StreamController<BillingEvent>.broadcast();

  /// Whether the store is reachable on this device (false on web/desktop/test).
  bool available = false;

  /// Product details (localized price strings, etc.) once queried.
  List<ProductDetails> products = [];

  /// Invoked when a premium purchase is confirmed (purchased or restored).
  void Function()? onPremiumUnlocked;

  /// UI-facing purchase lifecycle events.
  Stream<BillingEvent> get events => _events.stream;

  ProductDetails? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> init() async {
    try {
      available = await _iap.isAvailable();
      if (!available) return;
      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onDone: () => _sub?.cancel(),
        onError: (Object e) => debugPrint('purchaseStream error: $e'),
      );
      final resp = await _iap.queryProductDetails(_ids);
      products = resp.productDetails;
      if (resp.error != null) {
        debugPrint('queryProductDetails error: ${resp.error}');
      }
    } catch (e) {
      available = false;
      debugPrint('BillingService.init failed: $e');
    }
  }

  /// Begin a purchase. Subscriptions and non-consumables both go through
  /// `buyNonConsumable` in the plugin (the store manages renewal/entitlement).
  Future<void> buy(ProductDetails product) async {
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  /// Re-deliver any previously-owned entitlements (required by store policy).
  Future<void> restore() => _iap.restorePurchases();

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _events.add(BillingEvent.pending);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_ids.contains(p.productID)) {
            final ok = await _verify(p);
            if (ok) {
              onPremiumUnlocked?.call();
              _events.add(p.status == PurchaseStatus.restored
                  ? BillingEvent.restored
                  : BillingEvent.purchased);
            } else {
              _events.add(BillingEvent.error);
            }
          }
          break;
        case PurchaseStatus.error:
          _events.add(BillingEvent.error);
          break;
        case PurchaseStatus.canceled:
          _events.add(BillingEvent.canceled);
          break;
      }
      // Must always finish the transaction, or the store keeps re-delivering it.
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  /// Until the Play service account is linked in Play Console, server
  /// verification will fail; trust the client so internal testing isn't blocked.
  /// Flip to `false` once `verifyPlayPurchase` is configured and tested.
  static const bool _allowUnverifiedFallback = true;

  /// Server-side receipt verification via the `verifyPlayPurchase` Cloud
  /// Function (validates against the Play Developer API + records entitlement
  /// in Firestore). Falls back to client-trust while not yet configured.
  Future<bool> _verify(PurchaseDetails p) async {
    try {
      final res = await FirebaseFunctions.instance
          .httpsCallable('verifyPlayPurchase')
          .call(<String, dynamic>{
        'productId': p.productID,
        'purchaseToken': p.verificationData.serverVerificationData,
        'isSubscription': p.productID == monthlyId,
      });
      final data = res.data;
      return data is Map && data['valid'] == true;
    } catch (e) {
      debugPrint('verifyPlayPurchase unavailable ($e) — '
          'granting unverified=$_allowUnverifiedFallback');
      return _allowUnverifiedFallback;
    }
  }

  void dispose() {
    _sub?.cancel();
    _events.close();
  }
}
