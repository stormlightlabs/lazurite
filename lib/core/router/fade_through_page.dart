import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

Page<T> buildFadeThroughPage<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
  final reducedMotion = !animationsAllowed(context);
  final duration = reducedMotion ? Anim.fast : Anim.screenTransition;

  return CustomTransitionPage<T>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: Anim.fast,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (reducedMotion) {
        return FadeTransition(opacity: animation, child: child);
      }

      final fade = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.2, 1, curve: Anim.enter),
      );

      final scale = Tween<double>(begin: 0.96, end: 1).animate(CurvedAnimation(parent: animation, curve: Anim.enter));
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
