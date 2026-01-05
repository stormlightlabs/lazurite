import 'package:lazurite/src/core/auth/session_model.dart';

/// State of the authentication system.
sealed class AuthState {
  const AuthState();

  const factory AuthState.unknown() = AuthStateUnknown;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.authenticated(Session session) = AuthStateAuthenticated;
  const factory AuthState.loading() = AuthStateLoading;
  const factory AuthState.error(Object error, StackTrace? stackTrace) = AuthStateError;
}

class AuthStateUnknown extends AuthState {
  const AuthStateUnknown();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateAuthenticated extends AuthState {
  const AuthStateAuthenticated(this.session);
  final Session session;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateAuthenticated &&
          runtimeType == other.runtimeType &&
          session == other.session;

  @override
  int get hashCode => session.hashCode;
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateError extends AuthState {
  const AuthStateError(this.error, this.stackTrace);
  final Object error;
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateError &&
          runtimeType == other.runtimeType &&
          error.toString() == other.error.toString();

  @override
  int get hashCode => error.toString().hashCode;
}
