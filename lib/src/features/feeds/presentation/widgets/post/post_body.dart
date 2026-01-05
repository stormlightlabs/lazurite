import 'package:flutter/material.dart';

class PostBody extends StatelessWidget {
  const PostBody({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}
