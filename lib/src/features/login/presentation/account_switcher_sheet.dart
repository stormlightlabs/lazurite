import 'package:flutter/material.dart';

class AccountSwitcherSheet extends StatelessWidget {
  const AccountSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Switch Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const Text('Multi-account support coming soon.'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
