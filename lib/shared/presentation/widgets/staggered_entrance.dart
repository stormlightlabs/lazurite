import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

class StaggeredEntrance extends StatelessWidget {
  const StaggeredEntrance({
    super.key,
    required this.child,
    required this.itemKey,
    required this.index,
    required this.seenKeys,
  });

  final Widget child;
  final String itemKey;
  final int index;

  /// Widget keys that have been seen before, used to determine whether to animate the child.
  ///
  /// Mark immediately so rebuilds during the same frame do not restart the entrance sequence.
  final Set<String> seenKeys;

  @override
  Widget build(BuildContext context) {
    final hasSeen = seenKeys.contains(itemKey);
    if (hasSeen) {
      return child;
    }

    seenKeys.add(itemKey);

    return child.animateIfAllowed(
      context,
      delay: Anim.staggerFor(index),
      effects: const [
        FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
        SlideEffect(begin: Offset(0, 0.05), end: Offset.zero, duration: Anim.feedItem, curve: Anim.enter),
      ],
    );
  }
}
