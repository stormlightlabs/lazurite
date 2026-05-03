import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Ensures tapping outside a focused [EditableText] dismisses keyboard focus
/// on touch devices as well.
class GlobalTapOutsideUnfocus extends StatelessWidget {
  const GlobalTapOutsideUnfocus({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Actions(
    actions: <Type, Action<Intent>>{
      EditableTextTapOutsideIntent: CallbackAction<EditableTextTapOutsideIntent>(
        onInvoke: (intent) {
          // Preserve Flutter's default down-event behavior on touch so overlay
          // interactions (like typeahead suggestion taps) are not interrupted.
          if (intent.pointerDownEvent.kind != ui.PointerDeviceKind.touch) {
            intent.focusNode.unfocus();
          }
          return null;
        },
      ),
      EditableTextTapUpOutsideIntent: CallbackAction<EditableTextTapUpOutsideIntent>(
        onInvoke: (intent) {
          if (intent.pointerUpEvent.kind == ui.PointerDeviceKind.touch) {
            intent.focusNode.unfocus();
          }
          return null;
        },
      ),
    },
    child: child,
  );
}
