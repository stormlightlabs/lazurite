import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository, AuthState initialState = const AuthState.unauthenticated()})
    : _authRepository = authRepository,
      super(initialState) {
    on<LoginRequested>(_onLoginRequested);
    on<OAuthLoginRequested>(_onOAuthLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SessionRestored>(_onSessionRestored);
    on<CheckSessionRequested>(_onCheckSessionRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    try {
      final tokens = await _authRepository.loginWithAppPassword(event.handle, event.appPassword);

      if (tokens == null) {
        emit(const AuthState.authError('Login failed.'));
        return;
      }

      emit(AuthState.authenticated(tokens));
    } catch (error) {
      emit(AuthState.authError('Login failed: $error'));
    }
  }

  Future<void> _onOAuthLoginRequested(OAuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    try {
      final tokens = await _authRepository.loginWithOAuth(event.handle);

      if (tokens == null) {
        emit(const AuthState.authError('OAuth login failed.'));
        return;
      }

      emit(AuthState.authenticated(tokens));
    } catch (error) {
      emit(AuthState.authError('OAuth login failed: $error'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (error) {
      emit(AuthState.authError('Logout failed: $error'));
    }
  }

  Future<void> _onSessionRestored(SessionRestored event, Emitter<AuthState> emit) async {
    emit(AuthState.authenticated(event.tokens));
  }

  Future<void> _onCheckSessionRequested(CheckSessionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    try {
      final tokens = await _authRepository.restoreSession();
      if (tokens == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      emit(AuthState.authenticated(tokens));
    } catch (_) {
      emit(const AuthState.unauthenticated());
    }
  }
}
