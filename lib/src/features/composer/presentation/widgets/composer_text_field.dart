import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

/// Multi-line text field for composing posts with character count and rich text styling.
///
/// Automatically styles mentions (@handle), links (URLs), and hashtags (#tag) with
/// distinct colors as the user types.
class ComposerTextField extends StatelessWidget {
  const ComposerTextField({
    required this.controller,
    this.maxLength = 300,
    this.hintText = "What's happening?",
    this.onChanged,
    super.key,
  });

  /// Text editing controller for the field.
  final TextEditingController controller;

  /// Maximum character limit (default 300).
  final int maxLength;

  /// Hint text displayed when empty.
  final String hintText;

  /// Callback fired when text changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExtendedTextField(
            controller: controller,
            maxLines: null,
            minLines: 4,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
              border: InputBorder.none,
              counterText: '',
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: onChanged,
            specialTextSpanBuilder: ComposerTextSpanBuilder(
              mentionColor: colorScheme.primary,
              linkColor: colorScheme.tertiary,
              hashtagColor: colorScheme.secondary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final remaining = maxLength - value.text.length;
                final isOverLimit = remaining < 0;
                final isNearLimit = remaining <= 20 && remaining >= 0;

                return Text(
                  '$remaining',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverLimit
                        ? colorScheme.error
                        : isNearLimit
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom text span builder that styles mentions, links, and hashtags.
class ComposerTextSpanBuilder extends SpecialTextSpanBuilder {
  ComposerTextSpanBuilder({
    required this.mentionColor,
    required this.linkColor,
    required this.hashtagColor,
  });

  final Color mentionColor;
  final Color linkColor;
  final Color hashtagColor;

  @override
  SpecialText? createSpecialText(
    String flag, {
    TextStyle? textStyle,
    SpecialTextGestureTapCallback? onTap,
    int? index,
  }) {
    if (flag.isEmpty) {
      return null;
    }

    if (flag == '@') {
      return MentionText(textStyle: textStyle, color: mentionColor, onTap: onTap);
    }

    if (flag == '#') {
      return HashtagText(textStyle: textStyle, color: hashtagColor, onTap: onTap);
    }

    if (flag == 'http://' || flag == 'https://') {
      return LinkText(textStyle: textStyle, color: linkColor, onTap: onTap);
    }

    return null;
  }
}

/// Styled text span for @mentions.
class MentionText extends SpecialText {
  MentionText({
    required TextStyle? textStyle,
    required this.color,
    SpecialTextGestureTapCallback? onTap,
  }) : super('@', RegExp(r'\s|$').pattern, textStyle, onTap: onTap);

  final Color color;

  @override
  InlineSpan finishText() {
    final text = toString();
    return TextSpan(
      text: text,
      style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// Styled text span for #hashtags.
class HashtagText extends SpecialText {
  HashtagText({
    required TextStyle? textStyle,
    required this.color,
    SpecialTextGestureTapCallback? onTap,
  }) : super('#', RegExp(r'\s|$').pattern, textStyle, onTap: onTap);

  final Color color;

  @override
  InlineSpan finishText() {
    final text = toString();
    return TextSpan(
      text: text,
      style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// Styled text span for URLs.
class LinkText extends SpecialText {
  LinkText({
    required TextStyle? textStyle,
    required this.color,
    SpecialTextGestureTapCallback? onTap,
  }) : super('http', RegExp(r'\s|$').pattern, textStyle, onTap: onTap);

  final Color color;

  @override
  InlineSpan finishText() {
    final text = toString();
    return TextSpan(
      text: text,
      style: textStyle?.copyWith(color: color, decoration: TextDecoration.underline),
    );
  }
}
