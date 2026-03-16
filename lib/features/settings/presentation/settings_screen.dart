import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final tokens = state.tokens;
              if (!state.isAuthenticated || tokens == null) {
                return const SizedBox.shrink();
              }

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(tokens.displayName ?? tokens.handle),
                subtitle: Text('@${tokens.handle}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile'),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
