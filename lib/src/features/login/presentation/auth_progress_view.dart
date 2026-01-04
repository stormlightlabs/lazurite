import 'package:flutter/material.dart';

class AuthProgressView extends StatelessWidget {
  const AuthProgressView({super.key, this.message = 'Signing in...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(message, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
