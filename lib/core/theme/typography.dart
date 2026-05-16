import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppHeadingFontFamily {
  lora('lora', 'Lora'),
  crimsonPro('crimsonPro', 'Crimson Pro'),
  playfairDisplay('playfairDisplay', 'Playfair Display'),
  merriweather('merriweather', 'Merriweather'),
  averiaSerifLibre('averiaSerifLibre', 'Averia Serif Libre');

  const AppHeadingFontFamily(this.key, this.label);

  final String key;
  final String label;
}

enum AppContentFontFamily {
  googleSans('googleSans', 'Google Sans'),
  dmSans('dmSans', 'DM Sans'),
  publicSans('publicSans', 'Public Sans'),
  openSans('openSans', 'Open Sans');

  const AppContentFontFamily(this.key, this.label);

  final String key;
  final String label;
}

enum AppCodeFontFamily {
  googleSansCode('googleSansCode', 'Google Sans Code'),
  jetBrainsMono('jetBrainsMono', 'JetBrains Mono'),
  firaCode('firaCode', 'Fira Code'),
  sourceCodePro('sourceCodePro', 'Source Code Pro');

  const AppCodeFontFamily(this.key, this.label);

  final String key;
  final String label;
}

@immutable
class AppFontTheme extends ThemeExtension<AppFontTheme> {
  const AppFontTheme({required this.headingFontFamily, required this.contentFontFamily, required this.codeFontFamily});

  static const defaults = AppFontTheme(
    headingFontFamily: AppHeadingFontFamily.lora,
    contentFontFamily: AppContentFontFamily.googleSans,
    codeFontFamily: AppCodeFontFamily.googleSansCode,
  );

  final AppHeadingFontFamily headingFontFamily;
  final AppContentFontFamily contentFontFamily;
  final AppCodeFontFamily codeFontFamily;

  TextStyle codeTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => AppTypography.code(
    codeFontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );

  @override
  AppFontTheme copyWith({
    AppHeadingFontFamily? headingFontFamily,
    AppContentFontFamily? contentFontFamily,
    AppCodeFontFamily? codeFontFamily,
  }) => AppFontTheme(
    headingFontFamily: headingFontFamily ?? this.headingFontFamily,
    contentFontFamily: contentFontFamily ?? this.contentFontFamily,
    codeFontFamily: codeFontFamily ?? this.codeFontFamily,
  );

  @override
  AppFontTheme lerp(ThemeExtension<AppFontTheme>? other, double t) {
    if (other is! AppFontTheme || t < 0.5) {
      return this;
    }
    return other;
  }
}

class AppTypography {
  AppTypography._();

  static bool _disableFontsForTests = false;

  static void disableFontsForTests() {
    _disableFontsForTests = true;
  }

  static void enableFonts() {
    _disableFontsForTests = false;
  }

