import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
import 'package:lazurite/core/theme/animation_utils.dart';

class AnimatedRefreshIndicator extends StatefulWidget {
  const AnimatedRefreshIndicator({super.key, required this.onRefresh, required this.child, this.displacement = 40});

  final RefreshCallback onRefresh;
  final Widget child;
  final double displacement;

  @override
  State<AnimatedRefreshIndicator> createState() => _AnimatedRefreshIndicatorState();
}

class _AnimatedRefreshIndicatorState extends State<AnimatedRefreshIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_refreshing) {
      return;
    }

    setState(() => _refreshing = true);
    unawaited(_rotationController.repeat());

    try {
      await widget.onRefresh();
    } finally {
      _rotationController.stop();
      if (mounted) {
        setState(() => _refreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      RefreshIndicator(onRefresh: _handleRefresh, displacement: widget.displacement, child: widget.child),
      if (animationsAllowed(context))
        Positioned(
          top: 12,
          right: 16,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: Anim.fast,
              opacity: _refreshing ? 1 : 0,
              child: AnimatedScale(
                duration: Anim.refreshComplete,
                scale: _refreshing ? 1 : 0.8,
                curve: Anim.enter,
                child: RotationTransition(
                  turns: _rotationController,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.sync, size: 16)),
                  ),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
