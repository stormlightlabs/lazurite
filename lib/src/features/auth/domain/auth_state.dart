import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lazurite/src/core/auth/session_model.dart';

part 'auth_state.freezed.dart';

/// State of the authentication system.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.unknown() = AuthStateUnknown;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.authenticated(Session session) = AuthStateAuthenticated;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.error(Object error, StackTrace? stackTrace) = AuthStateError;

  const AuthState._();
}
