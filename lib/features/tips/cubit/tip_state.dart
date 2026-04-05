import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

enum TipStoreStatus { loading, available, unavailable }

enum TipPurchaseStatus { idle, pending, success, error }

class TipState extends Equatable {
  const TipState({
    this.storeStatus = TipStoreStatus.loading,
    this.products = const [],
    this.purchaseStatus = TipPurchaseStatus.idle,
    this.errorMessage,
    this.adsRemoved = false,
  });

  final TipStoreStatus storeStatus;
  final List<ProductDetails> products;
  final TipPurchaseStatus purchaseStatus;
  final String? errorMessage;
  final bool adsRemoved;

  TipState copyWith({
    TipStoreStatus? storeStatus,
    List<ProductDetails>? products,
    TipPurchaseStatus? purchaseStatus,
    String? errorMessage,
    bool? adsRemoved,
    bool clearError = false,
  }) {
    return TipState(
      storeStatus: storeStatus ?? this.storeStatus,
      products: products ?? this.products,
      purchaseStatus: purchaseStatus ?? this.purchaseStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  @override
  List<Object?> get props => [storeStatus, products, purchaseStatus, errorMessage, adsRemoved];
}
