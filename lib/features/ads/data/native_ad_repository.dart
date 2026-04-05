import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lazurite/core/ads/ad_helper.dart';
import 'package:lazurite/core/logging/app_logger.dart';

abstract class NativeAdHandle {
  Widget buildWidget();

  void dispose();
}

abstract class NativeAdRepository {
  Future<NativeAdHandle?> loadAd({required int slotIndex});
}

class GoogleMobileNativeAdRepository implements NativeAdRepository {
  @override
  Future<NativeAdHandle?> loadAd({required int slotIndex}) async {
    final completer = Completer<NativeAdHandle?>();

    try {
      late final NativeAd ad;
      ad = NativeAd(
        adUnitId: AdHelper.nativeAdUnitId,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            if (!completer.isCompleted) {
              completer.complete(_GoogleMobileNativeAdHandle(ad));
            }
          },
          onAdFailedToLoad: (failedAd, error) {
            failedAd.dispose();
            log.d('Native ad failed to load for slot $slotIndex: $error');
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          },
        ),
      );

      await ad.load();
      return completer.future;
    } catch (error, stackTrace) {
      log.e('Failed to request native ad for slot $slotIndex', error: error, stackTrace: stackTrace);
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return completer.future;
    }
  }
}

class _GoogleMobileNativeAdHandle implements NativeAdHandle {
  _GoogleMobileNativeAdHandle(this._ad);

  final NativeAd _ad;

  @override
  Widget buildWidget() => AdWidget(ad: _ad);

  @override
  void dispose() => _ad.dispose();
}
