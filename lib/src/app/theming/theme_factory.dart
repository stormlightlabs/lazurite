import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lazurite/src/app/theming/theme_variant.dart';

/// Factory for building [ThemeData] from a [ThemeVariant].
///
/// This centralizes all component theme construction, ensuring consistent
/// application of ColorScheme roles across the app. All component themes
/// are derived from the variant's [ColorScheme] - no hard-coded colors.
abstract final class ThemeFactory {
  /// Builds a complete [ThemeData] from a [ThemeVariant].
  ///
  /// The resulting theme uses Material 3 design with all component themes derived from the
  /// variant's [ColorScheme] roles.
  static ThemeData buildThemeData(ThemeVariant variant) {
    return _buildThemeDataFromScheme(
      variant.derivedScheme,
      variant.brightness,
      variant.spec.surfaceDim,
    );
  }

  /// Builds a complete [ThemeData] directly from a [ColorScheme].
  ///
  /// Used for dynamic colors where we don't have a [ThemeVariant].
  static ThemeData buildThemeDataFromScheme(ColorScheme scheme) {
    return _buildThemeDataFromScheme(scheme, scheme.brightness, null);
  }

  static ThemeData _buildThemeDataFromScheme(
    ColorScheme colorScheme,
    Brightness brightness,
    Color? scaffoldBackgroundColor,
  ) {
    final textTheme = _buildTextTheme(colorScheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor ?? colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: _buildAppBarTheme(colorScheme, textTheme),
      navigationBarTheme: _buildNavigationBarTheme(colorScheme, textTheme),
      cardTheme: _buildCardTheme(colorScheme),
      dividerTheme: _buildDividerTheme(colorScheme),
      chipTheme: _buildChipTheme(colorScheme),
      inputDecorationTheme: _buildInputDecorationTheme(colorScheme),
      listTileTheme: _buildListTileTheme(colorScheme),
      dialogTheme: _buildDialogTheme(colorScheme),
      bottomSheetTheme: _buildBottomSheetTheme(colorScheme),
    );
  }

  /// Builds AppBar theme from ColorScheme roles.
  static AppBarTheme _buildAppBarTheme(ColorScheme cs, TextTheme textTheme) {
    return AppBarTheme(
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: cs.onSurface),
    );
  }

  /// Builds NavigationBar theme using M3 active indicator semantics.
  ///
  /// Per M3 spec, uses container role for active indicator rather than
  /// primary tint overlay.
  static NavigationBarThemeData _buildNavigationBarTheme(ColorScheme cs, TextTheme textTheme) {
    return NavigationBarThemeData(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: cs.secondaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: cs.onSecondaryContainer);
        }
        return IconThemeData(color: cs.onSurfaceVariant);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final baseStyle = textTheme.labelMedium;
        if (states.contains(WidgetState.selected)) {
          return baseStyle?.copyWith(color: cs.onSurface);
        }
        return baseStyle?.copyWith(color: cs.onSurfaceVariant);
      }),
      elevation: 0,
    );
  }

  /// Builds Card theme using surfaceContainerLow for subtle elevation.
  static CardThemeData _buildCardTheme(ColorScheme cs) {
    return CardThemeData(
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// Builds Divider theme using outlineVariant for subtle boundaries.
  static DividerThemeData _buildDividerTheme(ColorScheme cs) {
    return DividerThemeData(color: cs.outlineVariant, thickness: 1, space: 1);
  }

  /// Builds Chip theme following M3 filter chip spec.
  ///
  /// Unselected: outline + onSurfaceVariant
  /// Selected: secondaryContainer + onSecondaryContainer
  static ChipThemeData _buildChipTheme(ColorScheme cs) {
    return ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: cs.secondaryContainer,
      disabledColor: cs.onSurface.withAlpha(31),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      secondaryLabelStyle: TextStyle(color: cs.onSecondaryContainer),
      side: BorderSide(color: cs.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  /// Builds InputDecoration theme for text fields.
  static InputDecorationTheme _buildInputDecorationTheme(ColorScheme cs) {
    return InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      floatingLabelStyle: TextStyle(color: cs.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: cs.error),
      ),
    );
  }

  /// Builds ListTile theme using on-surface roles.
  static ListTileThemeData _buildListTileTheme(ColorScheme cs) {
    return ListTileThemeData(
      textColor: cs.onSurface,
      iconColor: cs.onSurfaceVariant,
      tileColor: Colors.transparent,
      selectedTileColor: cs.secondaryContainer,
      selectedColor: cs.onSecondaryContainer,
    );
  }

  /// Builds Dialog theme using surfaceContainerHigh.
  static DialogThemeData _buildDialogTheme(ColorScheme cs) {
    return DialogThemeData(
      backgroundColor: cs.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    );
  }

  /// Builds BottomSheet theme using surfaceContainerLow.
  static BottomSheetThemeData _buildBottomSheetTheme(ColorScheme cs) {
    return BottomSheetThemeData(
      backgroundColor: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    );
  }

  /// Builds the text theme with custom fonts.
  ///
  /// - Crimson Pro for display styles
  /// - Merriweather Sans for body/label styles
  /// - Fira Code for code (available via bodySmall)
  static TextTheme _buildTextTheme(Color color) {
    final displayStyle = GoogleFonts.crimsonPro(color: color);
    final bodyStyle = GoogleFonts.merriweatherSans(color: color);
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
