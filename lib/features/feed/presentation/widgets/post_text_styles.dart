import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

TextStyle? feedPostBodyTextStyle(BuildContext context, {bool compact = false, bool nested = false}) {
  final color = context.colorScheme.onSurface;
  final configuredFontSize = context.fontTheme.contentFontSize.value;

  if (compact) {
    return context.textTheme.titleSmall?.copyWith(
      color: color,
      fontSize: nested ? configuredFontSize - 2 : configuredFontSize,
      height: 1.45,
      letterSpacing: 0,
    );
  }

  final baseStyle = nested ? context.textTheme.titleSmall : context.textTheme.titleMedium;
  return baseStyle?.copyWith(
    color: color,
    fontSize: nested ? configuredFontSize - 2 : configuredFontSize,
    height: nested ? 1.5 : 1.55,
    letterSpacing: nested ? 0 : -0.35,
  );
}
