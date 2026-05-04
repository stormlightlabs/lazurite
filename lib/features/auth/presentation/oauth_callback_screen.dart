import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({required this.callbackUri, super.key});

  static const String routePath = '/oauth/callback';

  final Uri callbackUri;

  @override
  State<OAuthCallbackScreen> createState() => _OAuthCallbackScreenState();
}

class _OAuthCallbackScreenState extends State<OAuthCallbackScreen> {
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    unawaited(_consumeCallback());
  }

  Future<void> _consumeCallback() async {
    final handled = await context.read<AuthBloc>().handleOAuthRedirectUri(widget.callbackUri);
    if (!mounted) {
      return;
    }

    if (!handled) {
      _submitted = true;
      context.go('/login');
      return;
    }

    _submitted = true;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final busy = !_submitted;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.4))
              else
                const Icon(Icons.check_circle_outline, size: 30),
              const SizedBox(height: 12),
              Text(
                busy ? 'Finalizing sign in...' : 'Returning to Lazurite...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
