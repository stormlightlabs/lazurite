import 'package:flutter/material.dart';

class RecoverableCrashTestScreen extends StatelessWidget {
  const RecoverableCrashTestScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const _RecoverableCrashTestBody(),
    );
  }
}

class _RecoverableCrashTestBody extends StatelessWidget {
  const _RecoverableCrashTestBody();

  @override
  Widget build(BuildContext context) {
    throw StateError('Recoverable crash report screen test');
  }
}
