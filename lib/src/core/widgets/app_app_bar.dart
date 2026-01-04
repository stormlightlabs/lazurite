import 'package:flutter/material.dart';

/// A consistent app bar used across the application.
///
/// Provides a standard app bar with title and optional actions slot.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates an app bar.
  const AppAppBar({required this.title, this.actions, this.leading, this.centerTitle, super.key});

  /// The title to display in the app bar.
  final String title;

  /// Optional list of action widgets to display on the right.
  final List<Widget>? actions;

  /// Optional leading widget (defaults to back button when applicable).
  final Widget? leading;

  /// Whether to center the title. Defaults to platform convention.
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
