import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

class ComposeFab extends StatelessWidget {
  const ComposeFab({Key? key, required this.heroTag, required this.tooltip, required this.onPressed, this.shape})
    : _fabKey = key,
      super(key: null);

  final Key? _fabKey;
  final Object heroTag;
  final String tooltip;
  final VoidCallback? onPressed;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: _fabKey,
      heroTag: heroTag,
      tooltip: tooltip,
      onPressed: onPressed,
      shape: shape,
      child: const Icon(Icons.add),
    ).animateIfAllowed(
      context,
      effects: const [
        FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
        ScaleEffect(begin: Offset(0, 0), end: Offset(1, 1), duration: Anim.feedItem, curve: Anim.emphasis),
      ],
    );
  }
}
