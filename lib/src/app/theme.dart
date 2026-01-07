import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// IBM Oxocarbon-inspired color palette with BlueSky blue accent.
abstract final class AppColors {
  static const Color darkBackground = Color(0xFF161616);
  static const Color darkSurface = Color(0xFF262626);
  static const Color darkSurfaceVariant = Color(0xFF393939);
  static const Color darkOutline = Color(0xFF525252);
  static const Color darkOnBackground = Color(0xFFF2F4F8);
  static const Color darkOnSurface = Color(0xFFDDE1E6);

  static const Color lightBackground = Color(0xFFF2F4F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFDDE1E6);
  static const Color lightOutline = Color(0xFF525252);
  static const Color lightOnBackground = Color(0xFF161616);
  static const Color lightOnSurface = Color(0xFF262626);

  static const Color primary = Color(0xFF0085FF);
  static const Color secondary = Color(0xFF78A9FF);
  static const Color tertiary = Color(0xFF33B1FF);
  static const Color error = Color(0xFFEE5396);
  static const Color success = Color(0xFF42BE65);
  static const Color warning = Color(0xFFFF7EB6);

  static const Color cyan = Color(0xFF08BDBA);
  static const Color cyanLight = Color(0xFF3DDBD9);
  static const Color purple = Color(0xFFBE95FF);
  static const Color blueLight = Color(0xFF82CFFF);
  static const Color textSecondary = Color(0xFF697689);
}

/// App theme configuration with IBM Oxocarbon colors.
abstract final class AppTheme {
  /// Dark theme based on IBM Oxocarbon Dark palette.
  static ThemeData get dark {
    final textTheme = _buildTextTheme(AppColors.darkOnBackground);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.darkBackground,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        onError: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        outline: AppColors.darkOutline,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primary.withAlpha(51),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
      ),
      cardTheme: const CardThemeData(color: AppColors.darkSurface, elevation: 0),
    );
  }

  /// Light theme based on IBM Oxocarbon Light palette.
  static ThemeData get light {
    final textTheme = _buildTextTheme(AppColors.lightOnBackground);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.lightBackground,
        secondary: AppColors.secondary,
        onSecondary: AppColors.lightBackground,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
        onError: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        outline: AppColors.lightOutline,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.primary.withAlpha(51),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
      ),
      cardTheme: const CardThemeData(color: AppColors.lightSurface, elevation: 0),
    );
  }

  /// Builds the text theme with custom fonts.
  /// - Crimson Pro for display styles
  /// - Atkinson Hyperlegible for body/label styles
  /// - Fira Code for code (available via bodySmall)
  static TextTheme _buildTextTheme(Color color) {
    final displayStyle = GoogleFonts.crimsonPro(color: color);
    final bodyStyle = GoogleFonts.atkinsonHyperlegible(color: color);
    final monoStyle = GoogleFonts.firaCode(color: color);

    return TextTheme(
      displayLarge: displayStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: displayStyle.copyWith(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: displayStyle.copyWith(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: displayStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w400),
      headlineMedium: displayStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w400),
      headlineSmall: displayStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w400),
      titleLarge: bodyStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
      titleMedium: bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      bodyLarge: bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: monoStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: bodyStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: bodyStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: bodyStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
