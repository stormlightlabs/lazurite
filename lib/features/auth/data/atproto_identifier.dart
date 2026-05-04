enum AtProtoIdentifierValidationErrorCode { empty, unsupportedDid, invalidHandle }

class AtProtoIdentifierValidationError {
  const AtProtoIdentifierValidationError(this.code);

  final AtProtoIdentifierValidationErrorCode code;
}

final RegExp _atprotoHandlePattern = RegExp(
  r'^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$',
);

String normalizeAtProtoIdentifierForAuth(String identifier) {
  final trimmed = identifier.trim();
  if (trimmed.toLowerCase().startsWith('did:')) {
    return trimmed;
  }

  final withoutAt = trimmed.replaceFirst(RegExp(r'^@+'), '');
  return withoutAt.toLowerCase();
}

AtProtoIdentifierValidationError? validateAtProtoIdentifierForAuth(String identifier) {
  if (identifier.isEmpty) {
    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.empty);
  }

  final normalizedLower = identifier.toLowerCase();
  if (normalizedLower.startsWith('did:')) {
    if (normalizedLower.startsWith('did:plc:') || normalizedLower.startsWith('did:web:')) {
      return null;
    }

    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.unsupportedDid);
  }

  if (!_atprotoHandlePattern.hasMatch(identifier)) {
    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidHandle);
  }

  return null;
}
