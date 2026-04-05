import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/ads/ad_helper.dart';
import 'package:lazurite/features/ads/cubit/ad_state.dart';
import 'package:lazurite/features/ads/data/native_ad_repository.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class AdCubit extends Cubit<AdState> {
  AdCubit({required SettingsCubit settingsCubit, required NativeAdRepository nativeAdRepository})
    : _nativeAdRepository = nativeAdRepository,
      super(AdState(adsRemoved: settingsCubit.state.adsRemoved)) {
    _sub = settingsCubit.stream.map((SettingsState s) => s.adsRemoved).distinct().listen((adsRemoved) {
      if (adsRemoved) {
        clearAds();
      }
      emit(state.copyWith(adsRemoved: adsRemoved));
    });
  }

  final NativeAdRepository _nativeAdRepository;
  late final StreamSubscription<bool> _sub;
  final Set<int> _loadingSlots = <int>{};

  Future<void> loadAdsForPage(int pageIndex, int postCount, {int offset = 0}) async {
    if (state.adsRemoved || postCount <= 0) {
      return;
    }

    final visualCount = AdHelper.visualItemCount(postCount, offset: offset);
    final slots = <int>[];
    for (var index = 0; index < visualCount; index++) {
      if (AdHelper.isAdSlot(index, offset: offset)) {
        slots.add(index);
      }
    }

    for (final slotIndex in slots) {
      await loadAdSlot(slotIndex);
    }
  }

  Future<void> loadAdSlot(int slotIndex) async {
    if (state.adsRemoved || state.loadedAds.containsKey(slotIndex) || !_loadingSlots.add(slotIndex)) {
      return;
    }

    try {
      final ad = await _nativeAdRepository.loadAd(slotIndex: slotIndex);
      if (isClosed || ad == null || state.adsRemoved) {
        ad?.dispose();
        return;
      }

      emit(state.copyWith(loadedAds: {...state.loadedAds, slotIndex: ad}));
    } finally {
      _loadingSlots.remove(slotIndex);
    }
  }

  void disposeAd(int slotIndex) {
    final ad = state.loadedAds[slotIndex];
    if (ad == null) {
      return;
    }

    final nextAds = Map<int, NativeAdHandle>.of(state.loadedAds)..remove(slotIndex);
    ad.dispose();
    emit(state.copyWith(loadedAds: nextAds));
  }

  void clearAds() {
    for (final ad in state.loadedAds.values) {
      ad.dispose();
    }
    if (state.loadedAds.isNotEmpty) {
      emit(state.copyWith(loadedAds: const {}));
    }
  }

  @override
  Future<void> close() {
    clearAds();
    _sub.cancel();
    return super.close();
  }
}
