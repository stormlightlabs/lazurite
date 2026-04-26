import 'package:flutter/material.dart';

class ActorNameWidget extends StatelessWidget {
  const ActorNameWidget({
    super.key,
    required this.handle,
    this.displayName,
    this.displayNameStyle,
    this.handleStyle,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.uppercaseHandle = true,
    this.showHandle = true,
    this.showDisplayNameOnlyWhenPresent = false,
    this.handlePrefix = '@',
    this.gap = 2,
  });

  final String handle;
  final String? displayName;
  final TextStyle? displayNameStyle;
  final TextStyle? handleStyle;
  final int maxLines;
  final TextOverflow overflow;
  final bool uppercaseHandle;
  final bool showHandle;
  final bool showDisplayNameOnlyWhenPresent;
  final String handlePrefix;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final normalizedDisplayName = displayName?.trim();
    final hasDisplayName = normalizedDisplayName != null && normalizedDisplayName.isNotEmpty;
    final shouldShowDisplayName = hasDisplayName || !showDisplayNameOnlyWhenPresent;
    final displayText = hasDisplayName ? normalizedDisplayName : handle;
    final handleText = '$handlePrefix${uppercaseHandle ? handle.toUpperCase() : handle}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldShowDisplayName) Text(displayText, style: displayNameStyle, maxLines: maxLines, overflow: overflow),
        if (showHandle) ...[
          if (shouldShowDisplayName) SizedBox(height: gap),
          Text(handleText, style: handleStyle, maxLines: maxLines, overflow: overflow),
        ],
      ],
    );
  }
}
