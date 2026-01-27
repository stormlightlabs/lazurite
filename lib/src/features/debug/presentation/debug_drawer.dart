import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/router.dart';
import 'package:lazurite/src/features/debug/application/debug_overlay_controller.dart';

import 'atproto_session_tab.dart';
import 'network_inspector_tab.dart';
import 'performance_metrics_tab.dart';
import 'system_info_tab.dart';

/// A drawer displaying debug information in tabs.
///
/// Contains tabs for:
/// - System Info: Flutter version, platform, screen size, memory, FPS
/// - ATProto Session: DID, handle, PDS host, session status
class DebugDrawer extends ConsumerWidget {
  const DebugDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlayState = ref.watch(debugOverlayControllerProvider);
    final theme = Theme.of(context);

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => Material(
            elevation: 16,
            color: theme.colorScheme.surface,
            child: SafeArea(
              left: false,
              child: DefaultTabController(
                length: 4,
                initialIndex: overlayState.activeTabIndex,
                child: Column(
                  children: [
                    _buildHeader(context, ref, theme),
                    _buildTabBar(theme),
                    const Expanded(
                      child: TabBarView(
                        children: [
                          SystemInfoTab(),
                          AtprotoSessionTab(),
                          NetworkInspectorTab(),
                          PerformanceMetricsTab(),
                        ],
                      ),
                    ),
                    _buildFooter(context, ref, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.bug_report, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Debug Overlay',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => ref.read(debugOverlayControllerProvider.notifier).hide(),
            tooltip: 'Close',
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      tabs: const [
        Tab(icon: Icon(Icons.info_outline), text: 'System'),
        Tab(icon: Icon(Icons.account_circle_outlined), text: 'Session'),
        Tab(icon: Icon(Icons.http), text: 'Network'),
        Tab(icon: Icon(Icons.speed), text: 'Perf'),
      ],
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
    );
  }

  Widget _buildFooter(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: FilledButton.tonal(
        onPressed: () {
          ref.read(debugOverlayControllerProvider.notifier).hide();
          rootNavigatorKey.currentContext?.go('/devtools');
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.developer_mode, size: 20),
            SizedBox(width: 8),
            Flexible(child: Text('Open Full DevTools', overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
