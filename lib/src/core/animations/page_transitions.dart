import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/animation_controller.dart' as lazurite_anim;

/// Types of Material 3 page transitions.
enum LazuriteTransitionType {
  /// Shared axis transition (X, Y, or Z).
  ///
  /// Use for transitions between related content (e.g., tabs, steps).
  sharedAxisHorizontal,
  sharedAxisVertical,
  sharedAxisScaled,

  /// Fade through transition.
  ///
  /// Use for transitions between unrelated content.
  fadeThrough,

  /// Fade scale transition.
  ///
  /// Use for dialogs and modal overlays.
  fadeScale,

  /// Standard fade.
  fade,
}

/// Helper for creating aware page transitions.
class LazuritePageTransitions {
  const LazuritePageTransitions._();

  /// Builds a [CustomTransitionPage] with the specified [type] and animation settings.
  static CustomTransitionPage<T> build<T>({
    required Widget child,
    required LazuriteTransitionType type,
    required GoRouterState state,
    required lazurite_anim.AnimationController controller,
    Duration? duration,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    LocalKey? key,
  }) {
    final platformReduceMotion = PlatformDispatcher.instance.accessibilityFeatures.reduceMotion;

    return CustomTransitionPage<T>(
      key: key ?? state.pageKey,
      child: child,
      opaque: opaque,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: _calculateDuration(
        controller,
        duration ?? const Duration(milliseconds: 300),
        platformReduceMotion: platformReduceMotion,
      ),
      reverseTransitionDuration: _calculateDuration(
        controller,
        duration ?? const Duration(milliseconds: 300),
        platformReduceMotion: platformReduceMotion,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final mediaQuery = MediaQuery.of(context);
        final reduceMotion =
            mediaQuery.disableAnimations ||
            PlatformDispatcher.instance.accessibilityFeatures.reduceMotion;

        final shouldDisable = controller.shouldDisableAnimations(
          platformReduceMotion: reduceMotion,
        );

        if (shouldDisable) {
          return child;
        }

        return _buildTransition(type, context, animation, secondaryAnimation, child);
      },
    );
  }

  static Duration _calculateDuration(
    lazurite_anim.AnimationController controller,
    Duration base, {
    required bool platformReduceMotion,
  }) {
    return controller.getEffectiveDuration(base, platformReduceMotion: platformReduceMotion);
  }

  static Widget _buildTransition(
    LazuriteTransitionType type,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case LazuriteTransitionType.sharedAxisHorizontal:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      case LazuriteTransitionType.sharedAxisVertical:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      case LazuriteTransitionType.sharedAxisScaled:
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child,
        );
      case LazuriteTransitionType.fadeThrough:
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      case LazuriteTransitionType.fadeScale:
        return FadeScaleTransition(animation: animation, child: child);
      case LazuriteTransitionType.fade:
        return FadeTransition(opacity: animation, child: child);
    }
  }
}
