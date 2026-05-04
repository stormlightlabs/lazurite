import 'package:flutter/foundation.dart';

enum AtProtoIdentifierValidationErrorCode { empty, unsupportedDid, invalidDid, invalidHandle }

class AtProtoIdentifierValidationError {
  const AtProtoIdentifierValidationError(this.code);

  final AtProtoIdentifierValidationErrorCode code;
}

final RegExp _atprotoHandlePattern = RegExp(
  r'^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$',
);
final RegExp _didPlcSuffixPattern = RegExp(r'^[a-z2-7]{24}$');
final RegExp _didWebLocalhostPortPattern = RegExp(r'^localhost%3A[0-9]+$', caseSensitive: false);
final RegExp _didWebHostLabelPattern = RegExp(r'^[A-Za-z0-9-]+$');
const Set<String> _disallowedDidWebTopLevelDomains = {
  'alt',
  'arpa',
  'example',
  'internal',
  'invalid',
  'local',
  'localhost',
  'onion',
};

String normalizeAtProtoIdentifierForAuth(String identifier) {
  final trimmed = identifier.trim();
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('did:plc:')) {
    return 'did:plc:${trimmed.substring('did:plc:'.length).toLowerCase()}';
  }
  if (lower.startsWith('did:web:')) {
    return 'did:web:${trimmed.substring('did:web:'.length).toLowerCase()}';
  }
  if (lower.startsWith('did:')) {
    return 'did:${trimmed.substring('did:'.length)}';
  }

  final withoutAt = trimmed.replaceFirst(RegExp(r'^@+'), '');
  return withoutAt.toLowerCase();
}

AtProtoIdentifierValidationError? validateAtProtoIdentifierForAuth(
  String identifier, {
  bool allowDevelopmentDidWebHosts = !kReleaseMode,
}) {
  if (identifier.isEmpty) {
    return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.empty);
  }

  final normalizedLower = identifier.toLowerCase();
  if (normalizedLower.startsWith('did:')) {
    if (normalizedLower.startsWith('did:plc:')) {
      final suffix = identifier.substring('did:plc:'.length).trim();
      if (!_didPlcSuffixPattern.hasMatch(suffix)) {
        return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidDid);
      }
      return null;
    }

    if (normalizedLower.startsWith('did:web:')) {
      final suffix = identifier.substring('did:web:'.length).trim();
      if (suffix.isEmpty ||
          suffix.contains(RegExp(r'\s')) ||
          suffix.contains(':') ||
          suffix.contains('/') ||
          suffix.contains('?') ||
          suffix.contains('#')) {
        return const AtProtoIdentifierValidationError(AtProtoIdentifierValidationErrorCode.invalidDid);
      }

      if (!_isValidDidWebHostSuffix(suffix, allowDevelopmentDidWebHosts: allowDevelopmentDidWebHosts)) {
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

bool _isValidDidWebHostSuffix(String suffix, {required bool allowDevelopmentDidWebHosts}) {
  if (allowDevelopmentDidWebHosts && _didWebLocalhostPortPattern.hasMatch(suffix)) {
    return true;
  }

  final lower = suffix.toLowerCase();
  if (allowDevelopmentDidWebHosts && lower == 'localhost') {
    return true;
  }

  if (suffix.length > 253 || suffix.startsWith('.') || suffix.endsWith('.') || suffix.contains('..')) {
    return false;
  }

  final labels = suffix.split('.');
  if (labels.length < 2) {
    return false;
  }

  for (final label in labels) {
    if (label.isEmpty ||
        label.length > 63 ||
        !_didWebHostLabelPattern.hasMatch(label) ||
        label.startsWith('-') ||
        label.endsWith('-')) {
      return false;
    }
  }

  final tld = labels.last.toLowerCase();
  if (_disallowedDidWebTopLevelDomains.contains(tld)) {
    return false;
  }

  return true;
}
