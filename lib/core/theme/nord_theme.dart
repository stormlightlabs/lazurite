import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

class NordTheme {
  NordTheme._();

  static const Color nord0 = Color(0xFF2e3440);
  static const Color nord1 = Color(0xFF3b4252);
  static const Color nord2 = Color(0xFF434c5e);
  static const Color nord3 = Color(0xFF4c566a);
  static const Color nord4 = Color(0xFFd8dee9);
  static const Color nord5 = Color(0xFFe5e9f0);
  static const Color nord6 = Color(0xFFeceff4);
  static const Color nord7 = Color(0xFF8fbcbb);
  static const Color nord8 = Color(0xFF88c0d0);
  static const Color nord9 = Color(0xFF81a1c1);
  static const Color nord10 = Color(0xFF5e81ac);
  static const Color nord11 = Color(0xFFbf616a);
  static const Color nord12 = Color(0xFFd08770);
  static const Color nord13 = Color(0xFFebcb8b);
  static const Color nord14 = Color(0xFFa3be8c);
  static const Color nord15 = Color(0xFFb48ead);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: nord8,
        onPrimary: nord0,
        primaryContainer: nord1,
        onPrimaryContainer: nord5,
        secondary: nord9,
        onSecondary: nord0,
        secondaryContainer: nord1,
        onSecondaryContainer: nord5,
        tertiary: nord7,
        onTertiary: nord0,
        error: nord11,
        onError: nord6,
        errorContainer: nord1,
        onErrorContainer: nord5,
        surface: nord1,
        onSurface: nord5,
        surfaceContainerHighest: nord2,
        outline: nord3,
        outlineVariant: nord2,
      ),
      scaffoldBackgroundColor: nord0,
      appBarTheme: AppBarTheme(
        backgroundColor: nord0,
        foregroundColor: nord5,
        surfaceTintColor: nord8,
        titleTextStyle: AppTypography.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: nord5),
      ),
      cardTheme: const CardThemeData(color: nord1, surfaceTintColor: nord8),
      dividerTheme: const DividerThemeData(color: nord2),
      iconTheme: const IconThemeData(color: nord4),
      listTileTheme: ListTileThemeData(
        textColor: nord5,
        iconColor: nord4,
        titleTextStyle: AppTypography.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: nord5),
        subtitleTextStyle: AppTypography.dmSans(fontSize: 14, color: nord4),
      ),
      textTheme: AppTypography.textTheme(bodyColor: nord5, headlineColor: nord6, captionColor: nord3),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: nord8, foregroundColor: nord0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nord8,
          foregroundColor: nord0,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nord8,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nord1,
        border: OutlineInputBorder(borderSide: const BorderSide(color: nord2)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: nord2)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: nord8)),
        labelStyle: AppTypography.dmSans(color: nord3),
        hintStyle: AppTypography.dmSans(color: nord3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: nord1,
        contentTextStyle: AppTypography.dmSans(color: nord5),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: nord8,
        onPrimary: nord0,
        primaryContainer: nord1,
        onPrimaryContainer: nord3,
        secondary: nord9,
        onSecondary: nord6,
        secondaryContainer: nord1,
        onSecondaryContainer: nord3,
        tertiary: nord7,
        onTertiary: nord0,
        error: nord11,
        onError: nord6,
        errorContainer: nord1,
        onErrorContainer: nord3,
        surface: nord1,
        onSurface: nord3,
        surfaceContainerHighest: nord2,
        outline: nord3,
        outlineVariant: nord2,
      ),
      scaffoldBackgroundColor: nord6,
      appBarTheme: AppBarTheme(
        backgroundColor: nord6,
        foregroundColor: nord3,
        surfaceTintColor: nord8,
        titleTextStyle: AppTypography.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: nord3),
      ),
      cardTheme: const CardThemeData(color: nord5, surfaceTintColor: nord8),
      dividerTheme: const DividerThemeData(color: nord2),
      iconTheme: const IconThemeData(color: nord4),
      listTileTheme: ListTileThemeData(
        textColor: nord3,
        iconColor: nord4,
        titleTextStyle: AppTypography.dmSans(fontSize: 16, fontWeight: FontWeight.w500, color: nord3),
        subtitleTextStyle: AppTypography.dmSans(fontSize: 14, color: nord4),
      ),
      textTheme: AppTypography.textTheme(bodyColor: nord3, headlineColor: nord0, captionColor: nord3),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: nord8, foregroundColor: nord0),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: nord8,
          foregroundColor: nord0,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: nord8,
          textStyle: AppTypography.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: nord5,
        border: OutlineInputBorder(borderSide: const BorderSide(color: nord2)),
        enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: nord2)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: nord8)),
        labelStyle: AppTypography.dmSans(color: nord3),
        hintStyle: AppTypography.dmSans(color: nord3),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: nord5,
        contentTextStyle: AppTypography.dmSans(color: nord3),
      ),
    );
  }
}
