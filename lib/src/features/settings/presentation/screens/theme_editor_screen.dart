import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/providers.dart';
import 'package:lazurite/src/app/theme_controller.dart';
import 'package:lazurite/src/app/theming/custom_theme_draft.dart';

import '../widgets/color_role_picker.dart';
import '../widgets/theme_preview_card.dart';

/// Screen for creating and editing custom themes.
///
/// Allows users to customize color roles and typography scale on top of
/// a base theme pack. Changes are previewed in real-time.
class ThemeEditorScreen extends ConsumerStatefulWidget {
  const ThemeEditorScreen({super.key, this.customThemeId});

  /// ID of an existing custom theme to edit, or null to create a new one.
  final String? customThemeId;

  @override
  ConsumerState<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends ConsumerState<ThemeEditorScreen> {
  late String _name;
  late String _basePackId;
  late ThemeRoleOverrides _overrides;
  late TypographyScale _typographyScale;
  bool _isLoading = true;
  bool _isDirty = false;
  String? _existingId;

  @override
  void initState() {
    super.initState();
    _loadOrCreateDraft();
  }

  Future<void> _loadOrCreateDraft() async {
    if (widget.customThemeId != null) {
      final repo = ref.read(customThemeRepositoryProvider);
      final existing = await repo.getById(widget.customThemeId!);
      if (existing != null) {
        setState(() {
          _existingId = existing.id;
          _name = existing.name;
          _basePackId = existing.basePackId;
          _overrides = existing.overrides;
          _typographyScale = existing.typographyScale;
          _isLoading = false;
        });
        return;
      }
    }

    final themeState = ref.read(themeControllerProvider);
    setState(() {
      _name = 'My Custom Theme';
      _basePackId = themeState.currentPackId;
      _overrides = ThemeRoleOverrides.empty;
      _typographyScale = TypographyScale.normal;
      _isLoading = false;
    });
  }

  void _updateOverride(String role, Color? color) {
    setState(() {
      _isDirty = true;
      _overrides = switch (role) {
        'primary' => _overrides.copyWith(primary: color, clearPrimary: color == null),
        'secondary' => _overrides.copyWith(secondary: color, clearSecondary: color == null),
        'tertiary' => _overrides.copyWith(tertiary: color, clearTertiary: color == null),
        'surface' => _overrides.copyWith(surface: color, clearSurface: color == null),
        'surfaceContainerLow' => _overrides.copyWith(
          surfaceContainerLow: color,
          clearSurfaceContainerLow: color == null,
        ),
        'surfaceContainerHigh' => _overrides.copyWith(
          surfaceContainerHigh: color,
          clearSurfaceContainerHigh: color == null,
        ),
        'outlineVariant' => _overrides.copyWith(
          outlineVariant: color,
          clearOutlineVariant: color == null,
        ),
        _ => _overrides,
      };
    });
  }

  Future<void> _save() async {
    final repo = ref.read(customThemeRepositoryProvider);
    final controller = ref.read(themeControllerProvider.notifier);

    final CustomThemeDraft draft;
    if (_existingId != null) {
      final existing = await repo.getById(_existingId!);
      draft = existing!.copyWith(
        name: _name,
        basePackId: _basePackId,
        overrides: _overrides,
        typographyScale: _typographyScale,
      );
    } else {
      draft = CustomThemeDraft.create(
        name: _name,
        basePackId: _basePackId,
        overrides: _overrides,
        typographyScale: _typographyScale,
      );
    }

    final result = await repo.save(draft);
    if (result.isValid) {
      await controller.setCustomTheme(draft.id);
      if (mounted) {
        context.pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error ?? 'Failed to save theme')));
      }
    }
  }

  void _resetToDefaults() {
    setState(() {
      _overrides = ThemeRoleOverrides.empty;
      _isDirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Theme Editor')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final packs = ref.watch(availableThemePacksProvider);
    final basePack = packs.firstWhere((p) => p.id == _basePackId, orElse: () => packs.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Editor'),
        actions: [
          if (_overrides.hasOverrides)
            TextButton(onPressed: _resetToDefaults, child: const Text('Reset')),
          TextButton(
            onPressed: _isDirty || _existingId == null ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Theme Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: _name),
              onChanged: (value) {
                _name = value;
                _isDirty = true;
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(context, 'BASE PACK', [
            for (final pack in packs)
              RadioListTile<String>(
                title: Text(pack.name),
                subtitle: pack.author != null ? Text('by ${pack.author}') : null,
                value: pack.id,
                groupValue: _basePackId,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _basePackId = value;
                      _isDirty = true;
                    });
                  }
                },
              ),
          ]),
          const Divider(),
          _buildSection(context, 'COLOR OVERRIDES', [
            ColorRolePicker(
              label: 'Primary',
              description: 'Main accent color',
              currentColor: _overrides.primary,
              defaultColor: basePack.darkVariant?.spec.primary ?? colorScheme.primary,
              onColorChanged: (color) => _updateOverride('primary', color),
            ),
            ColorRolePicker(
              label: 'Secondary',
              description: 'Supporting accent',
              currentColor: _overrides.secondary,
              defaultColor: basePack.darkVariant?.spec.secondary ?? colorScheme.secondary,
              onColorChanged: (color) => _updateOverride('secondary', color),
            ),
            ColorRolePicker(
              label: 'Tertiary',
              description: 'Complementary accent',
              currentColor: _overrides.tertiary,
              defaultColor: basePack.darkVariant?.spec.tertiary ?? colorScheme.tertiary,
              onColorChanged: (color) => _updateOverride('tertiary', color),
            ),
            ColorRolePicker(
              label: 'Surface',
              description: 'Background color',
              currentColor: _overrides.surface,
              defaultColor: basePack.darkVariant?.spec.surface ?? colorScheme.surface,
              onColorChanged: (color) => _updateOverride('surface', color),
            ),
            ColorRolePicker(
              label: 'Surface Container Low',
              description: 'Card backgrounds',
              currentColor: _overrides.surfaceContainerLow,
              defaultColor:
                  basePack.darkVariant?.spec.surfaceContainerLow ??
                  colorScheme.surfaceContainerLow,
              onColorChanged: (color) => _updateOverride('surfaceContainerLow', color),
            ),
            ColorRolePicker(
              label: 'Surface Container High',
              description: 'Elevated surfaces',
              currentColor: _overrides.surfaceContainerHigh,
              defaultColor:
                  basePack.darkVariant?.spec.surfaceContainerHigh ??
                  colorScheme.surfaceContainerHigh,
              onColorChanged: (color) => _updateOverride('surfaceContainerHigh', color),
            ),
            ColorRolePicker(
              label: 'Outline Variant',
              description: 'Subtle dividers',
              currentColor: _overrides.outlineVariant,
              defaultColor:
                  basePack.darkVariant?.spec.outlineVariant ?? colorScheme.outlineVariant,
              onColorChanged: (color) => _updateOverride('outlineVariant', color),
            ),
          ]),
          const Divider(),
          _buildSection(context, 'TYPOGRAPHY SCALE', [
            for (final scale in TypographyScale.values)
              RadioListTile<TypographyScale>(
                title: Text(scale.name.toUpperCase()),
                subtitle: Text('${(scale.scaleFactor * 100).toInt()}%'),
                value: scale,
                groupValue: _typographyScale,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _typographyScale = value;
                      _isDirty = true;
                    });
                  }
                },
              ),
          ]),
          const Divider(),
          _buildSection(context, 'PREVIEW', [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (basePack.lightVariant != null)
                    Expanded(
                      child: ThemePreviewCard(
                        colorScheme: basePack.lightVariant!.derivedScheme,
                        label: 'Light',
                      ),
                    ),
                  const SizedBox(width: 16),
                  if (basePack.darkVariant != null)
                    Expanded(
                      child: ThemePreviewCard(
                        colorScheme: basePack.darkVariant!.derivedScheme,
                        label: 'Dark',
                      ),
                    ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
