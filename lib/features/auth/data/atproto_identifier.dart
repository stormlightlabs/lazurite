enum AtProtoIdentifierValidationErrorCode { empty, unsupportedDid, invalidDid, invalidHandle }

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
    return trimmed.toLowerCase();
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
    if (normalizedLower.startsWith('did:plc:')) {
      final suffix = identifier.substring('did:plc:'.length).trim();
      if (suffix.isEmpty) {
        return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidDid);
      }
      return null;
    }

    if (normalizedLower.startsWith('did:web:')) {
      final suffix = identifier.substring('did:web:'.length).trim();
      if (suffix.isEmpty) {
        return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidDid);
      }
      return null;
    }

    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.unsupportedDid);
  }

  if (!_atprotoHandlePattern.hasMatch(identifier)) {
    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidHandle);
  }

  return null;
}
