import 'package:flutter/material.dart';

/// Position of a post within a thread chain.
enum ThreadLinePosition {
  /// First post in a chain (ancestor at top)
  top,

  /// Middle post in a chain
  middle,

  /// Last post in a chain (or focal post)
  bottom,

  /// Single post with no connections
  none,
}

/// A visual connector widget for thread relationships.
///
/// Displays vertical lines connecting posts in a thread to show parent-child relationships.
class ThreadLineConnector extends StatelessWidget {
  const ThreadLineConnector({
    required this.position,
    this.width = 2,
    this.color,
    this.leftPadding = 36,
    super.key,
  });

  /// Position of this post in the thread chain
  final ThreadLinePosition position;

  /// Width of the connector line
  final double width;

  /// Color of the connector line (defaults to theme divider color)
  final Color? color;

  /// Left padding to align with avatar center
  final double leftPadding;

  @override
  Widget build(BuildContext context) {
    if (position == ThreadLinePosition.none) {
      return const SizedBox.shrink();
    }

    final lineColor = color ?? Theme.of(context).dividerColor;

    return Positioned(
      left: leftPadding,
      top: position == ThreadLinePosition.top ? 52 : 0,
      bottom: position == ThreadLinePosition.bottom ? null : 0,
      child: CustomPaint(
        size: Size(width, position == ThreadLinePosition.bottom ? 20 : double.infinity),
        painter: _ThreadLinePainter(color: lineColor, strokeWidth: width, position: position),
      ),
    );
  }
}

class _ThreadLinePainter extends CustomPainter {
  _ThreadLinePainter({required this.color, required this.strokeWidth, required this.position});

  final Color color;
  final double strokeWidth;
  final ThreadLinePosition position;

  /// Top: Line from below avatar to bottom of post
  /// Middle: Full vertical line
  /// Bottom: Short line connecting to parent above
  /// None: No painting
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;

    switch (position) {
      case ThreadLinePosition.top:
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
      case ThreadLinePosition.middle:
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
      case ThreadLinePosition.bottom:
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);
      case ThreadLinePosition.none:
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.position != position;
  }
}
