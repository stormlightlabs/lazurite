import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/auth/data/auth_repository.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthState.unauthenticated()) {
    on<AuthEvent>(_onEvent);
  }
  final AuthRepository _authRepository;

  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    if (event is LoginRequested) {
      await _onLoginRequested(event, emit);
    } else if (event is OAuthLoginRequested) {
      await _onOAuthLoginRequested(event, emit);
    } else if (event is LogoutRequested) {
      await _onLogoutRequested(event, emit);
    } else if (event is SessionRestored) {
      await _onSessionRestored(event, emit);
    } else if (event is CheckSessionRequested) {
      await _onCheckSessionRequested(event, emit);
    }
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    try {
      final tokens = await _authRepository.loginWithAppPassword(event.handle, event.appPassword);
      if (tokens != null) {
        emit(AuthState.authenticated(tokens));
      } else {
        emit(const AuthState.authError('Login failed'));
      }
    } catch (e) {
      emit(const AuthState.authError('Login failed: \$e'));
    }
  }

  Future<void> _onOAuthLoginRequested(OAuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());
    try {
      final tokens = await _authRepository.loginWithOAuth(event.handle);
      if (tokens != null) {
        emit(AuthState.authenticated(tokens));
      } else {
        emit(const AuthState.authError('OAuth login failed'));
      }
    } catch (e) {
      emit(const AuthState.authError('OAuth login failed: \$e'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.authError('Logout failed: \$e'));
    }
  }

  Future<void> _onSessionRestored(SessionRestored event, Emitter<AuthState> emit) async {
    emit(AuthState.authenticated(event.tokens));
  }

  Future<void> _onCheckSessionRequested(CheckSessionRequested event, Emitter<AuthState> emit) async {
    try {
      final tokens = await _authRepository.getStoredSession();
      if (tokens != null) {
        if (tokens.isExpired && tokens.refreshToken != null) {
          final refreshed = await _authRepository.refreshSession(tokens.refreshToken!);
          if (refreshed != null) {
            emit(AuthState.authenticated(refreshed));
          } else {
            emit(const AuthState.unauthenticated());
          }
        } else {
          emit(AuthState.authenticated(tokens));
        }
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(const AuthState.unauthenticated());
    }
  }
}
