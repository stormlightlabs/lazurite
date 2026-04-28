import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static TextTheme textTheme({Color? bodyColor, Color? headlineColor, Color? captionColor}) {
    return TextTheme(
      displayLarge: lora(fontSize: 57, fontWeight: FontWeight.w400, color: headlineColor, letterSpacing: -0.25),
      displayMedium: lora(fontSize: 45, fontWeight: FontWeight.w400, color: headlineColor),
      displaySmall: lora(fontSize: 36, fontWeight: FontWeight.w400, color: headlineColor),
      headlineLarge: lora(fontSize: 32, fontWeight: FontWeight.w600, color: headlineColor),
      headlineMedium: lora(fontSize: 28, fontWeight: FontWeight.w600, color: headlineColor),
      headlineSmall: lora(fontSize: 24, fontWeight: FontWeight.w600, color: headlineColor),
      titleLarge: lora(fontSize: 22, fontWeight: FontWeight.w600, color: bodyColor),
      titleMedium: lora(fontSize: 16, fontWeight: FontWeight.w500, color: bodyColor, letterSpacing: 0.15),
      titleSmall: lora(fontSize: 14, fontWeight: FontWeight.w500, color: bodyColor, letterSpacing: 0.1),
      bodyLarge: googleSans(fontSize: 16, fontWeight: FontWeight.w400, color: bodyColor, letterSpacing: 0.5),
      bodyMedium: googleSans(fontSize: 14, fontWeight: FontWeight.w400, color: bodyColor, letterSpacing: 0.25),
      bodySmall: googleSans(fontSize: 12, fontWeight: FontWeight.w400, color: captionColor, letterSpacing: 0.4),
      labelLarge: googleSans(fontSize: 14, fontWeight: FontWeight.w500, color: bodyColor, letterSpacing: 0.1),
      labelMedium: googleSans(fontSize: 12, fontWeight: FontWeight.w500, color: bodyColor, letterSpacing: 0.5),
      labelSmall: googleSans(fontSize: 12, fontWeight: FontWeight.w500, color: captionColor, letterSpacing: 0.5),
    );
  }
}
