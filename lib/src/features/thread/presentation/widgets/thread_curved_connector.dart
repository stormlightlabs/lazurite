import 'package:flutter/material.dart';

/// Style of connector line to render.
enum ConnectorStyle {
  /// Parent to child connection with curve (for posts with children)
  parentToChild,

  /// Straight vertical line (for middle siblings in a chain)
  continuation,

  /// Terminal line ending at post (for last child or childless post)
  terminal,
}

/// A curved connector widget for thread relationships with rust-analyzer style.
///
/// Renders smooth bezier curves connecting posts at different nesting levels,
/// providing visual hierarchy similar to rust-analyzer error displays.
class ThreadCurvedConnector extends StatelessWidget {
  const ThreadCurvedConnector({
    required this.style,
    required this.depth,
    this.width = 2,
    this.color,
    this.height,
    super.key,
  });

  /// Style of connector to render
  final ConnectorStyle style;

  /// Current nesting depth (used for positioning calculations)
  final int depth;

  /// Width of the connector line
  final double width;

  /// Color of the connector line (defaults to theme divider color)
  final Color? color;

  /// Explicit height (if null, uses constraints)
  final double? height;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? Theme.of(context).dividerColor;

    return CustomPaint(
      size: Size(width, height ?? double.infinity),
      painter: _ThreadCurvedConnectorPainter(
        color: lineColor,
        strokeWidth: width,
        style: style,
        depth: depth,
      ),
    );
  }
}

class _ThreadCurvedConnectorPainter extends CustomPainter {
  _ThreadCurvedConnectorPainter({
    required this.color,
    required this.strokeWidth,
    required this.style,
    required this.depth,
  });

  final Color color;
  final double strokeWidth;
  final ConnectorStyle style;
  final int depth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    const curveOffset = 32.0;

    switch (style) {
      case ConnectorStyle.parentToChild:
        final curveStartY = size.height * 0.3;
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, curveStartY), paint);

        final path = Path()
          ..moveTo(centerX, curveStartY)
          ..quadraticBezierTo(centerX, size.height * 0.5, centerX + curveOffset, size.height * 0.7)
          ..lineTo(centerX + curveOffset, size.height);

        canvas.drawPath(path, paint);

      case ConnectorStyle.continuation:
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, size.height), paint);

      case ConnectorStyle.terminal:
        final endY = size.height * 0.3;
        canvas.drawLine(Offset(centerX, 0), Offset(centerX, endY), paint);
        canvas.drawLine(Offset(centerX, endY), Offset(centerX + 20, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ThreadCurvedConnectorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.style != style ||
        oldDelegate.depth != depth;
  }
}
