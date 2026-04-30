import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/purple_theme.dart';

void main() {
  group('PurpleTheme', () {
    group('Dark color values', () {
      test('sop0 is #1E1E3F', () {
        expect(PurpleTheme.sop0, const Color(0xFF1E1E3F));
      });

      test('sop1 is #28284E', () {
        expect(PurpleTheme.sop1, const Color(0xFF28284E));
      });

      test('sop2 is #2D2B55', () {
        expect(PurpleTheme.sop2, const Color(0xFF2D2B55));
      });

      test('sop3 is #A599E9', () {
        expect(PurpleTheme.sop3, const Color(0xFFA599E9));
      });

      test('sop4 is #E1EFFF', () {
        expect(PurpleTheme.sop4, const Color(0xFFE1EFFF));
      });

      test('sop5 is #9EFFFF', () {
        expect(PurpleTheme.sop5, const Color(0xFF9EFFFF));
      });

      test('sop6 is #FAD000', () {
        expect(PurpleTheme.sop6, const Color(0xFFFAD000));
      });

      test('sop7 is #FF9D00', () {
        expect(PurpleTheme.sop7, const Color(0xFFFF9D00));
      });

      test('sop8 is #B362FF', () {
        expect(PurpleTheme.sop8, const Color(0xFFB362FF));
      });

      test('sop9 is #FF628C', () {
        expect(PurpleTheme.sop9, const Color(0xFFFF628C));
      });

      test('sop10 is #A5FF90', () {
        expect(PurpleTheme.sop10, const Color(0xFFA5FF90));
      });

      test('sop11 is #EC3A37', () {
        expect(PurpleTheme.sop11, const Color(0xFFEC3A37));
      });

      test('sop12 is #80FFBB', () {
        expect(PurpleTheme.sop12, const Color(0xFF80FFBB));
      });

      test('sop13 is #FB94FF', () {
        expect(PurpleTheme.sop13, const Color(0xFFFB94FF));
      });

      test('sop14 is #6943FF', () {
        expect(PurpleTheme.sop14, const Color(0xFF6943FF));
      });

      test('darkOutlineVariant is lavender at ~15% opacity', () {
        expect(PurpleTheme.darkOutlineVariant, const Color(0x26A599E9));
      });
    });

    group('Light color values', () {
      test('sopL0 is #F8F6FF', () {
        expect(PurpleTheme.sopL0, const Color(0xFFF8F6FF));
      });

      test('sopL1 is #EDE9FF', () {
        expect(PurpleTheme.sopL1, const Color(0xFFEDE9FF));
      });

      test('sopL2 is #D6CEFF', () {
        expect(PurpleTheme.sopL2, const Color(0xFFD6CEFF));
      });

      test('sopL3 is #8B7FD4', () {
        expect(PurpleTheme.sopL3, const Color(0xFF8B7FD4));
      });

      test('sopL4 is #2D2B55', () {
        expect(PurpleTheme.sopL4, const Color(0xFF2D2B55));
      });

      test('sopL5 is #6943FF', () {
        expect(PurpleTheme.sopL5, const Color(0xFF6943FF));
      });

      test('sopL6 is #7B6EC0', () {
        expect(PurpleTheme.sopL6, const Color(0xFF7B6EC0));
      });
    });

    group('ThemeData', () {
      test('dark theme maps expected tokens', () {
        final theme = PurpleTheme.dark();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.dark);
        expect(scheme.primary, PurpleTheme.sop3);
        expect(scheme.secondary, PurpleTheme.sop5);
        expect(scheme.tertiary, PurpleTheme.sop8);
        expect(scheme.surface, PurpleTheme.sop1);
        expect(scheme.onSurface, PurpleTheme.sop4);
        expect(scheme.surfaceContainerHighest, PurpleTheme.sop2);
        expect(scheme.outline, PurpleTheme.sop3);
        expect(scheme.outlineVariant, PurpleTheme.darkOutlineVariant);
        expect(scheme.error, PurpleTheme.sop11);
        expect(theme.scaffoldBackgroundColor, PurpleTheme.sop0);
        expect(theme.appBarTheme.backgroundColor, PurpleTheme.sop0);
        expect(theme.cardTheme.color, PurpleTheme.sop1);
        expect(theme.dividerTheme.color, PurpleTheme.darkOutlineVariant);
        expect(theme.iconTheme.color, PurpleTheme.sop3);
        expect(theme.listTileTheme.textColor, PurpleTheme.sop4);
        expect(theme.floatingActionButtonTheme.backgroundColor, PurpleTheme.sop3);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, PurpleTheme.sop1);
        expect(theme.snackBarTheme.backgroundColor, PurpleTheme.sop1);
      });

      test('light theme maps expected tokens', () {
        final theme = PurpleTheme.light();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.light);
        expect(scheme.primary, PurpleTheme.sopL5);
        expect(scheme.secondary, PurpleTheme.sopL6);
        expect(scheme.tertiary, PurpleTheme.sop8);
        expect(scheme.surface, PurpleTheme.sopL1);
        expect(scheme.onSurface, PurpleTheme.sopL4);
        expect(scheme.surfaceContainerHighest, PurpleTheme.sopL2);
        expect(scheme.outline, PurpleTheme.sopL3);
        expect(scheme.outlineVariant, PurpleTheme.sopL2);
        expect(scheme.error, PurpleTheme.sop11);
        expect(theme.scaffoldBackgroundColor, PurpleTheme.sopL0);
        expect(theme.appBarTheme.backgroundColor, PurpleTheme.sopL0);
        expect(theme.cardTheme.color, PurpleTheme.sopL1);
        expect(theme.dividerTheme.color, PurpleTheme.sopL2);
        expect(theme.iconTheme.color, PurpleTheme.sopL3);
        expect(theme.listTileTheme.textColor, PurpleTheme.sopL4);
        expect(theme.floatingActionButtonTheme.backgroundColor, PurpleTheme.sopL5);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, PurpleTheme.sopL1);
        expect(theme.snackBarTheme.backgroundColor, PurpleTheme.sopL1);
      });
    });
  });
}
