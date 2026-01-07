import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lazurite/src/core/auth/session_model.dart';
import 'package:lazurite/src/core/providers/app_lifecycle_provider.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/settings/application/preference_sync_controller.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

/// Mock notifier for auth state
class MockAuthNotifier extends Notifier<AuthState> with Mock implements AuthNotifier {
  MockAuthNotifier(this._state);

  AuthState _state;

  @override
  AuthState build() => _state;

  void setState(AuthState newState) {
    _state = newState;
    state = newState;
  }
}

/// Mock notifier for app lifecycle
class MockAppLifecycle extends Notifier<AppLifecycleState> with Mock implements AppLifecycle {
  MockAppLifecycle(this._state);

  AppLifecycleState _state;

  @override
  AppLifecycleState build() => _state;

  void setState(AppLifecycleState newState) {
    _state = newState;
    state = newState;
  }
}

void main() {
  late MockBlueskyPreferencesRepository mockRepository;

  setUp(() {
    mockRepository = MockBlueskyPreferencesRepository();

    when(() => mockRepository.syncPreferencesFromRemote()).thenAnswer((_) async {});
    when(() => mockRepository.processSyncQueue()).thenAnswer((_) async {});
    when(() => mockRepository.clearAll()).thenAnswer((_) async {});
  });

  group('PreferenceSyncController', () {
    group('initial sync on authenticated state', () {
      test('syncs preferences when user is authenticated', () async {
        final fakeSession = _createFakeSession();
        final authState = AuthStateAuthenticated(fakeSession);

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.resumed)),
          ],
        );
        addTearDown(container.dispose);

        container.read(preferenceSyncControllerProvider);
        await Future<void>.delayed(Duration.zero);

        verify(() => mockRepository.syncPreferencesFromRemote()).called(1);
        verify(() => mockRepository.processSyncQueue()).called(1);
      });

      test('does not sync when user is not authenticated', () async {
        const authState = AuthStateUnauthenticated();

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.resumed)),
          ],
        );
        addTearDown(container.dispose);

        container.read(preferenceSyncControllerProvider);
        await Future<void>.delayed(Duration.zero);

        verifyNever(() => mockRepository.syncPreferencesFromRemote());
        verifyNever(() => mockRepository.processSyncQueue());
      });
    });

    group('error handling', () {
      test('handles sync errors gracefully', () async {
        final fakeSession = _createFakeSession();
        final authState = AuthStateAuthenticated(fakeSession);

        when(
          () => mockRepository.syncPreferencesFromRemote(),
        ).thenThrow(Exception('Network error'));

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.resumed)),
          ],
        );
        addTearDown(container.dispose);

        expect(() => container.read(preferenceSyncControllerProvider), returnsNormally);
        await Future<void>.delayed(Duration.zero);

        verify(() => mockRepository.syncPreferencesFromRemote()).called(1);
      });

      test('handles queue processing errors gracefully', () async {
        final fakeSession = _createFakeSession();
        final authState = AuthStateAuthenticated(fakeSession);

        when(() => mockRepository.processSyncQueue()).thenThrow(Exception('Queue error'));

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.resumed)),
          ],
        );
        addTearDown(container.dispose);

        expect(() => container.read(preferenceSyncControllerProvider), returnsNormally);
        await Future<void>.delayed(Duration.zero);
      });

      test('does not crash when clearAll fails on logout', () async {
        when(() => mockRepository.clearAll()).thenThrow(Exception('Clear failed'));

        const authState = AuthStateUnauthenticated();

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.resumed)),
          ],
        );
        addTearDown(container.dispose);

        expect(() => container.read(preferenceSyncControllerProvider), returnsNormally);
        await Future<void>.delayed(Duration.zero);
      });
    });

    group('lifecycle state', () {
      test('does not sync on initial paused state', () async {
        final fakeSession = _createFakeSession();
        final authState = AuthStateAuthenticated(fakeSession);

        final container = ProviderContainer(
          overrides: [
            blueskyPreferencesRepositoryProvider.overrideWithValue(mockRepository),
            authProvider.overrideWith(() => MockAuthNotifier(authState)),
            appLifecycleProvider.overrideWith(() => MockAppLifecycle(AppLifecycleState.paused)),
          ],
        );
        addTearDown(container.dispose);

        container.read(preferenceSyncControllerProvider);
        await Future<void>.delayed(Duration.zero);
        verify(() => mockRepository.syncPreferencesFromRemote()).called(1);
      });
    });
  });
}

Session _createFakeSession() {
  return Session(
    did: 'did:plc:testuser123',
    handle: 'test.bsky.social',
    accessJwt: 'test-access-jwt',
    refreshJwt: 'test-refresh-jwt',
    pdsUrl: 'https://bsky.social',
    scope: 'atproto transition:generic',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    dpopKey: const <String, dynamic>{},
  );
}
