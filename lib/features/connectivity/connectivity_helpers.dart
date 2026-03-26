import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';

bool isOffline(BuildContext context) => context.select<ConnectivityCubit, bool>((cubit) => cubit.state.isOffline);

String offlineActionMessage(String action) => 'You\'re offline. Reconnect to $action.';

void showOfflineSnackBar(BuildContext context, {required String action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(offlineActionMessage(action)), behavior: SnackBarBehavior.floating));
}
