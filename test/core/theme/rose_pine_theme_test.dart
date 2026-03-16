import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/rose_pine_theme.dart';

void main() {
  group('RosePineTheme', () {
    group('Main (Dark) color values', () {
      test('base is #191724', () {
        expect(RosePineTheme.mainBase, const Color(0xFF191724));
      });

      test('surface is #1f1d2e', () {
        expect(RosePineTheme.mainSurface, const Color(0xFF1f1d2e));
      });

      test('overlay is #26233a', () {
        expect(RosePineTheme.mainOverlay, const Color(0xFF26233a));
      });

      test('muted is #6e6a86', () {
        expect(RosePineTheme.mainMuted, const Color(0xFF6e6a86));
      });

      test('subtle is #908caa', () {
        expect(RosePineTheme.mainSubtle, const Color(0xFF908caa));
      });

      test('text is #e0def4', () {
        expect(RosePineTheme.mainText, const Color(0xFFe0def4));
      });

      test('love is #eb6f92', () {
        expect(RosePineTheme.mainLove, const Color(0xFFeb6f92));
      });

      test('gold is #f6c177', () {
        expect(RosePineTheme.mainGold, const Color(0xFFf6c177));
      });

      test('rose is #ebbcba', () {
        expect(RosePineTheme.mainRose, const Color(0xFFebbcba));
      });

      test('pine is #31748f', () {
        expect(RosePineTheme.mainPine, const Color(0xFF31748f));
      });

      test('foam is #9ccfd8', () {
        expect(RosePineTheme.mainFoam, const Color(0xFF9ccfd8));
      });

      test('iris is #c4a7e7', () {
        expect(RosePineTheme.mainIris, const Color(0xFFc4a7e7));
      });
    });

    group('Dawn (Light) color values', () {
      test('base is #faf4ed', () {
        expect(RosePineTheme.dawnBase, const Color(0xFFfaf4ed));
      });

      test('surface is #fffaf3', () {
        expect(RosePineTheme.dawnSurface, const Color(0xFFfffaf3));
      });

      test('overlay is #f2e9e1', () {
        expect(RosePineTheme.dawnOverlay, const Color(0xFFf2e9e1));
      });

      test('muted is #9893a5', () {
        expect(RosePineTheme.dawnMuted, const Color(0xFF9893a5));
      });

      test('subtle is #797593', () {
        expect(RosePineTheme.dawnSubtle, const Color(0xFF797593));
      });

      test('text is #575279', () {
        expect(RosePineTheme.dawnText, const Color(0xFF575279));
      });

      test('love is #b4637a', () {
        expect(RosePineTheme.dawnLove, const Color(0xFFb4637a));
      });

      test('gold is #ea9d34', () {
        expect(RosePineTheme.dawnGold, const Color(0xFFea9d34));
      });

      test('rose is #d7827e', () {
        expect(RosePineTheme.dawnRose, const Color(0xFFd7827e));
      });

      test('pine is #286983', () {
        expect(RosePineTheme.dawnPine, const Color(0xFF286983));
      });

      test('foam is #56949f', () {
        expect(RosePineTheme.dawnFoam, const Color(0xFF56949f));
      });

      test('iris is #907aa9', () {
        expect(RosePineTheme.dawnIris, const Color(0xFF907aa9));
      });
    });
  });
}
