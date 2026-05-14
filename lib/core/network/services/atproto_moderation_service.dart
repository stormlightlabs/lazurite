part of '../poptart_client_adapter.dart';

class AtProtoModerationService {
  AtProtoModerationService._(this._client);

  final PoptartClient _client;

  Future<XRPCResponse<ModerationCreateReportOutput>> createReport({
    required ReasonType reasonType,
    String? reason,
    required UModerationCreateReportSubject subject,
    ModTool? modTool,
    Map<String, String>? $headers,
    String? $service,
  }) {
    return _client.call(
      comAtprotoModerationCreateReport,
      headers: $headers,
      service: $service,
      input: ModerationCreateReportInput(reasonType: reasonType, reason: reason, subject: subject, modTool: modTool),
    );
  }
}
