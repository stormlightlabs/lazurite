import 'package:flutter/material.dart';

/// A widget that detects when it becomes visible in the viewport.
///
/// Calls [onVisible] when the widget scrolls into view for the first time.
/// Uses Flutter's built-in visibility detection to avoid external dependencies.
class VisibilityDetector extends StatefulWidget {
  const VisibilityDetector({
    required this.child,
    required this.onVisible,
    this.visibilityThreshold = 0.1,
    super.key,
  });

  /// The child widget to wrap.
  final Widget child;

  /// Callback invoked when the widget becomes visible.
  ///
  /// This is called only once, when the widget first becomes visible.
  final VoidCallback onVisible;

  /// Minimum fraction of the widget that must be visible (0.0 to 1.0).
  ///
  /// Defaults to 0.1 (10% visible).
  final double visibilityThreshold;

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  bool _hasBeenVisible = false;

  @override
  Widget build(BuildContext context) {
    if (_hasBeenVisible) {
      return widget.child;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_hasBeenVisible) {
          _checkVisibility();
        }
        return false;
      },
      child: widget.child,
    );
  }

  void _checkVisibility() {
    if (_hasBeenVisible) return;

    final renderObject = context.findRenderObject();
    if (renderObject == null || !renderObject.attached) return;

    final renderBox = renderObject as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final screenHeight = MediaQuery.of(context).size.height;

    final topVisible = position.dy < screenHeight && position.dy + size.height > 0;
    if (!topVisible) return;

    final visibleTop = position.dy < 0 ? 0.0 : position.dy;
    final visibleBottom = position.dy + size.height > screenHeight
        ? screenHeight
        : position.dy + size.height;
    final visibleHeight = visibleBottom - visibleTop;
    final visibleFraction = visibleHeight / size.height;

    if (visibleFraction >= widget.visibilityThreshold) {
      _markAsVisible();
    }
  }

  void _markAsVisible() {
    if (_hasBeenVisible) return;

    setState(() {
      _hasBeenVisible = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onVisible();
      }
    });
  }
}
