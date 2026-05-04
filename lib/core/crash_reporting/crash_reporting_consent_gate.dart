import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/crash_reporting/crash_reporting_service.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/settings/bloc/settings_cubit.dart';
import 'package:lazurite/features/settings/bloc/settings_state.dart';

class CrashReportingConsentGate extends StatefulWidget {
  const CrashReportingConsentGate({required this.child, required this.crashReportingService, super.key});

  final Widget child;
  final CrashReportingService crashReportingService;

  @override
  State<CrashReportingConsentGate> createState() => _CrashReportingConsentGateState();
}

class _CrashReportingConsentGateState extends State<CrashReportingConsentGate> {
  bool _dialogShownThisRun = false;
  bool _dialogInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleConsentPromptCheck());
  }

  void _scheduleConsentPromptCheck() {
    if (!mounted || _dialogInFlight || _dialogShownThisRun) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_maybePromptForConsent()));
  }

  bool _shouldPrompt() {
    final authState = context.read<AuthBloc>().state;
    if (!authState.isAuthenticated) {
      return false;
    }
    final settingsState = context.read<SettingsCubit>().state;
    return !settingsState.crashReportingConsentPrompted;
  }

  Future<void> _maybePromptForConsent() async {
    if (!mounted || _dialogInFlight || _dialogShownThisRun || !_shouldPrompt()) {
      return;
    }

    _dialogInFlight = true;
    try {
      final shouldEnable = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Help Improve Stability?'),
              content: const Text(
                'Would you like to enable crash and error reporting? '
                'This helps identify and fix app stability issues.',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Not now')),
                FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Enable')),
              ],
            ),
          );
        },
      );

      final enabled = shouldEnable == true;
      if (!mounted) {
        return;
      }

      final settingsCubit = context.read<SettingsCubit>();
      await settingsCubit.setCrashReportingConsentPrompted(true);
      await settingsCubit.setCrashReportingEnabled(enabled);

      await widget.crashReportingService.setCollectionEnabled(enabled);
      if (enabled) {
        await widget.crashReportingService.sendUnsentReports();
      } else {
        await widget.crashReportingService.deleteUnsentReports();
      }

      _dialogShownThisRun = true;
    } catch (error, stackTrace) {
      log.w('Crash reporting consent prompt failed', error: error, stackTrace: stackTrace);
    } finally {
      _dialogInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) => MultiBlocListener(
    listeners: [
      BlocListener<AuthBloc, AuthState>(listener: (_, _) => _scheduleConsentPromptCheck()),
      BlocListener<SettingsCubit, SettingsState>(listener: (_, _) => _scheduleConsentPromptCheck()),
    ],
    child: widget.child,
  );
}
