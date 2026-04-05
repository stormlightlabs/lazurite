import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lazurite/core/database/app_database.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_state.dart';
import 'package:lazurite/features/tips/data/purchase_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

PurchaseDetails _purchase({
  required PurchaseStatus status,
  String productId = PurchaseRepository.coffeeProductId,
  bool pendingCompletePurchase = false,
  String? errorMessage,
}) {
  final purchase = PurchaseDetails(
    productID: productId,
    verificationData: PurchaseVerificationData(
      localVerificationData: 'local',
      serverVerificationData: 'server',
      source: 'test',
    ),
    transactionDate: '123',
    status: status,
  );
  purchase.pendingCompletePurchase = pendingCompletePurchase;
  if (errorMessage != null) {
    purchase.error = IAPError(source: 'test', code: 'purchase-error', message: errorMessage);
  }
  return purchase;
}

void main() {
  late AppDatabase database;
  late SettingsCubit settingsCubit;
  late MockPurchaseRepository repository;
  late StreamController<List<PurchaseDetails>> purchaseController;
  late ProductDetails coffee;

  setUp(() async {
    database = AppDatabase(executor: NativeDatabase.memory());
    settingsCubit = SettingsCubit(database: database);
    repository = MockPurchaseRepository();
    purchaseController = StreamController<List<PurchaseDetails>>.broadcast();
    coffee = ProductDetails(
      id: PurchaseRepository.coffeeProductId,
      title: 'Coffee',
      description: 'Small tip',
      price: r'$1.99',
      rawPrice: 1.99,
      currencyCode: 'USD',
      currencySymbol: r'$',
    );
    registerFallbackValue(
      PurchaseDetails(
        productID: coffee.id,
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local',
          serverVerificationData: 'server',
          source: 'test',
        ),
        transactionDate: '123',
        status: PurchaseStatus.purchased,
      ),
    );

    when(() => repository.purchaseStream).thenAnswer((_) => purchaseController.stream);
    when(() => repository.isAvailable()).thenAnswer((_) async => true);
    when(() => repository.fetchProducts()).thenAnswer((_) async => [coffee]);
    when(() => repository.buyTip(coffee)).thenAnswer((_) async {});
    when(() => repository.completePurchase(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await purchaseController.close();
    await settingsCubit.close();
    await database.close();
  });

  test('loadProducts exposes available products', () async {
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    await cubit.loadProducts();

    expect(cubit.state.storeStatus, TipStoreStatus.available);
    expect(cubit.state.products, [coffee]);

    await cubit.close();
  });

  test('loadProducts reports unavailable store', () async {
    when(() => repository.isAvailable()).thenAnswer((_) async => false);
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    await cubit.loadProducts();

    expect(cubit.state.storeStatus, TipStoreStatus.unavailable);

    await cubit.close();
  });

  test('purchaseTip reports request errors', () async {
    when(() => repository.buyTip(coffee)).thenThrow(Exception('boom'));
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    await cubit.purchaseTip(coffee);

    expect(cubit.state.purchaseStatus, TipPurchaseStatus.error);
    expect(cubit.state.errorMessage, contains('boom'));

    await cubit.close();
  });

  test('purchase stream success sets ads removed and completes the purchase', () async {
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    purchaseController.add([_purchase(status: PurchaseStatus.purchased, pendingCompletePurchase: true)]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.purchaseStatus, TipPurchaseStatus.success);
    expect(cubit.state.adsRemoved, isTrue);
    expect(settingsCubit.state.adsRemoved, isTrue);
    expect(await database.getSetting('ads_removed'), 'true');
    verify(() => repository.completePurchase(any())).called(1);

    await cubit.close();
  });

  test('purchase stream error exposes the store error', () async {
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    purchaseController.add([
      _purchase(status: PurchaseStatus.error, pendingCompletePurchase: true, errorMessage: 'Purchase failed'),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.purchaseStatus, TipPurchaseStatus.error);
    expect(cubit.state.errorMessage, 'Purchase failed');
    verify(() => repository.completePurchase(any())).called(1);

    await cubit.close();
  });

  test('pending purchase updates keep the sheet in loading state', () async {
    final cubit = TipCubit(purchaseRepository: repository, settingsCubit: settingsCubit);

    purchaseController.add([_purchase(status: PurchaseStatus.pending)]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.purchaseStatus, TipPurchaseStatus.pending);

    await cubit.close();
  });
}
