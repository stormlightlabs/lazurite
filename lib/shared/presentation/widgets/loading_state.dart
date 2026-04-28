import 'package:flutter/material.dart';
import 'package:lazurite/shared/presentation/widgets/shimmer_skeleton.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message, this.padding = const EdgeInsets.all(24)});

  final String? message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const _LoadingSkeleton(),
            ..._message(message, theme.textTheme, theme.colorScheme),
          ],
        ),
      ),
    );
  }

  List<Widget> _message(String? message, TextTheme textTheme, ColorScheme colorScheme) => (message == null)
      ? []
      : [
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ];
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 220,
      child: Column(
        children: [
          ShimmerSkeletonLine(width: 220, height: 12),
          SizedBox(height: 8),
          ShimmerSkeletonLine(width: 168, height: 12),
        ],
      ),
    );
  }
}
