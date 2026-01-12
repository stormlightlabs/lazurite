import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/composer/application/autocomplete_provider.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/autocomplete_overlay.dart';

class ComposerTextField extends ConsumerStatefulWidget {
  const ComposerTextField({
    required this.controller,
    this.maxLength = 300,
    this.hintText = "What's happening?",
    this.onChanged,
    this.showRemainingCounter = true,
    super.key,
  });

  final TextEditingController controller;
  final int maxLength;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final bool showRemainingCounter;

  @override
  ConsumerState<ComposerTextField> createState() => _ComposerTextFieldState();
}

class _ComposerTextFieldState extends ConsumerState<ComposerTextField> {
  OverlayEntry? _overlayEntry;
  bool _showAutocomplete = false;
  String _lastQueriedText = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;

    if (text == _lastQueriedText) {
      return;
    }

    _lastQueriedText = text;
    ref.read(autocompleteProvider.notifier).search(text);

    final shouldShow = _shouldShowAutocomplete(text);
    if (shouldShow != _showAutocomplete) {
      setState(() {
        _showAutocomplete = shouldShow;
      });

      if (shouldShow) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  bool _shouldShowAutocomplete(String text) {
    if (text.isEmpty) return false;

    final lastSpaceIndex = text.lastIndexOf(' ');
    final lastNewlineIndex = text.lastIndexOf('\n');
    final lastSeparatorIndex = [lastSpaceIndex, lastNewlineIndex].reduce((a, b) => a > b ? a : b);

    final segment = lastSeparatorIndex >= 0 ? text.substring(lastSeparatorIndex + 1) : text;

    return segment.startsWith('@') || segment.startsWith('#');
  }

  void _showOverlay() {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => AutocompleteOverlay(
        text: widget.controller.text,
        visible: _showAutocomplete,
        offset: Offset(offset.dx, offset.dy + size.height + 8),
        onSuggestionSelected: _onSuggestionSelected,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onSuggestionSelected(AutocompleteSuggestion suggestion) {
    final text = widget.controller.text;
    final lastSpaceIndex = text.lastIndexOf(' ');
    final lastNewlineIndex = text.lastIndexOf('\n');
    final lastSeparatorIndex = [lastSpaceIndex, lastNewlineIndex].reduce((a, b) => a > b ? a : b);

    final prefix = lastSeparatorIndex >= 0 ? text.substring(0, lastSeparatorIndex + 1) : '';
    final suffix = lastSeparatorIndex >= 0 ? '' : '';

    final newText =
        '$prefix${suggestion.type == AutocompleteType.mention ? '@${suggestion.handle}' : '#${suggestion.label}'} $suffix';

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    _lastQueriedText = newText;
    ref.read(autocompleteProvider.notifier).clear();
    setState(() {
      _showAutocomplete = false;
    });
    _removeOverlay();
  }

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
            controller: widget.controller,
            maxLines: null,
            minLines: 4,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
              border: InputBorder.none,
              counterText: '',
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: widget.onChanged,
            specialTextSpanBuilder: ComposerTextSpanBuilder(
              mentionColor: colorScheme.primary,
              linkColor: colorScheme.tertiary,
              hashtagColor: colorScheme.secondary,
            ),
          ),
          if (widget.showRemainingCounter)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) {
                  final remaining = widget.maxLength - value.text.length;
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
