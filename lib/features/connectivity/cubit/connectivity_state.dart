part of 'connectivity_cubit.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityState extends Equatable {
  const ConnectivityState({required this.hasNetworkConnection, this.isSimulatedOffline = false});

  const ConnectivityState.online({bool isSimulatedOffline = false})
    : this(hasNetworkConnection: true, isSimulatedOffline: isSimulatedOffline);

  const ConnectivityState.offline({bool hasNetworkConnection = false, bool isSimulatedOffline = false})
    : this(hasNetworkConnection: hasNetworkConnection, isSimulatedOffline: isSimulatedOffline);

  final bool hasNetworkConnection;
  final bool isSimulatedOffline;

  bool get isOnline => hasNetworkConnection && !isSimulatedOffline;
  bool get isOffline => !isOnline;

  ConnectivityStatus get status => isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;

  @override
  List<Object?> get props => [hasNetworkConnection, isSimulatedOffline];
}
