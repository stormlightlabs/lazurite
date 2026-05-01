import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/core/theme/purple_theme.dart';

void main() {
  group('PurpleTheme', () {
    group('Raw palette values', () {
      test('sop0 is #1E1E3F', () => expect(PurpleTheme.sop0, const Color(0xFF1E1E3F)));
      test('sop1 is #28284E', () => expect(PurpleTheme.sop1, const Color(0xFF28284E)));
      test('sop2 is #2D2B55', () => expect(PurpleTheme.sop2, const Color(0xFF2D2B55)));
      test('sop3 is #A599E9', () => expect(PurpleTheme.sop3, const Color(0xFFA599E9)));
      test('sop4 is #E1EFFF', () => expect(PurpleTheme.sop4, const Color(0xFFE1EFFF)));
      test('sop5 is #9EFFFF', () => expect(PurpleTheme.sop5, const Color(0xFF9EFFFF)));
      test('sop6 is #FAD000', () => expect(PurpleTheme.sop6, const Color(0xFFFAD000)));
      test('sop7 is #FF9D00', () => expect(PurpleTheme.sop7, const Color(0xFFFF9D00)));
      test('sop8 is #B362FF', () => expect(PurpleTheme.sop8, const Color(0xFFB362FF)));
      test('sop9 is #FF628C', () => expect(PurpleTheme.sop9, const Color(0xFFFF628C)));
      test('sop10 is #A5FF90', () => expect(PurpleTheme.sop10, const Color(0xFFA5FF90)));
      test('sop11 is #EC3A37', () => expect(PurpleTheme.sop11, const Color(0xFFEC3A37)));
      test('sop12 is #80FFBB', () => expect(PurpleTheme.sop12, const Color(0xFF80FFBB)));
      test('sop13 is #FB94FF', () => expect(PurpleTheme.sop13, const Color(0xFFFB94FF)));
      test('sop14 is #6943FF', () => expect(PurpleTheme.sop14, const Color(0xFF6943FF)));
      test('sopL0 is #F8F6FF', () => expect(PurpleTheme.sopL0, const Color(0xFFF8F6FF)));
      test('sopL1 is #EDE9FF', () => expect(PurpleTheme.sopL1, const Color(0xFFEDE9FF)));
      test('sopL2 is #D6CEFF', () => expect(PurpleTheme.sopL2, const Color(0xFFD6CEFF)));
      test('sopL3 is #8B7FD4', () => expect(PurpleTheme.sopL3, const Color(0xFF8B7FD4)));
      test('sopL4 is #2D2B55', () => expect(PurpleTheme.sopL4, const Color(0xFF2D2B55)));
      test('sopL5 is #6943FF', () => expect(PurpleTheme.sopL5, const Color(0xFF6943FF)));
      test('sopL6 is #7B6EC0', () => expect(PurpleTheme.sopL6, const Color(0xFF7B6EC0)));
    });

    group('Dark semantic token values', () {
      test('darkSurface is sop0', () => expect(PurpleTheme.darkSurface, PurpleTheme.sop0));
      test('darkSurfaceContainer is sop1', () => expect(PurpleTheme.darkSurfaceContainer, PurpleTheme.sop1));
      test('darkSurfaceContainerHigh is sop2', () => expect(PurpleTheme.darkSurfaceContainerHigh, PurpleTheme.sop2));
      test('darkOnSurface is sop4', () => expect(PurpleTheme.darkOnSurface, PurpleTheme.sop4));
      test('darkOnSurfaceVariant is sop3', () => expect(PurpleTheme.darkOnSurfaceVariant, PurpleTheme.sop3));
      test('darkPrimary is sop8', () => expect(PurpleTheme.darkPrimary, PurpleTheme.sop8));
      test('darkOnPrimary is sop0', () => expect(PurpleTheme.darkOnPrimary, PurpleTheme.sop0));
      test('darkOutline is lavender ~30%', () => expect(PurpleTheme.darkOutline, const Color(0x4DA599E9)));
      test(
        'darkOutlineVariant is lavender ~15%',
        () => expect(PurpleTheme.darkOutlineVariant, const Color(0x26A599E9)),
      );
    });

    group('Light semantic token values', () {
      test('lightSurface is sopL0', () => expect(PurpleTheme.lightSurface, PurpleTheme.sopL0));
      test('lightSurfaceContainer is sopL1', () => expect(PurpleTheme.lightSurfaceContainer, PurpleTheme.sopL1));
      test('lightOnSurface is sopL4', () => expect(PurpleTheme.lightOnSurface, PurpleTheme.sopL4));
      test('lightOnSurfaceVariant is sopL3', () => expect(PurpleTheme.lightOnSurfaceVariant, PurpleTheme.sopL3));
      test('lightPrimary is sopL5', () => expect(PurpleTheme.lightPrimary, PurpleTheme.sopL5));
      test('lightOnPrimary is sopL0', () => expect(PurpleTheme.lightOnPrimary, PurpleTheme.sopL0));
      test('lightOutline is blue-purple ~30%', () => expect(PurpleTheme.lightOutline, const Color(0x4D6943FF)));
      test('lightOutlineVariant is sopL2', () => expect(PurpleTheme.lightOutlineVariant, PurpleTheme.sopL2));
    });

    group('ThemeData', () {
      test('dark theme maps expected tokens', () {
        final theme = PurpleTheme.dark();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.dark);
        expect(scheme.primary, PurpleTheme.darkPrimary);
        expect(scheme.secondary, PurpleTheme.sop5);
        expect(scheme.tertiary, PurpleTheme.sop3);
        expect(scheme.surface, PurpleTheme.darkSurfaceContainer);
        expect(scheme.onSurface, PurpleTheme.darkOnSurface);
        expect(scheme.onSurfaceVariant, PurpleTheme.darkOnSurfaceVariant);
        expect(scheme.surfaceContainerHighest, PurpleTheme.darkSurfaceContainerHigh);
        expect(scheme.outline, PurpleTheme.darkOutline);
        expect(scheme.outlineVariant, PurpleTheme.darkOutlineVariant);
        expect(scheme.error, PurpleTheme.sop11);
        expect(theme.scaffoldBackgroundColor, PurpleTheme.darkSurface);
        expect(theme.appBarTheme.backgroundColor, PurpleTheme.darkSurface);
        expect(theme.cardTheme.color, PurpleTheme.darkSurfaceContainer);
        expect(theme.dividerTheme.color, PurpleTheme.darkOutlineVariant);
        expect(theme.iconTheme.color, PurpleTheme.darkOnSurfaceVariant);
        expect(theme.listTileTheme.textColor, PurpleTheme.darkOnSurface);
        expect(theme.floatingActionButtonTheme.backgroundColor, PurpleTheme.darkPrimary);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, PurpleTheme.darkSurfaceContainer);
        expect(theme.snackBarTheme.backgroundColor, PurpleTheme.darkSurfaceContainerHigh);
      });

      test('light theme maps expected tokens', () {
        final theme = PurpleTheme.light();
        final scheme = theme.colorScheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.brightness, Brightness.light);
        expect(scheme.primary, PurpleTheme.lightPrimary);
        expect(scheme.secondary, PurpleTheme.sopL6);
        expect(scheme.tertiary, PurpleTheme.sop3);
        expect(scheme.surface, PurpleTheme.lightSurfaceContainer);
        expect(scheme.onSurface, PurpleTheme.lightOnSurface);
        expect(scheme.onSurfaceVariant, PurpleTheme.lightOnSurfaceVariant);
        expect(scheme.outline, PurpleTheme.lightOutline);
        expect(scheme.outlineVariant, PurpleTheme.lightOutlineVariant);
        expect(scheme.error, PurpleTheme.sop11);
        expect(theme.scaffoldBackgroundColor, PurpleTheme.lightSurface);
        expect(theme.appBarTheme.backgroundColor, PurpleTheme.lightSurface);
        expect(theme.cardTheme.color, PurpleTheme.lightSurfaceContainer);
        expect(theme.dividerTheme.color, PurpleTheme.lightOutlineVariant);
        expect(theme.iconTheme.color, PurpleTheme.lightOnSurfaceVariant);
        expect(theme.listTileTheme.textColor, PurpleTheme.lightOnSurface);
        expect(theme.floatingActionButtonTheme.backgroundColor, PurpleTheme.lightPrimary);
        expect(theme.inputDecorationTheme.filled, isTrue);
        expect(theme.inputDecorationTheme.fillColor, PurpleTheme.lightSurfaceContainer);
        expect(theme.snackBarTheme.backgroundColor, PurpleTheme.lightSurfaceContainer);
      });
    });
  });
}
