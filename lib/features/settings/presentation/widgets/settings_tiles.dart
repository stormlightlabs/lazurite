import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isDestructive = false,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool isDestructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      leading: icon != null ? Icon(icon, color: isDestructive ? context.colorScheme.error : null) : null,
      title: Text(title, style: TextStyle(color: isDestructive ? context.colorScheme.error : null)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    ),
  );
}

class ConstellationUrlTile extends StatelessWidget {
  const ConstellationUrlTile({super.key, required this.currentUrl});

  final String currentUrl;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      leading: const Icon(Icons.hub_outlined),
      title: const Text('Constellation URL'),
      subtitle: Text(currentUrl, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}

class SettingsDropdownTile<T> extends StatelessWidget {
  const SettingsDropdownTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
    this.subtitle,
    this.optionBuilder,
  });

  final String title;
  final String? subtitle;
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final Widget Function(BuildContext context, T value)? optionBuilder;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          alignment: AlignmentDirectional.centerEnd,
          value: value,
          onChanged: onChanged,
          selectedItemBuilder: (context) => [
            for (final option in options)
              Align(alignment: AlignmentDirectional.centerEnd, child: _buildOption(context, option)),
          ],
          items: [
            for (final option in options)
              DropdownMenuItem<T>(
                value: option,
                alignment: AlignmentDirectional.centerEnd,
                child: Align(alignment: AlignmentDirectional.centerEnd, child: _buildOption(context, option)),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _buildOption(BuildContext context, T option) =>
      optionBuilder?.call(context, option) ?? Text(labelBuilder(option), textAlign: TextAlign.right);
}
