import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/typography.dart';

extension ThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  AppFontTheme get fontTheme => theme.extension<AppFontTheme>() ?? AppFontTheme.defaults;

  TextStyle codeTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
    double? height,
  }) => fontTheme.codeTextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
  );
}
