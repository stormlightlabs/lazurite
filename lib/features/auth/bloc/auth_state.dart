part of 'auth_bloc.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, authError }

const _authStateNoValue = Object();

class AuthState extends Equatable {
  const AuthState._({required this.status, this.tokens, this.errorMessage});

  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);

  const AuthState.authenticating() : this._(status: AuthStatus.authenticating);

  const AuthState.authenticated(AuthTokens tokens) : this._(status: AuthStatus.authenticated, tokens: tokens);

  const AuthState.authError(String message) : this._(status: AuthStatus.authError, errorMessage: message);
  final AuthStatus status;
  final AuthTokens? tokens;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.authenticating;
  bool get hasError => status == AuthStatus.authError;

  AuthState copyWith({
    AuthStatus? status,
    Object? tokens = _authStateNoValue,
    Object? errorMessage = _authStateNoValue,
  }) => AuthState._(
    status: status ?? this.status,
    tokens: identical(tokens, _authStateNoValue) ? this.tokens : tokens as AuthTokens?,
    errorMessage: identical(errorMessage, _authStateNoValue) ? this.errorMessage : errorMessage as String?,
  );

  @override
  List<Object?> get props => [status, tokens, errorMessage];
}
