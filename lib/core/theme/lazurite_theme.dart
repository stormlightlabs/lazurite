import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

class LazuriteTheme {
  LazuriteTheme._();

  static const Color darkPrimary = Color(0xFF7dafff);
  static const Color darkOnPrimary = Color(0xFF05080f);
  static const Color darkPrimaryContainer = Color(0xFF0073de);
  static const Color darkOnPrimaryContainer = Color(0xFFf4f6fb);
  static const Color darkSurface = Color(0xFF0e0e0e);
  static const Color darkOnSurface = Color(0xFFf4f6fb);
  static const Color darkSurfaceVariant = Color(0xFF191919);
  static const Color darkOnSurfaceVariant = Color(0xFFababab);
  static const Color darkSurfaceContainerLowest = Color(0xFF000000);
  static const Color darkSurfaceContainer = Color(0xFF191919);
  static const Color darkSurfaceContainerHigh = Color(0xFF1f1f1f);
  static const Color darkSurfaceContainerHighest = Color(0xF5242424);
  static const Color darkSurfaceBright = Color(0x0Dffffff);
  static const Color darkOutline = Color(0x33ffffff);
  static const Color darkOutlineVariant = Color(0x1Affffff);
  static const Color darkError = Color(0xFFff8080);
  static const Color darkErrorContainer = Color(0xB88a1f1f);

  static const Color lightPrimary = Color(0xFF0b63d1);
  static const Color lightOnPrimary = Color(0xFFffffff);
  static const Color lightPrimaryContainer = Color(0xFF0953af);
  static const Color lightOnPrimaryContainer = Color(0xFFffffff);
  static const Color lightSurface = Color(0xFFffffff);
  static const Color lightOnSurface = Color(0xFF101418);
  static const Color lightSurfaceVariant = Color(0xFFf4f6f9);
  static const Color lightOnSurfaceVariant = Color(0xFF45505e);
  static const Color lightSurfaceContainerLowest = Color(0xFFeef1f5);
  static const Color lightSurfaceContainer = Color(0xFFf4f6f9);
  static const Color lightSurfaceContainerHigh = Color(0xFFeceff4);
  static const Color lightSurfaceContainerHighest = Color(0xF5f6f8fc);
  static const Color lightSurfaceBright = Color(0x0F111827);
  static const Color lightOutline = Color(0x3D111827);
  static const Color lightOutlineVariant = Color(0x24111827);
  static const Color lightError = Color(0xFFb42318);
  static const Color lightErrorContainer = Color(0xF2fee2e2);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkPrimaryContainer,
        onSecondary: darkOnPrimaryContainer,
        secondaryContainer: darkSurfaceContainer,
        onSecondaryContainer: darkOnSurface,
        tertiary: darkPrimary,
        onTertiary: darkOnPrimary,
        tertiaryContainer: darkSurfaceContainerHigh,
        onTertiaryContainer: darkOnSurface,
        error: darkError,
        onError: darkOnPrimary,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnSurface,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceBright: darkSurfaceBright,
        surfaceContainerLowest: darkSurfaceContainerLowest,
        surfaceContainerLow: darkSurfaceVariant,
        surfaceContainer: darkSurfaceContainer,
        surfaceContainerHigh: darkSurfaceContainerHigh,
        surfaceContainerHighest: darkSurfaceContainerHighest,
        onSurfaceVariant: darkOnSurfaceVariant,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
        inverseSurface: lightSurface,
        onInverseSurface: lightOnSurface,
        inversePrimary: lightPrimary,
        surfaceTint: darkPrimary,
      ),
      scaffoldBackgroundColor: darkSurfaceContainerLowest,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurfaceContainerLowest,
        foregroundColor: darkOnSurface,
        surfaceTintColor: darkPrimary,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: darkOnSurface),
      ),
      cardTheme: const CardThemeData(color: darkSurfaceContainer, surfaceTintColor: darkPrimary),
      dividerTheme: const DividerThemeData(color: darkOutlineVariant),
      iconTheme: const IconThemeData(color: darkOnSurfaceVariant),
      listTileTheme: ListTileThemeData(
        textColor: darkOnSurface,
        iconColor: darkOnSurfaceVariant,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: darkOnSurface),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: darkOnSurfaceVariant),
      ),
      textTheme: AppTypography.textTheme(
        bodyColor: darkOnSurface,
        headlineColor: darkOnSurface,
        captionColor: darkOnSurfaceVariant,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainerHigh,
        border: const OutlineInputBorder(borderSide: BorderSide(color: darkOutlineVariant)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkOutlineVariant)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkPrimary)),
        labelStyle: AppTypography.googleSans(color: darkOnSurfaceVariant),
        hintStyle: AppTypography.googleSans(color: darkOnSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceContainerHighest,
        contentTextStyle: AppTypography.googleSans(color: darkOnSurface),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightPrimaryContainer,
        onSecondary: lightOnPrimaryContainer,
        secondaryContainer: lightSurfaceContainer,
        onSecondaryContainer: lightOnSurface,
        tertiary: lightPrimary,
        onTertiary: lightOnPrimary,
        tertiaryContainer: lightSurfaceContainerHigh,
        onTertiaryContainer: lightOnSurface,
        error: lightError,
        onError: lightOnPrimary,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightOnSurface,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceBright: lightSurfaceBright,
        surfaceContainerLowest: lightSurfaceContainerLowest,
        surfaceContainerLow: lightSurfaceVariant,
        surfaceContainer: lightSurfaceContainer,
        surfaceContainerHigh: lightSurfaceContainerHigh,
        surfaceContainerHighest: lightSurfaceContainerHighest,
        onSurfaceVariant: lightOnSurfaceVariant,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
        inverseSurface: darkSurface,
        onInverseSurface: darkOnSurface,
        inversePrimary: darkPrimary,
        surfaceTint: lightPrimary,
      ),
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        surfaceTintColor: lightPrimary,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: lightOnSurface),
      ),
      cardTheme: const CardThemeData(color: lightSurfaceContainer, surfaceTintColor: lightPrimary),
      dividerTheme: const DividerThemeData(color: lightOutlineVariant),
      iconTheme: const IconThemeData(color: lightOnSurfaceVariant),
      listTileTheme: ListTileThemeData(
        textColor: lightOnSurface,
        iconColor: lightOnSurfaceVariant,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: lightOnSurface),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: lightOnSurfaceVariant),
      ),
      textTheme: AppTypography.textTheme(
        bodyColor: lightOnSurface,
        headlineColor: lightOnSurface,
        captionColor: lightOnSurfaceVariant,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: lightOnPrimary,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceContainer,
        border: const OutlineInputBorder(borderSide: BorderSide(color: lightOutlineVariant)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightOutlineVariant)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: lightPrimary)),
        labelStyle: AppTypography.googleSans(color: lightOnSurfaceVariant),
        hintStyle: AppTypography.googleSans(color: lightOnSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightSurfaceContainerHighest,
        contentTextStyle: AppTypography.googleSans(color: lightOnSurface),
      ),
    );
  }
}
