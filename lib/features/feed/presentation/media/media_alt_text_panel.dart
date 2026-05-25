import 'package:flutter/material.dart';

/// Scrollable panel used for media alt text in full-screen viewers.
///
/// Long alt text should remain readable without covering the whole media route,
/// so the panel grows naturally up to [maxHeightFraction] of the viewport and
/// then scrolls within that bounded area.
class MediaAltTextPanel extends StatefulWidget {
  const MediaAltTextPanel({
    super.key,
    required this.text,
    required this.decoration,
    this.textStyle,
    this.maxHeightFraction = 0.32,
    this.padding = const EdgeInsets.all(12),
  }) : assert(maxHeightFraction > 0 && maxHeightFraction <= 1);

  final String text;
  final Decoration decoration;
  final TextStyle? textStyle;
  final double maxHeightFraction;
  final EdgeInsetsGeometry padding;

  @override
  State<MediaAltTextPanel> createState() => _MediaAltTextPanelState();
}

class _MediaAltTextPanelState extends State<MediaAltTextPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * widget.maxHeightFraction),
    child: Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: widget.decoration,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: widget.padding,
          child: Text(widget.text.trim(), style: widget.textStyle),
        ),
      ),
    ),
  );
}
