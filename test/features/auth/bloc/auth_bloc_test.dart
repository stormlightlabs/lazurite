import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lazurite/features/auth/bloc/auth_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('AuthBloc', () {
    const tokens = AuthTokens(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      did: 'did:plc:abc123',
      handle: 'user.bsky.social',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when initial state is unauthenticated',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      verify: (bloc) {
        expect(bloc.state.status, AuthStatus.unauthenticated);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticating, authenticated] when LoginRequested is added and succeeds',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      setUp: () {
        when(() => mockAuthRepository.loginWithAppPassword(any(), any())).thenAnswer((_) async => tokens);
      },
      act: (bloc) => bloc.add(const LoginRequested(handle: 'user.bsky.social', appPassword: 'password')),
      expect: () => [const AuthState.authenticating(), const AuthState.authenticated(tokens)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticating, authError] when LoginRequested is added and fails',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      setUp: () {
        when(() => mockAuthRepository.loginWithAppPassword(any(), any())).thenThrow(Exception('Login failed'));
      },
      act: (bloc) => bloc.add(const LoginRequested(handle: 'user.bsky.social', appPassword: 'password')),
      expect: () => [
        const AuthState.authenticating(),
        predicate<AuthState>(
          (state) => state.status == AuthStatus.authError && state.errorMessage!.contains('Login failed'),
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticating, authenticated] when OAuthLoginRequested is added and succeeds',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      setUp: () {
        when(() => mockAuthRepository.loginWithOAuth(any())).thenAnswer((_) async => tokens);
      },
      act: (bloc) => bloc.add(const OAuthLoginRequested(handle: 'user.bsky.social')),
      expect: () => [const AuthState.authenticating(), const AuthState.authenticated(tokens)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when LogoutRequested is added',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      seed: () => const AuthState.authenticated(tokens),
      setUp: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when SessionRestored is added',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const SessionRestored(tokens: tokens)),
      expect: () => [const AuthState.authenticated(tokens)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [unauthenticated] when CheckSessionRequested is added and no session exists',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      setUp: () {
        when(() => mockAuthRepository.getStoredSession()).thenAnswer((_) async => null);
      },
      act: (bloc) => bloc.add(const CheckSessionRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [authenticated] when CheckSessionRequested is added and valid session exists',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      setUp: () {
        when(() => mockAuthRepository.getStoredSession()).thenAnswer((_) async => tokens);
      },
      act: (bloc) => bloc.add(const CheckSessionRequested()),
      expect: () => [const AuthState.authenticated(tokens)],
    );
  });
}
