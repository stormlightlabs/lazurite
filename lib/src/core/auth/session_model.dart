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
}
