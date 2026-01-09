import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/debug/debug.dart';
import 'package:lazurite/src/features/feeds/application/feed_sync_controller.dart';
import 'package:lazurite/src/features/settings/application/preference_sync_controller.dart';

/// The main application widget.
///
/// Configures theming, routing, and Riverpod.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeState = ref.watch(themeControllerProvider);
    final authState = ref.watch(authProvider);
    ref.watch(feedSyncControllerProvider);
    ref.watch(preferenceSyncControllerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(themeControllerProvider.notifier).setSystemSchemes(lightDynamic, darkDynamic);
        });

        return MaterialApp.router(
          key: ValueKey(authState is AuthStateAuthenticated),
          title: 'Lazurite',
          theme: themeState.lightTheme,
          darkTheme: themeState.darkTheme,
          themeMode: themeState.themeMode,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          builder: (context, child) => DebugOverlayHost(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
