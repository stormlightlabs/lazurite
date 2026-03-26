import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';

class ConnectivityBannerHost extends StatelessWidget {
  const ConnectivityBannerHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(child: child),
            if (state.isOffline)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: IgnorePointer(
                    ignoring: true,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.error),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.onErrorContainer, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.isSimulatedOffline
                                      ? 'You\'re offline (simulated in developer settings).'
                                      : 'You\'re offline.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
