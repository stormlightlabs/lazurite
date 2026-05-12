part of '../poptart_client_adapter.dart';

XRPCResponse<Session> _sessionResponse(final XRPCResponse<dynamic> response, final Session session) {
  return XRPCResponse(
    headers: response.headers,
    status: response.status,
    request: response.request,
    rateLimit: response.rateLimit,
    data: session,
  );
}

Session _sessionFromCreateSessionOutput(final ServerCreateSessionOutput output) {
  return Session.fromJson(output.toJson());
}

Session _sessionFromRefreshSessionOutput(final ServerRefreshSessionOutput output) {
  return Session.fromJson(output.toJson());
}

dynamic _coerceDescriptorParameters(XRPCMethodDescriptor<dynamic, dynamic, dynamic> descriptor, Object? parameters) {
  if (parameters == null) {
    return null;
  }
  if (parameters is! Map) {
    return parameters;
  }

  final normalized = _normalizeJson(parameters) as Map<String, dynamic>;
  final converter = descriptor.parametersFromJson;
  if (converter != null) {
    return converter.call(normalized);
  }
  return normalized.isEmpty ? null : normalized;
}

dynamic _coerceDescriptorInput(XRPCMethodDescriptor<dynamic, dynamic, dynamic> descriptor, Object? input) {
  if (input == null) {
    return null;
  }
  if (input is! Map) {
    return input;
  }

  final normalized = _normalizeJson(input) as Map<String, dynamic>;
  final converter = descriptor.inputFromJson;
  if (converter != null) {
    return converter.call(normalized);
  }
  return normalized.isEmpty ? null : normalized;
}

dynamic _normalizeJson(dynamic value) {
  if (value == null || value is String || value is num || value is bool) return value;
  if (value is DateTime) return value.toUtc().toIso8601String();
  if (value is AtUri || value is NSID) return value.toString();
  if (value is Blob || value is BlobRef) return value.toJson();
  if (value is List) return value.map(_normalizeJson).toList(growable: false);
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), _normalizeJson(val)));
  }
  final dynamic dynamicValue = value;
  try {
    return dynamicValue.toJson();
  } catch (_) {
    return value.toString();
  }
}

String _repoDid(PoptartClient client) {
  return client.session?.did ??
      client.oAuthSession?.sub ??
      (throw StateError('Authenticated repo DID is unavailable.'));
}
