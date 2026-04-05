import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lazurite/features/tips/data/purchase_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockInAppPurchase extends Mock implements InAppPurchase {}

void main() {
  late MockInAppPurchase iap;
  late StreamController<List<PurchaseDetails>> purchaseController;
  late ProductDetails product;
  late PurchaseDetails purchase;

  setUp(() {
    iap = MockInAppPurchase();
    purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
    product = ProductDetails(
      id: PurchaseRepository.coffeeProductId,
      title: 'Coffee',
      description: 'Small tip',
      price: r'$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD',
      currencySymbol: r'$',
    );
    purchase = PurchaseDetails(
      productID: product.id,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'local',
        serverVerificationData: 'server',
        source: 'test',
      ),
      transactionDate: '123',
      status: PurchaseStatus.purchased,
    );
    registerFallbackValue(PurchaseParam(productDetails: product));
    registerFallbackValue(purchase);

    when(() => iap.purchaseStream).thenAnswer((_) => purchaseController.stream);
    when(() => iap.isAvailable()).thenAnswer((_) async => true);
    when(
      () => iap.queryProductDetails(PurchaseRepository.productIds),
    ).thenAnswer((_) async => ProductDetailsResponse(productDetails: [product], notFoundIDs: const []));
    when(() => iap.buyConsumable(purchaseParam: any(named: 'purchaseParam'))).thenAnswer((_) async => true);
    when(() => iap.completePurchase(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await purchaseController.close();
  });

  test('delegates store availability checks', () async {
    final repository = InAppPurchaseRepository(iap: iap);

    expect(await repository.isAvailable(), isTrue);
    verify(() => iap.isAvailable()).called(1);
  });

  test('queries the configured tip products', () async {
    final repository = InAppPurchaseRepository(iap: iap);

    final result = await repository.fetchProducts();

    expect(result, [product]);
    verify(() => iap.queryProductDetails(PurchaseRepository.productIds)).called(1);
  });

  test('starts a consumable purchase', () async {
    final repository = InAppPurchaseRepository(iap: iap);

    await repository.buyTip(product);

    verify(() => iap.buyConsumable(purchaseParam: any(named: 'purchaseParam'))).called(1);
  });

  test('exposes the purchase stream and completes purchases', () async {
    final repository = InAppPurchaseRepository(iap: iap);
    final emitted = <List<PurchaseDetails>>[];
    final sub = repository.purchaseStream.listen(emitted.add);
    purchaseController.add([purchase]);
    await Future<void>.delayed(Duration.zero);

    await repository.completePurchase(purchase);

    expect(emitted, [
      [purchase],
    ]);
    verify(() => iap.completePurchase(purchase)).called(1);
    await sub.cancel();
  });
}
