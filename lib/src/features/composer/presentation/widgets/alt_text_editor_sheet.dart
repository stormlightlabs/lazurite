import 'package:flutter/material.dart';

/// Maximum character limit for alt text.
const int kMaxAltTextLength = 1000;

/// Bottom sheet for editing alt text for media attachments.
class AltTextEditorSheet extends StatefulWidget {
  const AltTextEditorSheet({this.initialAltText, this.mediaPath, super.key});

  /// The current alt text, if any.
  final String? initialAltText;

  /// Path to the media file for preview.
  final String? mediaPath;

  @override
  State<AltTextEditorSheet> createState() => _AltTextEditorSheetState();
}

class _AltTextEditorSheetState extends State<AltTextEditorSheet> {
  late TextEditingController _controller;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAltText ?? '');
    _characterCount = _controller.text.length;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = _controller.text.length;
    });
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOverLimit = _characterCount > kMaxAltTextLength;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alt Text', style: theme.textTheme.titleLarge),
                IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Cancel'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Alt text helps describe images for people who use screen readers.',
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: kMaxAltTextLength,
              decoration: InputDecoration(
                hintText: 'Describe this image...',
                border: const OutlineInputBorder(),
                counterText: '$_characterCount / $kMaxAltTextLength',
                counterStyle: TextStyle(
                  color: isOverLimit ? colorScheme.error : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: _cancel, child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton(onPressed: isOverLimit ? null : _save, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
