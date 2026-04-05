import 'package:in_app_purchase/in_app_purchase.dart';

/// Abstract purchase repository — wraps [InAppPurchase.instance] so it can be
/// mocked in unit tests.
abstract class PurchaseRepository {
  /// Product IDs for the two tip tiers.
  static const String coffeeProductId = 'tip_coffee';
  static const String latteProductId = 'tip_latte';
  static const Set<String> productIds = {coffeeProductId, latteProductId};

  /// Returns true if the underlying store is available and can process
  /// purchases.
  Future<bool> isAvailable();

  /// Fetches [ProductDetails] for both tip products from the store.
  Future<List<ProductDetails>> fetchProducts();

  /// Initiates a consumable purchase for [product].
  Future<void> buyTip(ProductDetails product);

  /// Broadcast stream of purchase updates.
  Stream<List<PurchaseDetails>> get purchaseStream;

  /// Must be called after verifying and delivering every terminal purchase.
  Future<void> completePurchase(PurchaseDetails details);
}

/// Production implementation backed by [InAppPurchase.instance].
class InAppPurchaseRepository implements PurchaseRepository {
  InAppPurchaseRepository({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<List<ProductDetails>> fetchProducts() async {
    final response = await _iap.queryProductDetails(PurchaseRepository.productIds);
    return response.productDetails;
  }

  @override
  Future<void> buyTip(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param);
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<void> completePurchase(PurchaseDetails details) => _iap.completePurchase(details);
}
