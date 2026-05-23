import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

/// Route-level error screen for malformed or unsupported external links.
///
/// Used when URL/path/query data cannot be parsed into the route's required
/// identifiers for direct app links where there may be no useful previous
/// screen to return to.
class InvalidRouteScreen extends StatelessWidget {
  const InvalidRouteScreen({
    super.key,
    this.title = 'Invalid link',
    this.message = 'This link is invalid or no longer available.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off, size: 48, color: context.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(title, style: context.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => context.go(AppRoutePath.home.path), child: const Text('Go home')),
          ],
        ),
      ),
    ),
  );
}
