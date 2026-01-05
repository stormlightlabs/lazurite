import 'package:dio/dio.dart';

import '../../core/identity/did_document.dart';
import '../../core/utils/logger.dart';

class IdentityRepository {
  IdentityRepository({required Dio dio, Logger? logger})
      : _dio = dio,
        _logger = logger ?? const Logger('IdentityRepository');

  final Dio _dio;
  final Logger _logger;

  /// Resolves a handle to a DID.
  ///
  /// Uses multiple resolution methods in order:
  /// 1. Bluesky AppView API (works for all handles including custom domains)
  /// 2. Direct .well-known/atproto-did lookup (for self-hosted)
  /// 3. DNS TXT (not implemented yet)
  Future<String?> resolveHandle(String handle) async {
    // Try AppView resolution first (works for all Bluesky handles)
    final appViewDid = await _resolveViaAppView(handle);
    if (appViewDid != null) {
      return appViewDid;
    }

    // Fallback to direct .well-known lookup
    final wellKnownDid = await _resolveViaWellKnown(handle);
    if (wellKnownDid != null) {
      return wellKnownDid;
    }

    _logger.warning('Failed to resolve handle $handle via all methods');
    return null;
  }

  /// Resolves handle via Bluesky AppView API.
  ///
  /// This works for all Bluesky handles (including custom domains) as long as
  /// the handle is registered with Bluesky.
  Future<String?> _resolveViaAppView(String handle) async {
    const url = '/xrpc/com.atproto.identity.resolveHandle';
    _logger.debug('Resolving handle $handle via AppView API');

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {'handle': handle},
      );

      if (response.statusCode == 200 && response.data != null) {
        final did = response.data!['did'] as String?;
        if (did != null) {
          _logger.info('Successfully resolved handle $handle to $did via AppView');
          return did;
        }
      }
      _logger.debug('AppView resolution failed for $handle: status=${response.statusCode}');
    } on DioException catch (e) {
      _logger.debug('AppView resolution failed for $handle: ${e.message}');
    } catch (e) {
      _logger.debug('AppView resolution error for $handle: $e');
    }
    return null;
  }

  /// Resolves handle via direct .well-known/atproto-did lookup.
  ///
  /// This is used as a fallback for self-hosted PDS instances.
  Future<String?> _resolveViaWellKnown(String handle) async {
    final url = 'https://$handle/.well-known/atproto-did';
    _logger.debug('Resolving handle $handle via .well-known');

    try {
      final response = await _dio.get<dynamic>(url);
      if (response.statusCode == 200 && response.data != null) {
        final did = response.data.toString().trim();
        // Validate it looks like a DID
        if (did.startsWith('did:')) {
          _logger.info('Successfully resolved handle $handle to $did via .well-known');
          return did;
        }
        _logger.warning('Invalid DID format from .well-known for $handle: $did');
      }
    } on DioException catch (e) {
      _logger.debug('.well-known resolution failed for $handle: ${e.message}');
    } catch (e) {
      _logger.debug('.well-known resolution error for $handle: $e');
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
    final url = 'https://plc.directory/$did';
    _logger.debug('Resolving PLC DID $did via $url');

    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      if (response.data != null) {
        final doc = DidDocument.fromJson(response.data!);
        _logger.info('Successfully resolved PLC DID $did');
        return doc;
      }
      _logger.warning('Failed to resolve PLC DID $did: empty response');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      _logger.error('Failed to resolve PLC DID $did: status=$statusCode, error=${e.message}', e);
    } catch (e, st) {
      _logger.error('Unexpected error resolving PLC DID $did', e, st);
    }
    return null;
  }

  Future<DidDocument?> _resolveWeb(String did) async {
    final hostname = did.substring('did:web:'.length);
    final url = 'https://$hostname/.well-known/did.json';
    _logger.debug('Resolving Web DID $did via $url');

    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      if (response.data != null) {
        final doc = DidDocument.fromJson(response.data!);
        _logger.info('Successfully resolved Web DID $did');
        return doc;
      }
      _logger.warning('Failed to resolve Web DID $did: empty response');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      _logger.error('Failed to resolve Web DID $did: status=$statusCode, error=${e.message}', e);
    } catch (e, st) {
      _logger.error('Unexpected error resolving Web DID $did', e, st);
    }
    return null;
  }
}
