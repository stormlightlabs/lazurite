import 'package:flutter/material.dart';

/// A widget that animates its child into view with a slide and fade effect.
///
/// Useful for staggering animations in a list.
class AnimatedItem extends StatefulWidget {
  const AnimatedItem({
    required this.child,
    required this.index,
    this.initialDelay = const Duration(milliseconds: 50),
    this.staggerDelay = const Duration(milliseconds: 50),
    super.key,
  });

  /// The child widget to animate.
  final Widget child;

  /// The index of the item in the list, used for calculating delay.
  final int index;

  /// The initial delay before any animations start.
  final Duration initialDelay;

  /// The delay between each item's animation start.
  final Duration staggerDelay;

  @override
  State<AnimatedItem> createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<AnimatedItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    _startAnimation();
  }

  void _startAnimation() {
    final delay = widget.initialDelay + (widget.staggerDelay * widget.index);
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

/// A wrapper that adds a scale effect when the child is pressed.
///
/// This widget uses a [Listener] to detect touch events without swallowing them,
/// allowing the child widget (e.g. a Button) to handle taps and show ripples.
class ScaleButton extends StatefulWidget {
  const ScaleButton({
    required this.child,
    this.scaleAmount = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final double scaleAmount;
  final Duration duration;
  final bool enabled;

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration, value: 0.0);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// A wrapper for AnimatedSwitcher that uses consistent fade/scale transitions.
class AnimatedContentSwitcher extends StatelessWidget {
  const AnimatedContentSwitcher({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}

/// A helper to build a list with staggered animations.
///
/// This is a convenience wrapper if you want to simply provide a list of children.
/// For ListView.builder, use AnimatedItem directly in the builder.
class MotionList extends StatelessWidget {
  const MotionList({
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding,
    super.key,
  });

  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      padding: padding,
      child: Column(
        children: List.generate(children.length, (index) {
          return AnimatedItem(index: index, child: children[index]);
        }),
      ),
    );
  }
}
