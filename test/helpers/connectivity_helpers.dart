import 'package:bloc_test/bloc_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:mocktail/mocktail.dart';

void stubConnectivityCubit(
  ConnectivityCubit cubit, {
  ConnectivityState state = const ConnectivityState.online(),
  Stream<ConnectivityState> stream = const Stream<ConnectivityState>.empty(),
}) {
  when(() => cubit.state).thenReturn(state);
  whenListen(cubit, stream, initialState: state);
}
