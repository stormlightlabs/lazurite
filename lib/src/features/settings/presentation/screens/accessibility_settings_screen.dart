import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/app/animation_controller.dart' as app;
import 'package:lazurite/src/features/settings/domain/animation_preferences.dart';

/// Accessibility settings screen for animation controls.
///
/// Displays animation mode selector (full/reduced/minimal/system) and speed multiplier slider
/// with live preview.
///
/// Changes are persisted via AnimationController.
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationState = ref.watch(app.animationControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildAnimationModeSection(context, ref, animationState, colorScheme),
          const Divider(),
          _buildSpeedMultiplierSection(context, ref, animationState, colorScheme),
          const Divider(),
          _buildInfoSection(context, colorScheme),
          const Divider(),
          _buildResetSection(context, ref),
        ],
      ),
    );
  }

  Widget _buildAnimationModeSection(
    BuildContext context,
    WidgetRef ref,
    app.AnimationState animationState,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'ANIMATION MODE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RadioGroup<AnimationMode>(
          groupValue: animationState.mode,
          onChanged: (mode) {
            if (mode != null) {
              ref.read(app.animationControllerProvider.notifier).setMode(mode);
            }
          },
          child: const Column(
            children: [
              RadioListTile<AnimationMode>(
                title: Text('Full'),
                subtitle: Text('All animations enabled'),
                secondary: Icon(Icons.animation),
                value: AnimationMode.full,
              ),
              RadioListTile<AnimationMode>(
                title: Text('Reduced'),
                subtitle: Text('Essential transitions only'),
                secondary: Icon(Icons.motion_photos_auto),
                value: AnimationMode.reduced,
              ),
              RadioListTile<AnimationMode>(
                title: Text('Minimal'),
                subtitle: Text('Near-instant transitions'),
                secondary: Icon(Icons.speed),
                value: AnimationMode.minimal,
              ),
              RadioListTile<AnimationMode>(
                title: Text('System'),
                subtitle: Text('Follows device reduce motion settings'),
                secondary: Icon(Icons.settings_accessibility),
                value: AnimationMode.system,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedMultiplierSection(
    BuildContext context,
    WidgetRef ref,
    app.AnimationState animationState,
    ColorScheme colorScheme,
  ) {
    final speedMultiplier = animationState.speedMultiplier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'ANIMATION SPEED',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.slow_motion_video),
          title: const Text('Speed Multiplier'),
          subtitle: Text('${speedMultiplier.toStringAsFixed(1)}x'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Slider(
                value: speedMultiplier,
                min: AnimationPreferences.minSpeedMultiplier,
                max: AnimationPreferences.maxSpeedMultiplier,
                divisions: 15,
                label: '${speedMultiplier.toStringAsFixed(1)}x',
                onChanged: (value) {
                  ref.read(app.animationControllerProvider.notifier).setSpeedMultiplier(value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slower (${AnimationPreferences.minSpeedMultiplier}x)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    'Faster (${AnimationPreferences.maxSpeedMultiplier.toStringAsFixed(1)}x)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildSpeedPreview(context, ref, animationState),
      ],
    );
  }

  Widget _buildSpeedPreview(
    BuildContext context,
    WidgetRef ref,
    app.AnimationState animationState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _AnimationPreviewWidget(
        speedMultiplier: animationState.speedMultiplier,
        mode: animationState.mode,
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'INFORMATION',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Platform Integration'),
          subtitle: Text(
            'System mode respects your device\'s reduce motion settings. '
            'Adjust animation speed and intensity to your preference.',
          ),
        ),
      ],
    );
  }

  Widget _buildResetSection(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () async {
          await ref.read(app.animationControllerProvider.notifier).resetToDefaults();
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Animation settings reset to defaults')));
          }
        },
        icon: const Icon(Icons.restore),
        label: const Text('Reset to Defaults'),
      ),
    );
  }
}

/// Preview widget that demonstrates the current animation speed.
class _AnimationPreviewWidget extends StatefulWidget {
  const _AnimationPreviewWidget({required this.speedMultiplier, required this.mode});

  final double speedMultiplier;
  final AnimationMode mode;

  @override
  State<_AnimationPreviewWidget> createState() => _AnimationPreviewWidgetState();
}

class _AnimationPreviewWidgetState extends State<_AnimationPreviewWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void didUpdateWidget(_AnimationPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedMultiplier != widget.speedMultiplier || oldWidget.mode != widget.mode) {
      _controller.dispose();
      _initializeAnimation();
    }
  }

  void _initializeAnimation() {
    const baseDuration = Duration(milliseconds: 800);
    final effectiveDuration = _calculateEffectiveDuration(baseDuration);

    _controller = AnimationController(duration: effectiveDuration, vsync: this);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.mode != AnimationMode.minimal) {
      _controller.repeat(reverse: true);
    }
  }

  Duration _calculateEffectiveDuration(Duration baseDuration) {
    final mode = widget.mode;

    switch (mode) {
      case AnimationMode.minimal:
        return const Duration(milliseconds: 1);
      case AnimationMode.reduced:
        final reducedMs = (baseDuration.inMilliseconds * 0.5 / widget.speedMultiplier).round();
        return Duration(milliseconds: reducedMs.clamp(1, 10000));
      case AnimationMode.full:
      case AnimationMode.system:
        final adjustedMs = (baseDuration.inMilliseconds / widget.speedMultiplier).round();
        return Duration(milliseconds: adjustedMs.clamp(1, 10000));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Align(
                  alignment: Alignment.lerp(
                    Alignment.centerLeft,
                    Alignment.centerRight,
                    _animation.value,
                  )!,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(Icons.circle, color: colorScheme.onPrimary, size: 24),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
