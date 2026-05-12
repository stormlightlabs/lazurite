part of '../poptart_client_adapter.dart';

class AtProtoServerService {
  AtProtoServerService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<ServerGetSessionOutput>> getSession({Map<String, String>? $headers, String? $service}) {
    return _client.call(comAtprotoServerGetSession, headers: $headers, service: $service);
  }

  Future<XRPCResponse<ServerGetServiceAuthOutput>> getServiceAuth({
    required String aud,
    int? exp,
    String? lxm,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      comAtprotoServerGetServiceAuth,
      headers: $headers,
      service: $service,
      parameters: ServerGetServiceAuthInput(aud: aud, exp: exp, lxm: lxm),
    );
  }
}
