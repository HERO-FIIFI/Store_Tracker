import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium';
  static const String premiumProductId = 'store_tracker_premium';

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  // Premium features flags
  bool _isPremium = false;

  bool get isPremium => _isPremium;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    // Check if in-app purchases are available
    _isAvailable = await _iap.isAvailable();

    // Load premium status from local storage
    await _loadPremiumStatus();

    if (_isAvailable) {
      // Set up purchase listener
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) => print('Purchase error: $error'),
      );

      // Load products
      await _loadProducts();

      // Restore previous purchases
      await restorePurchases();
    }
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    _isPremium = isPremium;
  }

  Future<void> _loadProducts() async {
    final productIds = <String>{premiumProductId};
    final response = await _iap.queryProductDetails(productIds);

    if (response.error != null) {
      print('Error loading products: ${response.error}');
      return;
    }

    _products = response.productDetails;
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // Show error
        print('Purchase error: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Verify and deliver product
        _verifyAndDeliverPurchase(purchaseDetails);
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchaseDetails) async {
    // In production, verify with your backend server
    // For now, we'll just mark as premium locally
    if (purchaseDetails.productID == premiumProductId) {
      await _savePremiumStatus(true);
    }
  }

  Future<bool> buyPremium() async {
    if (!_isAvailable || _products.isEmpty) {
      return false;
    }

    final product = _products.firstWhere(
      (p) => p.id == premiumProductId,
      orElse: () => throw Exception('Premium product not found'),
    );

    final purchaseParam = PurchaseParam(productDetails: product);
    try {
      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      print('Purchase failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Restore failed: $e');
    }
  }

  // Check if a specific premium feature is available
  bool canUseFeature(PremiumFeature feature) {
    // For now, all premium features require premium subscription
    return _isPremium;
  }

  // For testing purposes - manually set premium status
  Future<void> setPremiumForTesting(bool isPremium) async {
    await _savePremiumStatus(isPremium);
  }

  void dispose() {
    _subscription.cancel();
  }
}

enum PremiumFeature {
  cloudSync,
  advancedReports,
  multipleBranches,
  exportData,
  customBranding,
}