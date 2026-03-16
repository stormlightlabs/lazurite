import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/auth/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _handleController = TextEditingController();
  final _appPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showDebugForm = false;

  @override
  void dispose() {
    _handleController.dispose();
    _appPasswordController.dispose();
    super.dispose();
  }

  void _onOAuthLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final handle = _handleController.text.trim();
      context.read<AuthBloc>().add(OAuthLoginRequested(handle: handle));
    }
  }

  void _onAppPasswordLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final handle = _handleController.text.trim();
      final appPassword = _appPasswordController.text.trim();
      context.read<AuthBloc>().add(LoginRequested(handle: handle, appPassword: appPassword));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.hasError && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.cloud, size: 80, color: Colors.blue),
                  const SizedBox(height: 24),
                  Text('Lazurite', style: Theme.of(context).textTheme.headlineLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Sign in to BlueSky', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _handleController,
                    decoration: const InputDecoration(
                      labelText: 'Handle',
                      hintText: 'your-handle.bsky.social',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your handle';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                  ),
                  const SizedBox(height: 24),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return ElevatedButton.icon(
                        onPressed: state.isLoading ? null : _onOAuthLogin,
                        icon: state.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.login),
                        label: Text(state.isLoading ? 'Signing in...' : 'Sign in with BlueSky'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      );
                    },
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showDebugForm = !_showDebugForm;
                        });
                      },
                      child: Text(_showDebugForm ? 'Hide Debug Login' : 'Show Debug Login (App Password)'),
                    ),
                    if (_showDebugForm) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Debug Login (App Password)',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _appPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'App Password',
                          hintText: 'xxxx-xxxx-xxxx-xxxx',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (_showDebugForm && (value == null || value.isEmpty)) {
                            return 'Please enter your app password';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onAppPasswordLogin(),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            onPressed: state.isLoading ? null : _onAppPasswordLogin,
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.bug_report),
                            label: Text(state.isLoading ? 'Signing in...' : 'Debug Sign In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
