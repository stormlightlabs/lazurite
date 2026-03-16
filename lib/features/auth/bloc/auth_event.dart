part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.handle, required this.appPassword});
  final String handle;
  final String appPassword;

  @override
  List<Object?> get props => [handle, appPassword];
}

class OAuthLoginRequested extends AuthEvent {
  const OAuthLoginRequested({required this.handle});
  final String handle;

  @override
  List<Object?> get props => [handle];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class SessionRestored extends AuthEvent {
  const SessionRestored({required this.tokens});
  final AuthTokens tokens;

  @override
  List<Object?> get props => [tokens];
}

class CheckSessionRequested extends AuthEvent {
  const CheckSessionRequested();
}
