import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.subtitle,
    this.padding = const EdgeInsets.all(24),
  });

  final String message;
  final IconData icon;
  final Widget? action;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        ..._subtitle(subtitle, textTheme, colorScheme),
        ..._action(action),
      ],
    );

    return Center(
      child: Padding(
        padding: padding,
        child: content.animateIfAllowed(
          context,
          effects: const [
            FadeEffect(duration: Anim.screenTransition, curve: Anim.enter),
            ScaleEffect(
              begin: Offset(0.95, 0.95),
              end: Offset(1, 1),
              duration: Anim.screenTransition,
              curve: Anim.enter,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _action(Widget? action) => (action == null) ? [] : [const SizedBox(height: 16), action];

  List<Widget> _subtitle(String? subtitle, TextTheme textTheme, ColorScheme colorScheme) => (subtitle == null)
      ? []
      : [
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ];
}
