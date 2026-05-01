import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

/// Shades of Purple — dark theme by Alexander Keliris (Rigellute).
/// https://github.com/Rigellute/shades-of-purple.vim
///
/// Light mode specific colors are L0-L6
class PurpleTheme {
  PurpleTheme._();

  /// darkest bg
  static const Color sop0 = Color(0xFF1E1E3F);

  /// panel bg
  static const Color sop1 = Color(0xFF28284E);

  /// main bg
  static const Color sop2 = Color(0xFF2D2B55);

  /// muted lavender
  static const Color sop3 = Color(0xFFA599E9);

  /// main fg
  static const Color sop4 = Color(0xFFE1EFFF);

  /// cyan
  static const Color sop5 = Color(0xFF9EFFFF);

  /// yellow
  static const Color sop6 = Color(0xFFFAD000);

  /// orange
  static const Color sop7 = Color(0xFFFF9D00);

  /// vivid purple
  static const Color sop8 = Color(0xFFB362FF);

  /// pink-rose
  static const Color sop9 = Color(0xFFFF628C);

  /// green
  static const Color sop10 = Color(0xFFA5FF90);

  /// red
  static const Color sop11 = Color(0xFFEC3A37);

  /// teal
  static const Color sop12 = Color(0xFF80FFBB);

  /// light magenta
  static const Color sop13 = Color(0xFFFB94FF);

  /// blue
  static const Color sop14 = Color(0xFF6943FF);

  /// Surface hierarchy: darkSurface (scaffold) < darkSurfaceContainer (card) < darkSurfaceContainerHigh
  static const Color darkSurface = sop0;
  static const Color darkSurfaceContainer = sop1;
  static const Color darkSurfaceContainerHigh = sop2;

  /// Text
  static const Color darkOnSurface = sop4;

  /// secondary text / icons
  static const Color darkOnSurfaceVariant = sop3;

  /// Interactive accent — vivid purple, distinct from the muted-lavender secondary text
  static const Color darkPrimary = sop8;
  static const Color darkOnPrimary = sop0;

  /// Borders — semi-transparent lavender so they sit naturally on any dark surface
  ///
  /// ~30% — component borders
  static const Color darkOutline = Color(0x4DA599E9);

  /// ~15% — dividers
  static const Color darkOutlineVariant = Color(0x26A599E9);

  /// scaffold bg
  static const Color sopL0 = Color(0xFFF8F6FF);

  /// card / panel bg
  static const Color sopL1 = Color(0xFFEDE9FF);

  /// divider / border
  static const Color sopL2 = Color(0xFFD6CEFF);

  /// secondary text / icons
  static const Color sopL3 = Color(0xFF8B7FD4);

  /// primary text
  static const Color sopL4 = Color(0xFF2D2B55);

  /// interactive accent
  static const Color sopL5 = Color(0xFF6943FF);

  /// secondary accent
  static const Color sopL6 = Color(0xFF7B6EC0);

  static const Color lightSurface = sopL0;
  static const Color lightSurfaceContainer = sopL1;
  static const Color lightOnSurface = sopL4;
  static const Color lightOnSurfaceVariant = sopL3;
  static const Color lightPrimary = sopL5;
  static const Color lightOnPrimary = sopL0;

  /// ~30% blue-purple
  static const Color lightOutline = Color(0x4D6943FF);

  /// #D6CEFF — visible in light mode
  static const Color lightOutlineVariant = sopL2;

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkSurfaceContainer,
        onPrimaryContainer: darkOnSurface,
        secondary: sop5,
        onSecondary: darkSurface,
        secondaryContainer: darkSurfaceContainer,
        onSecondaryContainer: darkOnSurface,
        tertiary: sop3,
        onTertiary: darkSurface,
        error: sop11,
        onError: darkOnSurface,
        errorContainer: darkSurfaceContainer,
        onErrorContainer: darkOnSurface,
        surface: darkSurfaceContainer,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
        surfaceContainerHighest: darkSurfaceContainerHigh,
        outline: darkOutline,
        outlineVariant: darkOutlineVariant,
      ),
      scaffoldBackgroundColor: darkSurface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
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
        fillColor: darkSurfaceContainer,
        border: const OutlineInputBorder(borderSide: BorderSide(color: darkOutline)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkOutline)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: darkPrimary)),
        labelStyle: AppTypography.googleSans(color: darkOnSurfaceVariant),
        hintStyle: AppTypography.googleSans(color: darkOnSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceContainerHigh,
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
        primaryContainer: lightSurfaceContainer,
        onPrimaryContainer: lightOnSurface,
        secondary: sopL6,
        onSecondary: lightOnPrimary,
        secondaryContainer: lightSurfaceContainer,
        onSecondaryContainer: lightOnSurface,
        tertiary: sop3,
        onTertiary: lightOnPrimary,
        error: sop11,
        onError: lightOnPrimary,
        errorContainer: lightSurfaceContainer,
        onErrorContainer: lightOnSurface,
        surface: lightSurfaceContainer,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
        surfaceContainerHighest: lightOutlineVariant,
        outline: lightOutline,
        outlineVariant: lightOutlineVariant,
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
        backgroundColor: lightSurfaceContainer,
        contentTextStyle: AppTypography.googleSans(color: lightOnSurface),
      ),
    );
  }
}
