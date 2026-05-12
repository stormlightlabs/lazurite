part of '../poptart_client_adapter.dart';

class BlueskyLabelerService {
  BlueskyLabelerService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<LabelerGetServicesOutput>> getServices({
    required List<String> dids,
    bool detailed = false,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      appBskyLabelerGetServices,
      headers: $headers,
      service: $service,
      parameters: LabelerGetServicesInput(dids: dids, detailed: detailed),
    );
  }
}
