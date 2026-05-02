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
          intent.focusNode.unfocus();
          return null;
        },
      ),
    },
    child: child,
  );
}
