import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/app_route_paths.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';

/// Thin route used by custom-scheme and HTTPS app-link callbacks.
///
/// It must hand the raw callback URI to AuthBloc; the repository validates the
/// state/code against the pending OAuth flow created before browser launch.
class OAuthCallbackScreen extends StatefulWidget {
  const OAuthCallbackScreen({required this.callbackUri, super.key});

  static String get routePath => AppRoutePath.oauthCallback.path;
  static String get compatibilityRoutePath => AppRoutePath.oauthCallbackCompatibility.path;

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

  /// Consume once on route creation. The repository joins duplicate deliveries,
  /// which matters because OAuth codes are single-use.
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
