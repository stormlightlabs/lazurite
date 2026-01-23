import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

@freezed
abstract class Session with _$Session {
  const factory Session({
    required String did,
    required String handle,
    required String pdsUrl,
    required String accessJwt,
    required String refreshJwt,
    required String scope,
    required DateTime expiresAt,
    required Map<String, dynamic> dpopKey,
  }) = _Session;

  const Session._();

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  /// Checks if the session is expired with a 60-second buffer.
  ///
  /// This buffer accounts for network latency and clock skew to ensure tokens don't expire mid-request.
  bool get isExpired => DateTime.now().add(const Duration(seconds: 60)).isAfter(expiresAt);

  /// Returns true if the access token expires within 5 minutes.
  ///
  /// Used for proactive token refresh to avoid mid-session expirations.
  bool get isNearExpiration => DateTime.now().add(const Duration(minutes: 5)).isAfter(expiresAt);
}
