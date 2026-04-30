import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

class AppScreenEntrance extends StatelessWidget {
  const AppScreenEntrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child.animateIfAllowed(
    context,
    effects: const [
      FadeEffect(duration: Anim.normal, curve: Anim.enter),
      SlideEffect(begin: Offset(0, 0.02), end: Offset.zero, duration: Anim.normal, curve: Anim.enter),
    ],
  );
}
