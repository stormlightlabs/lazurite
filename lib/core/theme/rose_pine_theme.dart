import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

class RosePineTheme {
  RosePineTheme._();

  static const Color mainBase = Color(0xFF191724);
  static const Color mainSurface = Color(0xFF1f1d2e);
  static const Color mainOverlay = Color(0xFF26233a);
  static const Color mainMuted = Color(0xFF6e6a86);
  static const Color mainSubtle = Color(0xFF908caa);
  static const Color mainText = Color(0xFFe0def4);
  static const Color mainLove = Color(0xFFeb6f92);
  static const Color mainGold = Color(0xFFf6c177);
  static const Color mainRose = Color(0xFFebbcba);
  static const Color mainPine = Color(0xFF31748f);
  static const Color mainFoam = Color(0xFF9ccfd8);
  static const Color mainIris = Color(0xFFc4a7e7);

  static const Color dawnBase = Color(0xFFfaf4ed);
  static const Color dawnSurface = Color(0xFFfffaf3);
  static const Color dawnOverlay = Color(0xFFf2e9e1);
  static const Color dawnMuted = Color(0xFF9893a5);
  static const Color dawnSubtle = Color(0xFF797593);
  static const Color dawnText = Color(0xFF575279);
  static const Color dawnLove = Color(0xFFb4637a);
  static const Color dawnGold = Color(0xFFea9d34);
  static const Color dawnRose = Color(0xFFd7827e);
  static const Color dawnPine = Color(0xFF286983);
  static const Color dawnFoam = Color(0xFF56949f);
  static const Color dawnIris = Color(0xFF907aa9);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: mainRose,
        onPrimary: mainBase,
        primaryContainer: mainSurface,
        onPrimaryContainer: mainText,
        secondary: mainIris,
        onSecondary: mainBase,
        secondaryContainer: mainSurface,
        onSecondaryContainer: mainText,
        tertiary: mainFoam,
        onTertiary: mainBase,
        error: mainLove,
        onError: mainBase,
        errorContainer: mainSurface,
        onErrorContainer: mainText,
        surface: mainSurface,
        onSurface: mainText,
        surfaceContainerHighest: mainOverlay,
        outline: mainMuted,
        outlineVariant: mainOverlay,
      ),
      scaffoldBackgroundColor: mainBase,
      appBarTheme: AppBarTheme(
        backgroundColor: mainBase,
        foregroundColor: mainText,
        surfaceTintColor: mainRose,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: mainText),
      ),
      cardTheme: const CardThemeData(color: mainSurface, surfaceTintColor: mainRose),
      dividerTheme: const DividerThemeData(color: mainOverlay),
      iconTheme: const IconThemeData(color: mainSubtle),
      listTileTheme: ListTileThemeData(
        textColor: mainText,
        iconColor: mainSubtle,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: mainText),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: mainSubtle),
      ),
      textTheme: AppTypography.textTheme(bodyColor: mainText, headlineColor: mainText, captionColor: mainMuted),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mainRose,
        foregroundColor: mainBase,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mainRose,
          foregroundColor: mainBase,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mainRose,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mainSurface,
        border: const OutlineInputBorder(borderSide: BorderSide(color: mainOverlay)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: mainOverlay)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mainRose)),
        labelStyle: AppTypography.googleSans(color: mainMuted),
        hintStyle: AppTypography.googleSans(color: mainMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: mainSurface,
        contentTextStyle: AppTypography.googleSans(color: mainText),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: dawnRose,
        onPrimary: dawnBase,
        primaryContainer: dawnSurface,
        onPrimaryContainer: dawnText,
        secondary: dawnIris,
        onSecondary: dawnBase,
        secondaryContainer: dawnSurface,
        onSecondaryContainer: dawnText,
        tertiary: dawnFoam,
        onTertiary: dawnBase,
        error: dawnLove,
        onError: dawnBase,
        errorContainer: dawnSurface,
        onErrorContainer: dawnText,
        surface: dawnSurface,
        onSurface: dawnText,
        surfaceContainerHighest: dawnOverlay,
        outline: dawnMuted,
        outlineVariant: dawnOverlay,
      ),
      scaffoldBackgroundColor: dawnBase,
      appBarTheme: AppBarTheme(
        backgroundColor: dawnBase,
        foregroundColor: dawnText,
        surfaceTintColor: dawnRose,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: dawnText),
      ),
      cardTheme: const CardThemeData(color: dawnSurface, surfaceTintColor: dawnRose),
      dividerTheme: const DividerThemeData(color: dawnOverlay),
      iconTheme: const IconThemeData(color: dawnSubtle),
      listTileTheme: ListTileThemeData(
        textColor: dawnText,
        iconColor: dawnSubtle,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: dawnText),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: dawnSubtle),
      ),
      textTheme: AppTypography.textTheme(bodyColor: dawnText, headlineColor: dawnText, captionColor: dawnMuted),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: dawnRose,
        foregroundColor: dawnBase,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dawnRose,
          foregroundColor: dawnBase,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: dawnRose,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dawnSurface,
        border: const OutlineInputBorder(borderSide: BorderSide(color: dawnOverlay)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: dawnOverlay)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: dawnRose)),
        labelStyle: AppTypography.googleSans(color: dawnMuted),
        hintStyle: AppTypography.googleSans(color: dawnMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dawnSurface,
        contentTextStyle: AppTypography.googleSans(color: dawnText),
      ),
    );
  }
}
