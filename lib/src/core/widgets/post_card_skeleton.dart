import 'package:flutter/material.dart';

/// A shimmer loading skeleton widget for post cards.
///
/// Displays animated placeholder boxes that mimic the layout of a post card,
/// providing visual feedback during content loading.
class PostCardSkeleton extends StatefulWidget {
  /// Creates a post card skeleton.
  const PostCardSkeleton({this.lineCount = 3, super.key});

  /// The number of content lines to display in the skeleton.
  ///
  /// Defaults to 3.
  final int lineCount;

  @override
  State<PostCardSkeleton> createState() => _PostCardSkeletonState();
}

class _PostCardSkeletonState extends State<PostCardSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerBase = theme.colorScheme.surfaceContainerHighest;
    final shimmerHighlight = theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withAlpha(51))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBox(
                    width: 40,
                    height: 40,
                    borderRadius: 20,
                    animation: _animation,
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ShimmerBox(
                          width: 120,
                          height: 14,
                          borderRadius: 4,
                          animation: _animation,
                          baseColor: shimmerBase,
                          highlightColor: shimmerHighlight,
                        ),
                        const SizedBox(height: 6),
                        _ShimmerBox(
                          width: 80,
                          height: 12,
                          borderRadius: 4,
                          animation: _animation,
                          baseColor: shimmerBase,
                          highlightColor: shimmerHighlight,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(widget.lineCount, (index) {
                final isLastLine = index == widget.lineCount - 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ShimmerBox(
                    width: isLastLine ? 200 : double.infinity,
                    height: 14,
                    borderRadius: 4,
                    animation: _animation,
                    baseColor: shimmerBase,
                    highlightColor: shimmerHighlight,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// A single shimmer effect box used in skeleton screens.
class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.animation,
    required this.baseColor,
    required this.highlightColor,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Animation<double> animation;
  final Color baseColor;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: [
            (animation.value - 0.3).clamp(0.0, 1.0),
            animation.value.clamp(0.0, 1.0),
            (animation.value + 0.3).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}
