part of '../poptart_client_adapter.dart';

class AtProtoIdentityService {
  AtProtoIdentityService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<IdentityResolveHandleOutput>> resolveHandle({
    required String handle,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      comAtprotoIdentityResolveHandle,
      headers: $headers,
      service: $service,
      parameters: IdentityResolveHandleInput(handle: handle),
    );
  }
}
