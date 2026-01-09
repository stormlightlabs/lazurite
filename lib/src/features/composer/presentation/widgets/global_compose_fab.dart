import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';

/// Global floating action button for composing new posts.
///
/// Displays an extended FAB with "Post" label and edit icon.
/// Navigates to the composer screen when tapped.
///
/// Should be shown on main screens (Home, Search, Notifications, Profile) and hidden on screens
/// like Composer, Login, Drafts, and Settings.
class GlobalComposeFab extends StatelessWidget {
  const GlobalComposeFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.compose),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 6,
      child: const Icon(CupertinoIcons.pencil),
    );
  }
}
