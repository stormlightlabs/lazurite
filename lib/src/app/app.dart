import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme_mode_controller.dart';
import 'package:lazurite/src/app/theming/packs/oxocarbon_theme_pack.dart';
import 'package:lazurite/src/app/theming/theme_factory.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';

/// The main application widget.
///
/// Configures theming, routing, and Riverpod.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final authState = ref.watch(authProvider);
    ref.watch(feedSyncControllerProvider);

    return MaterialApp.router(
      key: ValueKey(authState is AuthStateAuthenticated),
      title: 'Lazurite',
      theme: ThemeFactory.buildThemeData(oxocarbonLightVariant),
      darkTheme: ThemeFactory.buildThemeData(oxocarbonDarkVariant),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
