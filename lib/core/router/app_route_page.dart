import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

bool useCupertinoRoutePage(TargetPlatform platform) => platform == TargetPlatform.iOS;

Page<T> buildAppRoutePage<T>(BuildContext context, GoRouterState state, Widget child) {
  return _buildAppRoutePage(context: context, state: state, child: child);
}

Page<T> _buildAppRoutePage<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
  if (useCupertinoRoutePage(Theme.of(context).platform)) {
    return CupertinoPage<T>(key: state.pageKey, child: child);
  }

  return _buildFadeThroughPage<T>(context: context, state: state, child: child);
}

Page<T> _buildFadeThroughPage<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
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
