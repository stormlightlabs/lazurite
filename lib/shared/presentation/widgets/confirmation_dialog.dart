import 'dart:async';

import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.onCancel,
    this.confirmDestructive = false,
    this.showCancel = true,
    this.confirmEnabled = true,
  });

  final Widget title;
  final Widget content;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;
  final bool confirmDestructive;
  final bool showCancel;
  final bool confirmEnabled;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: [
        if (showCancel)
          TextButton(onPressed: onCancel ?? () => Navigator.of(context).pop(false), child: Text(cancelLabel)),
        FilledButton(
          onPressed: confirmEnabled ? onConfirm : null,
          style: confirmDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

Future<bool> showConfirmationDialog({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool confirmDestructive = false,
  bool showCancel = true,
  bool barrierDismissible = true,
  FutureOr<void> Function()? onConfirmed,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => ConfirmationDialog(
      title: title,
      content: content,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      confirmDestructive: confirmDestructive,
      showCancel: showCancel,
      onConfirm: () => Navigator.of(dialogContext).pop(true),
      onCancel: () => Navigator.of(dialogContext).pop(false),
    ),
  );

  if (confirmed == true && onConfirmed != null) {
    await onConfirmed();
  }
  return confirmed ?? false;
}
