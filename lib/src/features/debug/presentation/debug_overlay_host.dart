import 'dart:async';

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

  /// Map of active pointer IDs.
  final _activePointers = <int>{};
  Timer? _longPressTimer;

  /// Focus node for keyboard shortcuts.
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    _longPressTimer?.cancel();
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
      child: Listener(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerUp,
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

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    _checkPointers();
  }

  void _handlePointerUp(PointerEvent event) {
    _activePointers.remove(event.pointer);
    _checkPointers();
  }

  void _checkPointers() {
    if (_activePointers.length == 2) {
      if (_longPressTimer == null || !_longPressTimer!.isActive) {
        _longPressTimer = Timer(_longPressDuration, () {
          if (mounted && _activePointers.length == 2) {
            ref.read(debugOverlayControllerProvider.notifier).toggle();
            // Reset to avoid repeated toggles without lifting fingers
            _activePointers.clear();
          }
        });
      }
    } else {
      _longPressTimer?.cancel();
      _longPressTimer = null;
    }
  }
}