  static TextStyle googleSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    if (_disableFontsForTests) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return GoogleFonts.googleSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle lora({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    if (_disableFontsForTests) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return GoogleFonts.lora(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle googleSansCode({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    if (_disableFontsForTests) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return GoogleFonts.googleSansCode(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle heading(
    AppHeadingFontFamily fontFamily, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return switch (fontFamily) {
      AppHeadingFontFamily.lora => _font(GoogleFonts.lora, fontSize, fontWeight, color, letterSpacing, height),
      AppHeadingFontFamily.crimsonPro => _font(
        GoogleFonts.crimsonPro,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppHeadingFontFamily.playfairDisplay => _font(
        GoogleFonts.playfairDisplay,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppHeadingFontFamily.merriweather => _font(
        GoogleFonts.merriweather,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppHeadingFontFamily.averiaSerifLibre => _font(
        GoogleFonts.averiaSerifLibre,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
    };
  }

  static TextStyle content(
    AppContentFontFamily fontFamily, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return switch (fontFamily) {
      AppContentFontFamily.googleSans => _font(
        GoogleFonts.googleSans,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppContentFontFamily.dmSans => _font(GoogleFonts.dmSans, fontSize, fontWeight, color, letterSpacing, height),
      AppContentFontFamily.publicSans => _font(
        GoogleFonts.publicSans,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppContentFontFamily.openSans => _font(GoogleFonts.openSans, fontSize, fontWeight, color, letterSpacing, height),
    };
  }

  static TextStyle code(
    AppCodeFontFamily fontFamily, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return switch (fontFamily) {
      AppCodeFontFamily.googleSansCode => _font(
        GoogleFonts.googleSansCode,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppCodeFontFamily.jetBrainsMono => _font(
        GoogleFonts.jetBrainsMono,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
      AppCodeFontFamily.firaCode => _font(GoogleFonts.firaCode, fontSize, fontWeight, color, letterSpacing, height),
      AppCodeFontFamily.sourceCodePro => _font(
        GoogleFonts.sourceCodePro,
        fontSize,
        fontWeight,
        color,
        letterSpacing,
        height,
      ),
    };
  }

  static TextTheme textTheme({
    Color? bodyColor,
    Color? headlineColor,
    Color? captionColor,
    AppHeadingFontFamily headingFontFamily = AppHeadingFontFamily.lora,
    AppContentFontFamily contentFontFamily = AppContentFontFamily.googleSans,
  }) {
    return TextTheme(
      displayLarge: heading(
        headingFontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: headlineColor,
        letterSpacing: -0.25,
      ),
      displayMedium: heading(headingFontFamily, fontSize: 45, fontWeight: FontWeight.w400, color: headlineColor),
      displaySmall: heading(headingFontFamily, fontSize: 36, fontWeight: FontWeight.w400, color: headlineColor),
      headlineLarge: heading(headingFontFamily, fontSize: 32, fontWeight: FontWeight.w600, color: headlineColor),
      headlineMedium: heading(headingFontFamily, fontSize: 28, fontWeight: FontWeight.w600, color: headlineColor),
      headlineSmall: heading(headingFontFamily, fontSize: 24, fontWeight: FontWeight.w600, color: headlineColor),
      titleLarge: heading(headingFontFamily, fontSize: 22, fontWeight: FontWeight.w600, color: bodyColor),
      titleMedium: heading(
        headingFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        letterSpacing: 0.15,
      ),
      titleSmall: heading(
        headingFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: content(
        contentFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: bodyColor,
        letterSpacing: 0.5,
      ),
      bodyMedium: content(
        contentFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: bodyColor,
        letterSpacing: 0.25,
      ),
      bodySmall: content(
        contentFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: captionColor,
        letterSpacing: 0.4,
      ),
      labelLarge: content(
        contentFontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        letterSpacing: 0.1,
      ),
      labelMedium: content(
        contentFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: bodyColor,
        letterSpacing: 0.5,
      ),
      labelSmall: content(
        contentFontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: captionColor,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData applyFontTheme(
    ThemeData theme, {
    required AppHeadingFontFamily headingFontFamily,
    required AppContentFontFamily contentFontFamily,
    required AppCodeFontFamily codeFontFamily,
  }) {
    final bodyColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurface;
    final headlineColor = theme.textTheme.headlineMedium?.color ?? theme.colorScheme.onSurface;
    final captionColor = theme.textTheme.bodySmall?.color ?? theme.colorScheme.onSurfaceVariant;
    final updatedTextTheme = textTheme(
      bodyColor: bodyColor,
      headlineColor: headlineColor,
      captionColor: captionColor,
      headingFontFamily: headingFontFamily,
      contentFontFamily: contentFontFamily,
    );
    final fontTheme = AppFontTheme(
      headingFontFamily: headingFontFamily,
      contentFontFamily: contentFontFamily,
      codeFontFamily: codeFontFamily,
    );

    return theme.copyWith(
      textTheme: updatedTextTheme,
      extensions: [...theme.extensions.values.where((extension) => extension is! AppFontTheme), fontTheme],
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: heading(
          headingFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.appBarTheme.titleTextStyle?.color ?? theme.appBarTheme.foregroundColor,
        ),
      ),
      listTileTheme: theme.listTileTheme.copyWith(
        titleTextStyle: content(
          contentFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: theme.listTileTheme.titleTextStyle?.color ?? theme.listTileTheme.textColor,
        ),
        subtitleTextStyle: content(
          contentFontFamily,
          fontSize: 14,
          color: theme.listTileTheme.subtitleTextStyle?.color ?? theme.colorScheme.onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: theme.elevatedButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(content(contentFontFamily, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: theme.textButtonTheme.style?.copyWith(
          textStyle: WidgetStatePropertyAll(content(contentFontFamily, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        labelStyle: content(contentFontFamily, color: theme.inputDecorationTheme.labelStyle?.color),
        hintStyle: content(contentFontFamily, color: theme.inputDecorationTheme.hintStyle?.color),
      ),
      snackBarTheme: theme.snackBarTheme.copyWith(
        contentTextStyle: content(contentFontFamily, color: theme.snackBarTheme.contentTextStyle?.color),
      ),
    );
  }

  static AppHeadingFontFamily parseHeadingFontFamily(String? value) => AppHeadingFontFamily.values.firstWhere(
    (fontFamily) => fontFamily.key == value,
    orElse: () => AppHeadingFontFamily.lora,
  );

  static AppContentFontFamily parseContentFontFamily(String? value) => AppContentFontFamily.values.firstWhere(
    (fontFamily) => fontFamily.key == value,
    orElse: () => AppContentFontFamily.googleSans,
  );

  static AppCodeFontFamily parseCodeFontFamily(String? value) => AppCodeFontFamily.values.firstWhere(
    (fontFamily) => fontFamily.key == value,
    orElse: () => AppCodeFontFamily.googleSansCode,
  );

  static TextStyle _font(
    TextStyle Function({
      Color? backgroundColor,
      Color? color,
      List<FontFeature>? fontFeatures,
      double? fontSize,
      FontStyle? fontStyle,
      FontWeight? fontWeight,
      Color? decorationColor,
      TextDecoration? decoration,
      TextDecorationStyle? decorationStyle,
      double? decorationThickness,
      List<Shadow>? shadows,
      double? height,
      Locale? locale,
      double? letterSpacing,
      TextBaseline? textBaseline,
      TextStyle? textStyle,
      double? wordSpacing,
    })
    fontBuilder,
    double fontSize,
    FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  ) {
    if (_disableFontsForTests) {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );
    }

    return fontBuilder(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}
