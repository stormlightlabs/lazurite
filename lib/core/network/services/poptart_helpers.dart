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

  final normalized = _normalizeDescriptorJson(value: parameters, encoder: descriptor.parametersToJson);
  if (normalized == null) {
    return parameters;
  }

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

  final normalized = _normalizeDescriptorJson(value: input, encoder: descriptor.inputToJson);
  if (normalized == null) {
    return input;
  }

  final converter = descriptor.inputFromJson;
  if (converter != null) {
    return converter.call(normalized);
  }
  return normalized.isEmpty ? null : normalized;
}

Map<String, dynamic>? _normalizeDescriptorJson({
  required Object value,
  required Map<String, dynamic> Function(dynamic value)? encoder,
}) {
  if (value is Map) {
    return _normalizeJson(value) as Map<String, dynamic>;
  }
  if (encoder == null) {
    return null;
  }
  return _normalizeJson(encoder.call(value)) as Map<String, dynamic>;
}

dynamic _normalizeJson(dynamic value, {String? key}) {
  if (value == null) return value;
  if (value is String) {
    return _isDateTimeJsonField(key) ? formatAtProtoDateTimeString(value) ?? value : value;
  }
  if (value is num || value is bool) return value;
  if (value is DateTime) return formatAtProtoDateTime(value);
  if (value is AtUri || value is NSID) return value.toString();
  if (value is Blob || value is BlobRef) return value.toJson();
  if (value is List) return value.map((item) => _normalizeJson(item)).toList(growable: false);
  if (value is Map) {
    return value.map((key, val) {
      final stringKey = key.toString();
      return MapEntry(stringKey, _normalizeJson(val, key: stringKey));
    });
  }
  final dynamic dynamicValue = value;
  try {
    return _normalizeJson(dynamicValue.toJson());
  } catch (error, stackTrace) {
    developer.log(
      'Falling back to string serialization for ${value.runtimeType}.',
      name: 'lazurite.network.poptart',
      error: error,
      stackTrace: stackTrace,
      level: 500,
    );
    return value.toString();
  }
}

bool _isDateTimeJsonField(String? key) => key != null && key.endsWith('At');

String _repoDid(PoptartClient client) {
  return client.session?.did ??
      client.oAuthSession?.sub ??
      (throw StateError('Authenticated repo DID is unavailable.'));
}
