import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme.dart';
import 'package:lazurite/src/app/theme_mode_controller.dart';
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
    ref.watch(feedSyncControllerProvider);

    return MaterialApp.router(
      title: 'Lazurite',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
