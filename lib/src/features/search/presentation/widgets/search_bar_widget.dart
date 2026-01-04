import 'package:flutter/material.dart';

/// Material 3 search bar widget.
class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({
    this.initialQuery,
    this.hintText = 'Search posts...',
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    super.key,
  });

  /// Initial query to display.
  final String? initialQuery;

  /// Hint text to display when empty.
  final String hintText;

  /// Callback when search is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Callback when text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when clear button is pressed.
  final VoidCallback? onClear;

  /// Whether to autofocus the search field.
  final bool autofocus;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  void _onSubmitted(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      widget.onSubmitted?.call(trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyLarge,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSubmitted,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _onClear,
              color: colorScheme.onSurfaceVariant,
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}
