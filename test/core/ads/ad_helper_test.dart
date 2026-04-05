import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/ads/ad_helper.dart';

void main() {
  group('AdHelper', () {
    test('uses the Google test unit ID for the active debug platform', () {
      final expected = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ca-app-pub-3940256099942544/3986624511',
        _ => 'ca-app-pub-3940256099942544/2247696110',
      };

      expect(AdHelper.nativeAdUnitId, expected);
    });

    test('visual item count injects ads every eight posts', () {
      expect(AdHelper.visualItemCount(0), 0);
      expect(AdHelper.visualItemCount(8), 9);
      expect(AdHelper.visualItemCount(10), 11);
      expect(AdHelper.visualItemCount(12, offset: AdHelper.profileAdOffset), 13);
    });

    test('maps feed visual indices back to post indices', () {
      expect(AdHelper.dataIndexForVisualIndex(0), 0);
      expect(AdHelper.dataIndexForVisualIndex(7), 7);
      expect(AdHelper.dataIndexForVisualIndex(8), isNull);
      expect(AdHelper.dataIndexForVisualIndex(9), 8);
      expect(AdHelper.dataIndexForVisualIndex(10), 9);
    });

    test('maps profile visual indices back to post indices with offset', () {
      expect(AdHelper.dataIndexForVisualIndex(0, offset: AdHelper.profileAdOffset), 0);
      expect(AdHelper.dataIndexForVisualIndex(3, offset: AdHelper.profileAdOffset), 3);
      expect(AdHelper.dataIndexForVisualIndex(4, offset: AdHelper.profileAdOffset), 4);
      expect(AdHelper.dataIndexForVisualIndex(11, offset: AdHelper.profileAdOffset), 11);
      expect(AdHelper.dataIndexForVisualIndex(12, offset: AdHelper.profileAdOffset), isNull);
      expect(AdHelper.dataIndexForVisualIndex(13, offset: AdHelper.profileAdOffset), 12);
    });

    test('round-trips data indices for feed and profile offsets', () {
      for (final offset in <int>[0, AdHelper.profileAdOffset]) {
        final postCount = offset == 0 ? 18 : 20;
        final visualCount = AdHelper.visualItemCount(postCount, offset: offset);
        final seen = <int>[];

        for (var visualIndex = 0; visualIndex < visualCount; visualIndex++) {
          final dataIndex = AdHelper.dataIndexForVisualIndex(visualIndex, offset: offset);
          if (dataIndex != null) {
            seen.add(dataIndex);
          }
        }

        expect(seen, List<int>.generate(postCount, (index) => index));
      }
    });
  });
}
