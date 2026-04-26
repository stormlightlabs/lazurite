import 'package:flutter/material.dart';

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
  final colorScheme = Theme.of(context).colorScheme;

  if (hideCurrent) {
    messenger.hideCurrentSnackBar();
  }

  return messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: behavior,
      duration: duration ?? const Duration(seconds: 4),
      backgroundColor: isError ? colorScheme.error : null,
      action: actionLabel == null ? null : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
    ),
  );
}
