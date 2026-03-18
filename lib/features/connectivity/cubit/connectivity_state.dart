part of 'connectivity_cubit.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityState extends Equatable {
  const ConnectivityState({required this.isOnline});

  const ConnectivityState.online() : this(isOnline: true);

  const ConnectivityState.offline() : this(isOnline: false);

  final bool isOnline;

  ConnectivityStatus get status => isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;

  @override
  List<Object?> get props => [isOnline];
}
