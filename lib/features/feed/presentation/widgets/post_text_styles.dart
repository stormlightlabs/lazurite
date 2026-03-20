import 'package:flutter/material.dart';

TextStyle? feedPostBodyTextStyle(BuildContext context, {bool compact = false, bool nested = false}) {
  final theme = Theme.of(context);
  final color = theme.colorScheme.onSurface;

  if (compact) {
    return theme.textTheme.bodySmall?.copyWith(color: color, height: 1.45);
  }

  final baseStyle = nested ? theme.textTheme.titleSmall : theme.textTheme.titleMedium;
  return baseStyle?.copyWith(color: color, height: nested ? 1.5 : 1.55, letterSpacing: nested ? 0 : -0.35);
}
