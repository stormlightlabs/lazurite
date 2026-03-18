import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/features/connectivity/cubit/connectivity_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<List<ConnectivityResult>> connectivityStreamController;

  setUp(() {
    mockConnectivity = MockConnectivity();
    connectivityStreamController = StreamController<List<ConnectivityResult>>.broadcast();

    when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
    when(() => mockConnectivity.onConnectivityChanged).thenAnswer((_) => connectivityStreamController.stream);
  });

  tearDown(() {
    connectivityStreamController.close();
  });

  group('ConnectivityCubit', () {
    test('initial state is online before checkConnectivity resolves', () {
      final cubit = ConnectivityCubit(connectivity: mockConnectivity);
      expect(cubit.state.isOnline, isTrue);
      Future<void>.delayed(Duration.zero).then((_) => cubit.close());
    });

    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits online state when connectivity is wifi',
      build: () {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.wifi]);
        return ConnectivityCubit(connectivity: mockConnectivity);
      },
      expect: () => [predicate<ConnectivityState>((state) => state.isOnline)],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits offline state when connectivity changes to none',
      build: () => ConnectivityCubit(connectivity: mockConnectivity),
      act: (cubit) => connectivityStreamController.add([ConnectivityResult.none]),
      expect: () => [
        predicate<ConnectivityState>((state) => state.isOnline),
        predicate<ConnectivityState>((state) => !state.isOnline),
      ],
    );

    blocTest<ConnectivityCubit, ConnectivityState>(
      'emits online state when connectivity changes to mobile',
      build: () {
        when(() => mockConnectivity.checkConnectivity()).thenAnswer((_) async => [ConnectivityResult.none]);
        return ConnectivityCubit(connectivity: mockConnectivity);
      },
      act: (cubit) => connectivityStreamController.add([ConnectivityResult.mobile]),
      expect: () => [
        predicate<ConnectivityState>((state) => !state.isOnline),
        predicate<ConnectivityState>((state) => state.isOnline),
      ],
    );

    test('ConnectivityState.online has isOnline = true', () {
      const state = ConnectivityState.online();
      expect(state.isOnline, isTrue);
      expect(state.status, ConnectivityStatus.online);
    });

    test('ConnectivityState.offline has isOnline = false', () {
      const state = ConnectivityState.offline();
      expect(state.isOnline, isFalse);
      expect(state.status, ConnectivityStatus.offline);
    });
  });
}
