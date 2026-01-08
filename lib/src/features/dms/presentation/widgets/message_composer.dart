import 'package:flutter/material.dart';

/// Message input widget for composing and sending messages.
///
/// Features:
/// - Multi-line text input (auto-expanding up to 5 lines)
/// - Send button enabled only when text is non-empty
/// - Character counter visible when approaching limit
class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSend,
    this.maxCharacters = 10000,
    this.characterWarningThreshold = 9500,
  });

  /// Callback when send button is pressed.
  final ValueChanged<String> onSend;

  /// Maximum allowed characters.
  final int maxCharacters;

  /// Threshold at which to show character counter.
  final int characterWarningThreshold;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSend => _controller.text.trim().isNotEmpty;
  bool get _showCharacterCount => _controller.text.length > widget.characterWarningThreshold;
  bool get _isOverLimit => _controller.text.length > widget.maxCharacters;

  void _handleSend() {
    if (!_canSend || _isOverLimit) return;

    final text = _controller.text.trim();
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_showCharacterCount)
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 8),
                child: Text(
                  '${_controller.text.length} / ${widget.maxCharacters}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _isOverLimit
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _canSend && !_isOverLimit ? _handleSend : null,
                  icon: const Icon(Icons.send),
                  tooltip: 'Send message',
                  style: IconButton.styleFrom(
                    backgroundColor: _canSend && !_isOverLimit
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: _canSend && !_isOverLimit
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
