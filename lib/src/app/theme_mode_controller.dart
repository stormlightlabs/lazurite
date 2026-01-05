import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_controller.g.dart';

/// Controls the current [ThemeMode] for the application.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() => ThemeMode.dark;

  /// Switches between light and dark modes.
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  /// Explicitly sets the theme mode.
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
