import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/theme_controller.dart';

import '../widgets/theme_preview_card.dart';

/// Theme settings screen for configuring app appearance.
///
/// Displays theme mode selector (Light/Dark/System), theme pack selection,
/// preview cards showing theme appearance, and an export button.
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);
    final packs = ref.watch(availableThemePacksProvider);
    final currentPack = packs.firstWhere(
      (p) => p.id == themeState.currentPackId,
      orElse: () => packs.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildThemeModeSection(context, ref, themeState),
          const Divider(),
          _buildThemePackSection(context, ref, themeState, packs),
          const Divider(),
          _buildCustomizeSection(context, themeState),
          const Divider(),
          _buildPreviewSection(context, currentPack),
          const Divider(),
          _buildExportSection(context, currentPack),
        ],
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context, WidgetRef ref, ThemeState themeState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'THEME MODE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RadioGroup<ThemeMode>(
          groupValue: themeState.themeMode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(themeControllerProvider.notifier).setThemeMode(mode);
            }
          },
          child: Column(
            children: [
              const RadioListTile<ThemeMode>(
                title: Text('Light'),
                secondary: Icon(Icons.light_mode_outlined),
                value: ThemeMode.light,
              ),
              const RadioListTile<ThemeMode>(
                title: Text('Dark'),
                secondary: Icon(Icons.dark_mode_outlined),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System'),
                subtitle: Text(_getSystemThemeDescription(context)),
                secondary: const Icon(Icons.settings_brightness_outlined),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemePackSection(
    BuildContext context,
    WidgetRef ref,
    ThemeState themeState,
    List packs,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'THEME PACK',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RadioGroup<String>(
          groupValue: themeState.currentPackId,
          onChanged: (packId) {
            if (packId != null) {
              ref.read(themeControllerProvider.notifier).setThemePack(packId);
            }
          },
          child: Column(
            children: [
              for (final pack in packs)
                RadioListTile<String>(
                  title: Text(pack.name),
                  subtitle: pack.author != null ? Text('by ${pack.author}') : null,
                  value: pack.id,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomizeSection(BuildContext context, ThemeState themeState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'CUSTOMIZE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Create Custom Theme'),
          subtitle: const Text('Adjust colors and typography'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/appearance/editor'),
        ),
        if (themeState.isUsingCustomTheme)
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Current Custom Theme'),
            subtitle: Text('ID: ${themeState.customThemeId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.push('/settings/appearance/editor?id=${themeState.customThemeId}'),
          ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context, dynamic currentPack) {
    final colorScheme = Theme.of(context).colorScheme;
    final lightVariant = currentPack.lightVariant;
    final darkVariant = currentPack.darkVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'PREVIEW',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (lightVariant != null)
                Expanded(
                  child: ThemePreviewCard(label: 'Light', colorScheme: lightVariant.derivedScheme),
                ),
              if (lightVariant != null && darkVariant != null) const SizedBox(width: 12),
              if (darkVariant != null)
                Expanded(
                  child: ThemePreviewCard(label: 'Dark', colorScheme: darkVariant.derivedScheme),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildExportSection(BuildContext context, dynamic currentPack) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'EXPORT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.code_outlined),
          title: const Text('Export theme JSON'),
          subtitle: const Text('Copy theme spec to clipboard'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _exportThemeJson(context, currentPack),
        ),
      ],
    );
  }

  String _getSystemThemeDescription(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? 'Currently: Dark' : 'Currently: Light';
  }

  void _exportThemeJson(BuildContext context, dynamic currentPack) {
    final brightness = Theme.of(context).brightness;
    final variant = brightness == Brightness.dark
        ? currentPack.darkVariant
        : currentPack.lightVariant;

    if (variant == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No theme variant available to export')));
      return;
    }

    final spec = variant.spec;
    final jsonMap = _themeSpecToJson(spec);
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

    Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Theme JSON copied to clipboard')));
  }

  Map<String, dynamic> _themeSpecToJson(dynamic spec) {
    String? colorToHex(Color? color) {
      if (color == null) return null;
      final argb = color.toARGB32();
      return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    }

    return {
      'surfaceDim': colorToHex(spec.surfaceDim),
      'surface': colorToHex(spec.surface),
      'surfaceBright': colorToHex(spec.surfaceBright),
      'surfaceContainerLowest': colorToHex(spec.surfaceContainerLowest),
      'surfaceContainerLow': colorToHex(spec.surfaceContainerLow),
      'surfaceContainer': colorToHex(spec.surfaceContainer),
      'surfaceContainerHigh': colorToHex(spec.surfaceContainerHigh),
      'surfaceContainerHighest': colorToHex(spec.surfaceContainerHighest),
      'onSurface': colorToHex(spec.onSurface),
      'onSurfaceVariant': colorToHex(spec.onSurfaceVariant),
      'outline': colorToHex(spec.outline),
      'outlineVariant': colorToHex(spec.outlineVariant),
      'primary': colorToHex(spec.primary),
      'onPrimary': colorToHex(spec.onPrimary),
      'primaryContainer': colorToHex(spec.primaryContainer),
      'onPrimaryContainer': colorToHex(spec.onPrimaryContainer),
      'secondary': colorToHex(spec.secondary),
      'onSecondary': colorToHex(spec.onSecondary),
      'secondaryContainer': colorToHex(spec.secondaryContainer),
      'onSecondaryContainer': colorToHex(spec.onSecondaryContainer),
      'tertiary': colorToHex(spec.tertiary),
      'onTertiary': colorToHex(spec.onTertiary),
      'tertiaryContainer': colorToHex(spec.tertiaryContainer),
      'onTertiaryContainer': colorToHex(spec.onTertiaryContainer),
      'error': colorToHex(spec.error),
      'onError': colorToHex(spec.onError),
      'errorContainer': colorToHex(spec.errorContainer),
      'onErrorContainer': colorToHex(spec.onErrorContainer),
      'inverseSurface': colorToHex(spec.inverseSurface),
      'onInverseSurface': colorToHex(spec.onInverseSurface),
      'inversePrimary': colorToHex(spec.inversePrimary),
      'scrim': colorToHex(spec.scrim),
      'shadow': colorToHex(spec.shadow),
    };
  }
}
