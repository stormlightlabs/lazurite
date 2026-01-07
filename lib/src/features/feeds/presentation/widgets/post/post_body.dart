import 'package:flutter/material.dart';

class PostBody extends StatelessWidget {
  const PostBody({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
      ),
    );
  }
}
