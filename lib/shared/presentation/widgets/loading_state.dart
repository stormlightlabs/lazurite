import 'package:flutter/material.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message, this.padding = const EdgeInsets.all(24)});

  final String? message;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [const CircularProgressIndicator(), ..._message(message, theme.textTheme, theme.colorScheme)],
        ),
      ),
    );
  }

  List<Widget> _message(String? message, TextTheme textTheme, ColorScheme colorScheme) => (message == null)
      ? []
      : [
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ];
}
