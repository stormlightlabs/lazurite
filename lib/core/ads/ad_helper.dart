import 'package:flutter/foundation.dart';

/// Static helpers for ad slot placement and index mapping.
class AdHelper {
  AdHelper._();

  /// Posts between ad slots (configurable constant).
  static const int adInterval = 8;

  /// Delay before the first ad on profile posts tabs — the user came to see
  /// this person's posts, so we hold off slightly longer.
  static const int profileAdOffset = 4;

  static const String _iosTestAdUnitId = 'ca-app-pub-3940256099942544/3986624511';
  static const String _androidTestAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  // TODO: replace with real production ad unit IDs before release.
  static const String _iosReleaseAdUnitId = 'ca-app-pub-3940256099942544/3986624511';
  static const String _androidReleaseAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  /// Returns the appropriate native ad unit ID for the current platform and
  /// build mode.
  static String get nativeAdUnitId {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (kDebugMode) {
      return isIOS ? _iosTestAdUnitId : _androidTestAdUnitId;
    }
    return isIOS ? _iosReleaseAdUnitId : _androidReleaseAdUnitId;
  }

  /// Total number of visual items when ad slots are injected into [postCount]
  /// posts, with the first ad deferred until [offset] posts have been shown.
  ///
  /// An ad slot is inserted after every [adInterval] eligible posts.
  /// Posts before [offset] are not eligible.
  static int visualItemCount(int postCount, {int offset = 0}) {
    if (postCount == 0) return 0;
    final eligible = postCount - offset;
    if (eligible <= 0) return postCount;
    return postCount + eligible ~/ adInterval;
  }

  /// Maps a visual list index to the underlying post data index, or returns
  /// `null` if the visual index is an ad slot.
  ///
  /// Uses a fixed period of `adInterval + 1` items per group (8 posts + 1 ad).
  /// Posts before [offset] are returned as-is (no ad injection before offset).
  static int? dataIndexForVisualIndex(int visualIndex, {int offset = 0}) {
    if (visualIndex < offset) return visualIndex;
    final relative = visualIndex - offset;
    const period = adInterval + 1;
    final posInPeriod = relative % period;
    if (posInPeriod == adInterval) return null;
    final fullPeriods = relative ~/ period;
    return offset + fullPeriods * adInterval + posInPeriod;
  }

  /// Returns `true` if [visualIndex] is an ad slot given the [offset].
  static bool isAdSlot(int visualIndex, {int offset = 0}) =>
      dataIndexForVisualIndex(visualIndex, offset: offset) == null;
}
