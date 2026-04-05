import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/tips/cubit/tip_state.dart';
import 'package:lazurite/features/tips/data/purchase_repository.dart';

class TipCubit extends Cubit<TipState> {
  TipCubit({required PurchaseRepository purchaseRepository, required SettingsCubit settingsCubit})
    : _repo = purchaseRepository,
      _settings = settingsCubit,
      super(TipState(adsRemoved: settingsCubit.state.adsRemoved)) {
    _purchaseSub = purchaseRepository.purchaseStream.listen(_onPurchaseUpdate);
  }

  final PurchaseRepository _repo;
  final SettingsCubit _settings;
  late final StreamSubscription<List<PurchaseDetails>> _purchaseSub;

  /// Checks store availability and fetches product details.
  Future<void> loadProducts() async {
    emit(state.copyWith(storeStatus: TipStoreStatus.loading));
    try {
      final available = await _repo.isAvailable();
      if (!available) {
        emit(state.copyWith(storeStatus: TipStoreStatus.unavailable));
        return;
      }
      final products = await _repo.fetchProducts();
      emit(state.copyWith(storeStatus: TipStoreStatus.available, products: products));
    } catch (e) {
      emit(state.copyWith(storeStatus: TipStoreStatus.unavailable));
    }
  }

  /// Initiates a tip purchase.
  Future<void> purchaseTip(ProductDetails product) async {
    emit(state.copyWith(purchaseStatus: TipPurchaseStatus.pending, clearError: true));
    try {
      await _repo.buyTip(product);
    } catch (e) {
      emit(state.copyWith(purchaseStatus: TipPurchaseStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          emit(state.copyWith(purchaseStatus: TipPurchaseStatus.pending, clearError: true));
          break;
        case PurchaseStatus.purchased:
          if (!state.adsRemoved) {
            await _settings.setAdsRemoved(true);
            emit(state.copyWith(adsRemoved: true));
          }
          emit(state.copyWith(purchaseStatus: TipPurchaseStatus.success, clearError: true));
          if (purchase.pendingCompletePurchase) {
            await _repo.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.error:
          emit(state.copyWith(purchaseStatus: TipPurchaseStatus.error, errorMessage: purchase.error?.message));
          if (purchase.pendingCompletePurchase) {
            await _repo.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.restored:
          if (purchase.pendingCompletePurchase) {
            await _repo.completePurchase(purchase);
          }
          break;
        case PurchaseStatus.canceled:
          emit(state.copyWith(purchaseStatus: TipPurchaseStatus.idle, clearError: true));
          break;
      }
    }
  }

  @override
  Future<void> close() {
    _purchaseSub.cancel();
    return super.close();
  }
}
