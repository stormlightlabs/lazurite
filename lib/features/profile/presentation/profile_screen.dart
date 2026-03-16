import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final tokens = state.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: tokens == null
          ? const Center(child: Text('No active account'))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tokens.displayName ?? tokens.handle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('@${tokens.handle}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SelectableText(tokens.did, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  Text(
                    'Phase 1 milestone 0 requires the profile route and feature structure. Full profile rendering is scheduled in milestone 2.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
    );
  }
}
