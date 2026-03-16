import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

class CatppuccinTheme {
  CatppuccinTheme._();

  static const Color mochaBase = Color(0xFF1e1e2e);
  static const Color mochaMantle = Color(0xFF181825);
  static const Color mochaSurface0 = Color(0xFF313244);
  static const Color mochaSurface1 = Color(0xFF45475a);
  static const Color mochaSubtext0 = Color(0xFFa6adc8);
  static const Color mochaText = Color(0xFFcdd6f4);
  static const Color mochaLavender = Color(0xFFb4befe);
  static const Color mochaBlue = Color(0xFF89b4fa);
  static const Color mochaSapphire = Color(0xFF74c7ec);
  static const Color mochaGreen = Color(0xFFa6e3a1);
  static const Color mochaRed = Color(0xFFf38ba8);
  static const Color mochaPeach = Color(0xFFfab387);
  static const Color mochaMauve = Color(0xFFcba6f7);
  static const Color mochaPink = Color(0xFFf5c2e7);
  static const Color mochaRosewater = Color(0xFFf5e0dc);

  static const Color latteBase = Color(0xFFeff1f5);
  static const Color latteMantle = Color(0xFFe6e9ef);
  static const Color latteSurface0 = Color(0xFFccd0da);
  static const Color latteSurface1 = Color(0xFFbcc0cc);
  static const Color latteSubtext0 = Color(0xFF6c6f85);
  static const Color latteText = Color(0xFF4c4f69);
  static const Color latteLavender = Color(0xFF7287fd);
  static const Color latteBlue = Color(0xFF1e66f5);
  static const Color latteSapphire = Color(0xFF209fb5);
  static const Color latteGreen = Color(0xFF40a02b);
  static const Color latteRed = Color(0xFFd20f39);
  static const Color lattePeach = Color(0xFFfe640b);
  static const Color latteMauve = Color(0xFF8839ef);
  static const Color lattePink = Color(0xFFea76cb);
  static const Color latteRosewater = Color(0xFFdc8a78);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: mochaLavender,
        onPrimary: mochaBase,
        primaryContainer: mochaMantle,
        onPrimaryContainer: mochaText,
        secondary: mochaMauve,
        onSecondary: mochaBase,
        secondaryContainer: mochaMantle,
        onSecondaryContainer: mochaText,
        tertiary: mochaSapphire,
        onTertiary: mochaBase,
        error: mochaRed,
        onError: mochaBase,
        errorContainer: mochaMantle,
        onErrorContainer: mochaText,
        surface: mochaMantle,
        onSurface: mochaText,
        surfaceContainerHighest: mochaSurface0,
        outline: mochaSurface1,
        outlineVariant: mochaSurface0,
      ),
      scaffoldBackgroundColor: mochaBase,
      appBarTheme: AppBarTheme(
        backgroundColor: mochaBase,
        foregroundColor: mochaText,
        surfaceTintColor: mochaLavender,
        titleTextStyle: AppTypography.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: mochaText),
      ),
      cardTheme: const CardThemeData(color: mochaMantle, surfaceTintColor: mochaLavender),
      dividerTheme: const DividerThemeData(color: mochaSurface0),
      iconTheme: const IconThemeData(color: mochaSubtext0),
      listTileTheme: ListTileThemeData(
        textColor: mochaText,
        iconColor: mochaSubtext0,
        titleTextStyle: AppTypography.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: mochaText),
        subtitleTextStyle: AppTypography.dmSans(fontSize: 14, color: mochaSubtext0),
      ),
      textTheme: AppTypography.textTheme(bodyColor: mochaText, headlineColor: mochaText, captionColor: mochaSurface1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mochaLavender,
        foregroundColor: mochaBase,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mochaLavender,
          foregroundColor: mochaBase,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mochaLavender,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mochaMantle,
        border: const OutlineInputBorder(borderSide: BorderSide(color: mochaSurface0)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: mochaSurface0)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: mochaLavender)),
        labelStyle: AppTypography.dmSans(color: mochaSurface1),
        hintStyle: AppTypography.dmSans(color: mochaSurface1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: mochaMantle,
        contentTextStyle: AppTypography.dmSans(color: mochaText),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: latteLavender,
        onPrimary: latteBase,
        primaryContainer: latteMantle,
        onPrimaryContainer: latteText,
        secondary: latteMauve,
        onSecondary: latteBase,
        secondaryContainer: latteMantle,
        onSecondaryContainer: latteText,
        tertiary: latteSapphire,
        onTertiary: latteBase,
        error: latteRed,
        onError: latteBase,
        errorContainer: latteMantle,
        onErrorContainer: latteText,
        surface: latteMantle,
        onSurface: latteText,
        surfaceContainerHighest: latteSurface0,
        outline: latteSurface1,
        outlineVariant: latteSurface0,
      ),
      scaffoldBackgroundColor: latteBase,
      appBarTheme: AppBarTheme(
        backgroundColor: latteBase,
        foregroundColor: latteText,
        surfaceTintColor: latteLavender,
        titleTextStyle: AppTypography.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: latteText),
      ),
      cardTheme: const CardThemeData(color: latteMantle, surfaceTintColor: latteLavender),
      dividerTheme: const DividerThemeData(color: latteSurface0),
      iconTheme: const IconThemeData(color: latteSubtext0),
      listTileTheme: ListTileThemeData(
        textColor: latteText,
        iconColor: latteSubtext0,
        titleTextStyle: AppTypography.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: latteText),
        subtitleTextStyle: AppTypography.dmSans(fontSize: 14, color: latteSubtext0),
      ),
      textTheme: AppTypography.textTheme(bodyColor: latteText, headlineColor: latteText, captionColor: latteSurface1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: latteLavender,
        foregroundColor: latteBase,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: latteLavender,
          foregroundColor: latteBase,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: latteLavender,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: latteMantle,
        border: const OutlineInputBorder(borderSide: BorderSide(color: latteSurface0)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: latteSurface0)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: latteLavender)),
        labelStyle: AppTypography.dmSans(color: latteSurface1),
        hintStyle: AppTypography.dmSans(color: latteSurface1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: latteMantle,
        contentTextStyle: AppTypography.dmSans(color: latteText),
      ),
    );
  }
}
