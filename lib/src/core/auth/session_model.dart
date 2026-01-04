import 'package:collection/collection.dart';

class Session {
  const Session({
    required this.did,
    required this.handle,
    required this.pdsUrl,
    required this.accessJwt,
    required this.refreshJwt,
    required this.scope,
    required this.expiresAt,
    required this.dpopKey,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      did: json['did'] as String,
      handle: json['handle'] as String,
      pdsUrl: json['pdsUrl'] as String,
      accessJwt: json['accessJwt'] as String,
      refreshJwt: json['refreshJwt'] as String,
      scope: json['scope'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      dpopKey: json['dpopKey'] as Map<String, dynamic>,
    );
  }

  /// Checks if the session is expired with a 60-second buffer.
  ///
  /// This buffer accounts for network latency and clock skew to ensure tokens don't expire mid-request.
  bool get isExpired => DateTime.now().add(const Duration(seconds: 60)).isAfter(expiresAt);

  final String did;
  final String handle;
  final String pdsUrl;
  final String accessJwt;
  final String refreshJwt;
  final String scope;
  final DateTime expiresAt;
  final Map<String, dynamic> dpopKey;

  Map<String, dynamic> toJson() => {
    'did': did,
    'handle': handle,
    'pdsUrl': pdsUrl,
    'accessJwt': accessJwt,
    'refreshJwt': refreshJwt,
    'scope': scope,
    'expiresAt': expiresAt.toIso8601String(),
    'dpopKey': dpopKey,
  };

  Session copyWith({
    String? did,
    String? handle,
    String? pdsUrl,
    String? accessJwt,
    String? refreshJwt,
    String? scope,
    DateTime? expiresAt,
    Map<String, dynamic>? dpopKey,
  }) {
    return Session(
      did: did ?? this.did,
      handle: handle ?? this.handle,
      pdsUrl: pdsUrl ?? this.pdsUrl,
      accessJwt: accessJwt ?? this.accessJwt,
      refreshJwt: refreshJwt ?? this.refreshJwt,
      scope: scope ?? this.scope,
      expiresAt: expiresAt ?? this.expiresAt,
      dpopKey: dpopKey ?? this.dpopKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          did == other.did &&
          handle == other.handle &&
          pdsUrl == other.pdsUrl &&
          accessJwt == other.accessJwt &&
          refreshJwt == other.refreshJwt &&
          scope == other.scope &&
          expiresAt == other.expiresAt &&
          const DeepCollectionEquality().equals(dpopKey, other.dpopKey);

  @override
  int get hashCode =>
      did.hashCode ^
      handle.hashCode ^
      pdsUrl.hashCode ^
      accessJwt.hashCode ^
      refreshJwt.hashCode ^
      scope.hashCode ^
      expiresAt.hashCode;
}
