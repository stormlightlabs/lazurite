part of 'auth_bloc.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, authError }

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

  AuthState copyWith({AuthStatus? status, AuthTokens? tokens, String? errorMessage}) {
    return AuthState._(
      status: status ?? this.status,
      tokens: tokens ?? this.tokens,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, tokens, errorMessage];
}
