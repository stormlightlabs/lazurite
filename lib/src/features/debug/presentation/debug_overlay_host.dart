import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/debug_overlay_controller.dart';
import 'debug_drawer.dart';

/// Host widget that wraps the app and provides debug overlay functionality.
class DebugOverlayHost extends ConsumerStatefulWidget {
  const DebugOverlayHost({super.key, required this.child, @visibleForTesting this.drawerBuilder});

  /// The child widget tree (typically MaterialApp).
  final Widget child;

  /// Optional builder for the drawer widget, used for testing.
  final WidgetBuilder? drawerBuilder;

  @override
  ConsumerState<DebugOverlayHost> createState() => _DebugOverlayHostState();
}

class _DebugOverlayHostState extends ConsumerState<DebugOverlayHost> {
  /// Duration required for a long-press to trigger the overlay.
  static const _longPressDuration = Duration(seconds: 2);

  /// Tracks if we're in the middle of a valid 2-finger long-press.
  bool _twoFingerPressActive = false;

  /// Focus node for keyboard shortcuts.
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return widget.child;
    }

    final overlayState = ref.watch(debugOverlayControllerProvider);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        child: Stack(
          children: [
            widget.child,
            if (overlayState.isVisible) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => ref.read(debugOverlayControllerProvider.notifier).hide(),
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                bottom: 0,
                width: 320,
                child: widget.drawerBuilder?.call(context) ?? const DebugDrawer(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (HardwareKeyboard.instance.isAltPressed && event.logicalKey == LogicalKeyboardKey.f12) {
        ref.read(debugOverlayControllerProvider.notifier).toggle();
      }
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    // TODO: use RawGestureDetector for full 2-finger support.
    _twoFingerPressActive = true;
    Future.delayed(_longPressDuration, () {
      if (_twoFingerPressActive && mounted) {
        ref.read(debugOverlayControllerProvider.notifier).toggle();
        _twoFingerPressActive = false;
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _twoFingerPressActive = false;
  }
}
