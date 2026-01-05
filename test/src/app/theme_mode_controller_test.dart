import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/app/theme_mode_controller.dart';

void main() {
  test('themeModeProvider defaults to dark mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('ThemeModeController.toggle switches between modes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(themeModeControllerProvider.notifier);

    notifier.toggle();
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    notifier.toggle();
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });

  test('ThemeModeController.setThemeMode updates the mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(themeModeControllerProvider.notifier);

    notifier.setThemeMode(ThemeMode.light);
    expect(container.read(themeModeControllerProvider), ThemeMode.light);

    notifier.setThemeMode(ThemeMode.dark);
    expect(container.read(themeModeControllerProvider), ThemeMode.dark);
  });
}
