import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/oxocarbon_theme.dart';

void main() {
  group('OxocarbonTheme', () {
    group('Dark color values', () {
      test('base00 is #161616', () {
        expect(OxocarbonTheme.darkBase00, const Color(0xFF161616));
      });

      test('base01 is #262626', () {
        expect(OxocarbonTheme.darkBase01, const Color(0xFF262626));
      });

      test('base02 is #393939', () {
        expect(OxocarbonTheme.darkBase02, const Color(0xFF393939));
      });

      test('base03 is #525252', () {
        expect(OxocarbonTheme.darkBase03, const Color(0xFF525252));
      });

      test('base04 is #dde1e6', () {
        expect(OxocarbonTheme.darkBase04, const Color(0xFFdde1e6));
      });

      test('base05 is #f2f4f8', () {
        expect(OxocarbonTheme.darkBase05, const Color(0xFFf2f4f8));
      });

      test('base06 is #ffffff', () {
        expect(OxocarbonTheme.darkBase06, const Color(0xFFffffff));
      });

      test('base07 is #08bdba', () {
        expect(OxocarbonTheme.darkBase07, const Color(0xFF08bdba));
      });

      test('base08 is #3ddbd9', () {
        expect(OxocarbonTheme.darkBase08, const Color(0xFF3ddbd9));
      });

      test('base09 is #78a9ff', () {
        expect(OxocarbonTheme.darkBase09, const Color(0xFF78a9ff));
      });

      test('base0A is #ee5396', () {
        expect(OxocarbonTheme.darkBase0A, const Color(0xFFee5396));
      });

      test('base0B is #33b1ff', () {
        expect(OxocarbonTheme.darkBase0B, const Color(0xFF33b1ff));
      });

      test('base0C is #ff7eb6', () {
        expect(OxocarbonTheme.darkBase0C, const Color(0xFFff7eb6));
      });

      test('base0D is #42be65', () {
        expect(OxocarbonTheme.darkBase0D, const Color(0xFF42be65));
      });

      test('base0E is #be95ff', () {
        expect(OxocarbonTheme.darkBase0E, const Color(0xFFbe95ff));
      });

      test('base0F is #82cfff', () {
        expect(OxocarbonTheme.darkBase0F, const Color(0xFF82cfff));
      });
    });

    group('Light color values', () {
      test('base00 is #ffffff', () {
        expect(OxocarbonTheme.lightBase00, const Color(0xFFffffff));
      });

      test('base01 is #f2f2f2', () {
        expect(OxocarbonTheme.lightBase01, const Color(0xFFf2f2f2));
      });

      test('base02 is #d0d0d0', () {
        expect(OxocarbonTheme.lightBase02, const Color(0xFFd0d0d0));
      });

      test('base03 is #161616', () {
        expect(OxocarbonTheme.lightBase03, const Color(0xFF161616));
      });

      test('base04 is #37474F', () {
        expect(OxocarbonTheme.lightBase04, const Color(0xFF37474F));
      });

      test('base05 is #90A4AE', () {
        expect(OxocarbonTheme.lightBase05, const Color(0xFF90A4AE));
      });

      test('base06 is #525252', () {
        expect(OxocarbonTheme.lightBase06, const Color(0xFF525252));
      });

      test('base07 is #08bdba', () {
        expect(OxocarbonTheme.lightBase07, const Color(0xFF08bdba));
      });

      test('base08 is #ff7eb6', () {
        expect(OxocarbonTheme.lightBase08, const Color(0xFFff7eb6));
      });

      test('base09 is #ee5396', () {
        expect(OxocarbonTheme.lightBase09, const Color(0xFFee5396));
      });

      test('base0A is #FF6F00', () {
        expect(OxocarbonTheme.lightBase0A, const Color(0xFFFF6F00));
      });

      test('base0B is #0f62fe', () {
        expect(OxocarbonTheme.lightBase0B, const Color(0xFF0f62fe));
      });

      test('base0C is #673AB7', () {
        expect(OxocarbonTheme.lightBase0C, const Color(0xFF673AB7));
      });

      test('base0D is #42be65', () {
        expect(OxocarbonTheme.lightBase0D, const Color(0xFF42be65));
      });

      test('base0E is #be95ff', () {
        expect(OxocarbonTheme.lightBase0E, const Color(0xFFbe95ff));
      });

      test('base0F is #FFAB91', () {
        expect(OxocarbonTheme.lightBase0F, const Color(0xFFFFAB91));
      });
    });
  });
}
