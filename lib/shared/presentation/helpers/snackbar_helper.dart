import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showAppSnackBar(
  BuildContext context,
  String message, {
  bool hideCurrent = true,
  bool isError = false,
  SnackBarBehavior? behavior,
  Duration? duration,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final colorScheme = context.colorScheme;

  if (hideCurrent) {
    messenger.hideCurrentSnackBar();
  }

  final snackBarBehavior = behavior ?? SnackBarBehavior.floating;
  final animatedContent = Text(message).animateIfAllowed(
    context,
    effects: const [
      FadeEffect(duration: Anim.feedItem, curve: Anim.enter),
      SlideEffect(begin: Offset(0, 0.25), end: Offset.zero, duration: Anim.feedItem, curve: Anim.enter),
    ],
  );

  return messenger.showSnackBar(
    SnackBar(
      content: animatedContent,
      behavior: snackBarBehavior,
      duration: duration ?? const Duration(seconds: 4),
      backgroundColor: isError ? colorScheme.error : null,
      action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}
