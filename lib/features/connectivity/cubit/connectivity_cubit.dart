import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'connectivity_state.dart';

class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({Connectivity? connectivity, bool simulateOffline = false})
    : _connectivity = connectivity ?? Connectivity(),
      _simulateOffline = simulateOffline,
      super(ConnectivityState(hasNetworkConnection: true, isSimulatedOffline: simulateOffline)) {
    _init();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _simulateOffline;
  bool _hasNetworkConnection = true;

  void _init() {
    _connectivity.checkConnectivity().then(_handleResults);
    _subscription = _connectivity.onConnectivityChanged.listen(_handleResults);
  }

  void setSimulatedOffline(bool value) {
    if (_simulateOffline == value) {
      return;
    }

    _simulateOffline = value;
    _emitCurrentState();
  }

  void _handleResults(List<ConnectivityResult> results) {
    _hasNetworkConnection = results.any((result) => result != ConnectivityResult.none);
    _emitCurrentState();
  }

  void _emitCurrentState() {
    emit(ConnectivityState(hasNetworkConnection: _hasNetworkConnection, isSimulatedOffline: _simulateOffline));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
