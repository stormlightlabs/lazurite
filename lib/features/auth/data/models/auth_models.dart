import 'package:equatable/equatable.dart';

enum AuthMethod { appPassword, oauth }

/// Persisted credentials plus routing metadata for either auth method.
///
/// [service] is the user's PDS. [oauthService] is the OAuth authorization
/// server. They can differ, so network clients must choose carefully.
class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    required this.did,
    required this.handle,
    this.displayName,
    this.service,
    this.oauthService,
    this.oauthClientId,
    this.dpopNonce,
    this.dpopPublicKey,
    this.dpopPrivateKey,
    this.authMethod = AuthMethod.appPassword,
  });
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final String did;
  final String handle;
  final String? displayName;
  final String? service;
  final String? oauthService;
  final String? oauthClientId;
  final String? dpopNonce;
  final String? dpopPublicKey;
  final String? dpopPrivateKey;
  final AuthMethod authMethod;

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? did,
    String? handle,
    String? displayName,
    String? service,
    String? oauthService,
    String? oauthClientId,
    String? dpopNonce,
    String? dpopPublicKey,
    String? dpopPrivateKey,
    AuthMethod? authMethod,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      did: did ?? this.did,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      service: service ?? this.service,
      oauthService: oauthService ?? this.oauthService,
      oauthClientId: oauthClientId ?? this.oauthClientId,
      dpopNonce: dpopNonce ?? this.dpopNonce,
      dpopPublicKey: dpopPublicKey ?? this.dpopPublicKey,
      dpopPrivateKey: dpopPrivateKey ?? this.dpopPrivateKey,
      authMethod: authMethod ?? this.authMethod,
    );
  }

  bool get usesOAuth => authMethod == AuthMethod.oauth;

  /// Treat tokens as expired slightly early so foreground requests do not race
  /// the server-side expiration boundary.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!.subtract(const Duration(minutes: 5)));
  }

  @override
  List<Object?> get props => [
    accessToken,
    refreshToken,
    expiresAt,
    did,
    handle,
    displayName,
    service,
    oauthService,
    oauthClientId,
    dpopNonce,
    dpopPublicKey,
    dpopPrivateKey,
    authMethod,
  ];
}

class User extends Equatable {
  const User({required this.did, required this.handle, this.displayName, this.avatar, this.description});
  final String did;
  final String handle;
  final String? displayName;
  final String? avatar;
  final String? description;

  User copyWith({String? did, String? handle, String? displayName, String? avatar, String? description}) {
    return User(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [did, handle, displayName, avatar, description];
}
