import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

class OxocarbonTheme {
  OxocarbonTheme._();

  static const Color darkBase00 = Color(0xFF161616);
  static const Color darkBase01 = Color(0xFF262626);
  static const Color darkBase02 = Color(0xFF393939);
  static const Color darkBase03 = Color(0xFF525252);
  static const Color darkBase04 = Color(0xFFdde1e6);
  static const Color darkBase05 = Color(0xFFf2f4f8);
  static const Color darkBase06 = Color(0xFFffffff);
  static const Color darkBase07 = Color(0xFF08bdba);
  static const Color darkBase08 = Color(0xFF3ddbd9);
  static const Color darkBase09 = Color(0xFF78a9ff);
  static const Color darkBase0A = Color(0xFFee5396);
  static const Color darkBase0B = Color(0xFF33b1ff);
  static const Color darkBase0C = Color(0xFFff7eb6);
  static const Color darkBase0D = Color(0xFF42be65);
  static const Color darkBase0E = Color(0xFFbe95ff);
  static const Color darkBase0F = Color(0xFF82cfff);

  static const Color lightBase00 = Color(0xFFffffff);
  static const Color lightBase01 = Color(0xFFf2f2f2);
  static const Color lightBase02 = Color(0xFFd0d0d0);
  static const Color lightBase03 = Color(0xFF161616);
  static const Color lightBase04 = Color(0xFF37474F);
  static const Color lightBase05 = Color(0xFF90A4AE);
  static const Color lightBase06 = Color(0xFF525252);
  static const Color lightBase07 = Color(0xFF08bdba);
  static const Color lightBase08 = Color(0xFFff7eb6);
  static const Color lightBase09 = Color(0xFFee5396);
  static const Color lightBase0A = Color(0xFFFF6F00);
  static const Color lightBase0B = Color(0xFF0f62fe);
  static const Color lightBase0C = Color(0xFF673AB7);
  static const Color lightBase0D = Color(0xFF42be65);
  static const Color lightBase0E = Color(0xFFbe95ff);
  static const Color lightBase0F = Color(0xFFFFAB91);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkBase09,
        onPrimary: darkBase00,
        primaryContainer: darkBase01,
        onPrimaryContainer: darkBase05,
        secondary: darkBase0E,
        onSecondary: darkBase00,
        secondaryContainer: darkBase01,
        onSecondaryContainer: darkBase05,
        tertiary: darkBase07,
        onTertiary: darkBase00,
        error: darkBase0A,
        onError: darkBase00,
        errorContainer: darkBase01,
        onErrorContainer: darkBase05,
        surface: darkBase01,
        onSurface: darkBase05,
        surfaceContainerHighest: darkBase02,
        outline: darkBase03,
        outlineVariant: darkBase02,
      ),
      scaffoldBackgroundColor: darkBase00,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBase00,
        foregroundColor: darkBase05,
        surfaceTintColor: darkBase09,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: darkBase05),
      ),
      cardTheme: const CardThemeData(color: darkBase01, surfaceTintColor: darkBase09),
      dividerTheme: const DividerThemeData(color: darkBase02),
      iconTheme: const IconThemeData(color: darkBase04),
      listTileTheme: ListTileThemeData(
        textColor: darkBase05,
        iconColor: darkBase04,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: darkBase05),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: darkBase04),
      ),
      textTheme: AppTypography.textTheme(bodyColor: darkBase05, headlineColor: darkBase06, captionColor: darkBase03),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkBase09,
        foregroundColor: darkBase00,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBase09,
          foregroundColor: darkBase00,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkBase09,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkBase01,
        border: const OutlineInputBorder(borderSide: BorderSide(color: darkBase02)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkBase02)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkBase09)),
        labelStyle: AppTypography.googleSans(color: darkBase03),
        hintStyle: AppTypography.googleSans(color: darkBase03),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBase01,
        contentTextStyle: AppTypography.googleSans(color: darkBase05),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: lightBase0B,
        onPrimary: lightBase00,
        primaryContainer: lightBase01,
        onPrimaryContainer: lightBase03,
        secondary: lightBase0C,
        onSecondary: lightBase00,
        secondaryContainer: lightBase01,
        onSecondaryContainer: lightBase03,
        tertiary: lightBase07,
        onTertiary: lightBase00,
        error: lightBase09,
        onError: lightBase00,
        errorContainer: lightBase01,
        onErrorContainer: lightBase03,
        surface: lightBase01,
        onSurface: lightBase03,
        surfaceContainerHighest: lightBase02,
        outline: lightBase05,
        outlineVariant: lightBase02,
      ),
      scaffoldBackgroundColor: lightBase00,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBase00,
        foregroundColor: lightBase03,
        surfaceTintColor: lightBase0B,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: lightBase03),
      ),
      cardTheme: const CardThemeData(color: lightBase01, surfaceTintColor: lightBase0B),
      dividerTheme: const DividerThemeData(color: lightBase02),
      iconTheme: const IconThemeData(color: lightBase04),
      listTileTheme: ListTileThemeData(
        textColor: lightBase03,
        iconColor: lightBase04,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: lightBase03),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: lightBase04),
      ),
      textTheme: AppTypography.textTheme(bodyColor: lightBase03, headlineColor: lightBase03, captionColor: lightBase05),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightBase0B,
        foregroundColor: lightBase00,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightBase0B,
          foregroundColor: lightBase00,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightBase0B,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBase01,
        border: const OutlineInputBorder(borderSide: BorderSide(color: lightBase02)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightBase02)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightBase0B)),
        labelStyle: AppTypography.googleSans(color: lightBase05),
        hintStyle: AppTypography.googleSans(color: lightBase05),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightBase01,
        contentTextStyle: AppTypography.googleSans(color: lightBase03),
      ),
    );
  }
}
