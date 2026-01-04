import 'package:dio/dio.dart';

import '../../core/identity/did_document.dart';

class IdentityRepository {
  IdentityRepository({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Resolves a handle to a DID.
  ///
  /// Tries DNS TXT record first (not implemented in this MVP due to platform limitations,
  /// skipping directly to HTTP .well-known), then falls back to .well-known/atproto-did.
  Future<String?> resolveHandle(String handle) async {
    // 1. DNS TXT (Skip for now, or implement if reliable package found)
    // 2. HTTP .well-known
    try {
      final response = await _dio.get<dynamic>('https://$handle/.well-known/atproto-did');
      if (response.statusCode == 200 && response.data != null) {
        return response.data.toString().trim();
      }
    } catch (_) {
      // Ignore errors and return null
    }
    return null;
  }

  /// Resolves a DID to a DidDocument.
  ///
  /// Supports did:plc and did:web.
  Future<DidDocument?> resolveDidDocument(String did) async {
    if (did.startsWith('did:plc:')) {
      return _resolvePlc(did);
    } else if (did.startsWith('did:web:')) {
      return _resolveWeb(did);
    }
    return null;
  }

  Future<DidDocument?> _resolvePlc(String did) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('https://plc.directory/$did');
      if (response.data != null) {
        return DidDocument.fromJson(response.data!);
      }
    } catch (_) {
      // Ignore
    }
    return null;
  }

  Future<DidDocument?> _resolveWeb(String did) async {
    final hostname = did.substring('did:web:'.length);
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://$hostname/.well-known/did.json',
      );
      if (response.data != null) {
        return DidDocument.fromJson(response.data!);
      }
    } catch (_) {
      // Ignore
    }
    return null;
  }
}
