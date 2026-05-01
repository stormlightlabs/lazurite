import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

/// Shades of Purple — dark theme by Alexander Keliris (Rigellute).
/// https://github.com/Rigellute/shades-of-purple.vim
///
/// Light mode specific colors are L0-L6
class PurpleTheme {
  PurpleTheme._();

  /// darkest bg (ColorColumn, WildMenu)
  static const Color sop0 = Color(0xFF1E1E3F);

  /// panel bg (LineNr bg, VertSplit bg)
  static const Color sop1 = Color(0xFF28284E);

  /// main bg (Normal bg)
  static const Color sop2 = Color(0xFF2D2B55);

  /// muted lavender (LineNr fg, NonText)
  static const Color sop3 = Color(0xFFA599E9);

  /// main fg (Normal fg)
  static const Color sop4 = Color(0xFFE1EFFF);

  /// cyan (Special, Title)
  static const Color sop5 = Color(0xFF9EFFFF);

  /// yellow (Cursor, WarningMsg)
  static const Color sop6 = Color(0xFFFAD000);

  /// orange (Function, Identifier)
  static const Color sop7 = Color(0xFFFF9D00);

  /// vivid purple (Comment)
  static const Color sop8 = Color(0xFFB362FF);

  /// pink-rose (Constant, SpellBad)
  static const Color sop9 = Color(0xFFFF628C);

  /// green (String)
  static const Color sop10 = Color(0xFFA5FF90);

  /// red (Error, DiffDelete)
  static const Color sop11 = Color(0xFFEC3A37);

  /// teal (Type)
  static const Color sop12 = Color(0xFF80FFBB);

  /// light magenta (jsThis, jsFunction)
  static const Color sop13 = Color(0xFFFB94FF);

  /// blue (terminal blue)
  static const Color sop14 = Color(0xFF6943FF);

  // Semi-transparent overlay for subtle dark-mode borders/dividers
  static const Color darkOutlineVariant = Color(0x26A599E9); // lavender ~15% opacity

  /// lightest bg (scaffold)
  static const Color sopL0 = Color(0xFFF8F6FF);

  /// panel bg (cards, surfaces)
  static const Color sopL1 = Color(0xFFEDE9FF);

  /// border / divider
  static const Color sopL2 = Color(0xFFD6CEFF);

  /// muted purple (secondary text)
  static const Color sopL3 = Color(0xFF8B7FD4);

  /// main fg (body text = sop2)
  static const Color sopL4 = Color(0xFF2D2B55);

  /// primary accent (sop14)
  static const Color sopL5 = Color(0xFF6943FF);

  /// secondary accent
  static const Color sopL6 = Color(0xFF7B6EC0);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: sop3,
        onPrimary: sop0,
        primaryContainer: sop1,
        onPrimaryContainer: sop4,
        secondary: sop5,
        onSecondary: sop0,
        secondaryContainer: sop1,
        onSecondaryContainer: sop4,
        tertiary: sop8,
        onTertiary: sop0,
        error: sop11,
        onError: sop4,
        errorContainer: sop1,
        onErrorContainer: sop4,
        surface: sop1,
        onSurface: sop4,
        surfaceContainerHighest: sop2,
        outline: sop3,
        outlineVariant: darkOutlineVariant,
      ),
      scaffoldBackgroundColor: sop0,
      appBarTheme: AppBarTheme(
        backgroundColor: sop0,
        foregroundColor: sop4,
        surfaceTintColor: sop3,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: sop4),
      ),
      cardTheme: const CardThemeData(color: sop1, surfaceTintColor: sop3),
      dividerTheme: const DividerThemeData(color: darkOutlineVariant),
      iconTheme: const IconThemeData(color: sop3),
      listTileTheme: ListTileThemeData(
        textColor: sop4,
        iconColor: sop3,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: sop4),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: sop3),
      ),
      textTheme: AppTypography.textTheme(bodyColor: sop4, headlineColor: sop4, captionColor: sop3),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: sop3, foregroundColor: sop0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sop3,
          foregroundColor: sop0,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: sop3,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sop1,
        border: const OutlineInputBorder(borderSide: BorderSide(color: sop1)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: sop1)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sop3)),
        labelStyle: AppTypography.googleSans(color: sop3),
        hintStyle: AppTypography.googleSans(color: sop3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: sop1,
        contentTextStyle: AppTypography.googleSans(color: sop4),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: sopL5,
        onPrimary: sopL0,
        primaryContainer: sopL1,
        onPrimaryContainer: sopL4,
        secondary: sopL6,
        onSecondary: sopL0,
        secondaryContainer: sopL1,
        onSecondaryContainer: sopL4,
        tertiary: sop8,
        onTertiary: sopL0,
        error: sop11,
        onError: sopL0,
        errorContainer: sopL1,
        onErrorContainer: sopL4,
        surface: sopL1,
        onSurface: sopL4,
        surfaceContainerHighest: sopL2,
        outline: sopL3,
        outlineVariant: sopL2,
      ),
      scaffoldBackgroundColor: sopL0,
      appBarTheme: AppBarTheme(
        backgroundColor: sopL0,
        foregroundColor: sopL4,
        surfaceTintColor: sopL5,
        titleTextStyle: AppTypography.googleSans(fontSize: 18, fontWeight: FontWeight.w600, color: sopL4),
      ),
      cardTheme: const CardThemeData(color: sopL1, surfaceTintColor: sopL5),
      dividerTheme: const DividerThemeData(color: sopL2),
      iconTheme: const IconThemeData(color: sopL3),
      listTileTheme: ListTileThemeData(
        textColor: sopL4,
        iconColor: sopL3,
        titleTextStyle: AppTypography.googleSans(fontSize: 16, fontWeight: FontWeight.w500, color: sopL4),
        subtitleTextStyle: AppTypography.googleSans(fontSize: 14, color: sopL3),
      ),
      textTheme: AppTypography.textTheme(bodyColor: sopL4, headlineColor: sopL4, captionColor: sopL3),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: sopL5, foregroundColor: sopL0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sopL5,
          foregroundColor: sopL0,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: sopL5,
          textStyle: AppTypography.googleSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sopL1,
        border: const OutlineInputBorder(borderSide: BorderSide(color: sopL2)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: sopL2)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: sopL5)),
        labelStyle: AppTypography.googleSans(color: sopL3),
        hintStyle: AppTypography.googleSans(color: sopL3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: sopL1,
        contentTextStyle: AppTypography.googleSans(color: sopL4),
      ),
    );
  }
}
