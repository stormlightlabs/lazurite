import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

class ShimmerSkeletonLine extends StatelessWidget {
  const ShimmerSkeletonLine({super.key, this.width, this.height = 14});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.zero),
    ).animateIfAllowed(
      context,
      effects: [ShimmerEffect(duration: Anim.shimmerCycle, color: theme.colorScheme.surfaceContainerHigh)],
    );
  }
}
