import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Text(
      title.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
    ),
  );
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Divider(height: 1, color: context.theme.dividerColor),
      Material(
        color: context.theme.cardColor,
        child: Column(children: children),
      ),
      Divider(height: 1, color: context.theme.dividerColor),
    ],
  );
}
