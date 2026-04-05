import 'package:equatable/equatable.dart';
import 'package:lazurite/features/ads/data/native_ad_repository.dart';

class AdState extends Equatable {
  const AdState({this.loadedAds = const {}, this.adsRemoved = false});

  final Map<int, NativeAdHandle> loadedAds;
  final bool adsRemoved;

  AdState copyWith({Map<int, NativeAdHandle>? loadedAds, bool? adsRemoved}) {
    return AdState(loadedAds: loadedAds ?? this.loadedAds, adsRemoved: adsRemoved ?? this.adsRemoved);
  }

  @override
  List<Object?> get props => [loadedAds, adsRemoved];
}
