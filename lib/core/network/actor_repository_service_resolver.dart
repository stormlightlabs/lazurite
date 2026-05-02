import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:lazurite/core/network/atproto_host_resolver.dart';

class ActorRepositoryServiceResolution {
  const ActorRepositoryServiceResolution({required this.actor, required this.did, required this.pdsHost});

  final String actor;
  final String did;
  final String pdsHost;
}

const Duration _identityLookupTimeout = Duration(seconds: 10);
const String _defaultResolveHandleHost = 'bsky.social';
const String _fallbackResolveHandleHost = 'public.api.bsky.app';

/// Resolves actor identifiers (DID/handle) to repo DID + PDS service host.
///
/// Topology requirements for non-self repo reads:
/// - Never use viewer-session `resolveIdentity`.
/// - Resolve handles via public `com.atproto.identity.resolveHandle`.
/// - Resolve DID docs directly (`did:plc` -> PLC directory, `did:web` ->
///   `/.well-known/did.json` or explicit path), then extract `#atproto_pds`.
///
/// Keeps a small in-memory cache for repeated lookups during the session.
class ActorRepositoryServiceResolver {
  ActorRepositoryServiceResolver({http.Client? httpClient, String resolveHandleHost = _defaultResolveHandleHost})
    : _httpClient = httpClient ?? http.Client(),
      _resolveHandleHosts = _buildResolveHandleHosts(resolveHandleHost);
  final http.Client _httpClient;
  final List<String> _resolveHandleHosts;
  final Map<String, ActorRepositoryServiceResolution> _cacheByActor = <String, ActorRepositoryServiceResolution>{};
  final Map<String, ActorRepositoryServiceResolution> _cacheByDid = <String, ActorRepositoryServiceResolution>{};
  static const int _maxCacheEntries = 256;

  Future<ActorRepositoryServiceResolution> resolve(String actor) async {
    final normalizedActor = actor.trim().toLowerCase();
    if (normalizedActor.isEmpty) {
      throw ArgumentError.value(actor, 'actor', 'Actor must not be empty.');
    }

    final cachedByActor = _cacheByActor[normalizedActor];
    if (cachedByActor != null) {
      return cachedByActor;
    }

    final cachedByDid = _cacheByDid[normalizedActor];
    if (cachedByDid != null) {
      _cacheByActor[normalizedActor] = cachedByDid;
      return cachedByDid;
    }

    final did = _isDid(normalizedActor) ? normalizedActor : await _resolveHandleToDid(normalizedActor);
    final didKey = did.toLowerCase();
    final cachedDidResolution = _cacheByDid[didKey];
    if (cachedDidResolution != null) {
      _cacheByActor[normalizedActor] = cachedDidResolution;
      return cachedDidResolution;
    }

    final didDoc = await _resolveDidDocument(did);
    final pdsHost = extractAtprotoPdsHostFromDidDoc(didDoc);
    if (pdsHost == null || pdsHost.isEmpty) {
      throw StateError('Unable to resolve actor PDS host: actor=$actor did=$did');
    }

    final resolution = ActorRepositoryServiceResolution(actor: actor, did: did, pdsHost: pdsHost);
    _put(normalizedActor, didKey, resolution);
    return resolution;
  }

  static List<String> _buildResolveHandleHosts(String preferredHost) {
    final seen = <String>{};
    final hosts = <String>[];

    void addHost(String? candidate) {
      final normalized = normalizeAtprotoServiceHost(candidate);
      if (normalized == null || normalized.isEmpty) {
        return;
      }
      if (seen.add(normalized)) {
        hosts.add(normalized);
      }
    }

    addHost(preferredHost);
    addHost(_defaultResolveHandleHost);
    addHost(_fallbackResolveHandleHost);
    return hosts;
  }

  bool _isDid(String value) => value.startsWith('did:');

  Future<String> _resolveHandleToDid(String normalizedHandle) async {
    final handle = normalizedHandle.replaceFirst(RegExp(r'^@+'), '');
    if (handle.isEmpty) {
      throw StateError('Unable to resolve empty handle to DID');
    }

    Object? lastError;
    for (final host in _resolveHandleHosts) {
      final uri = Uri.https(host, '/xrpc/com.atproto.identity.resolveHandle', {'handle': handle});
      try {
        final response = await _httpClient
            .get(uri, headers: const {'Accept': 'application/json', 'User-Agent': 'lazurite'})
            .timeout(_identityLookupTimeout);
        if (response.statusCode != HttpStatus.ok) {
          lastError = StateError(
            'resolveHandle failed for $handle via $host: HTTP ${response.statusCode} ${response.body}',
          );
          continue;
        }

        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          lastError = StateError('resolveHandle returned invalid payload for $handle via $host');
          continue;
        }

        final did = (decoded['did'] as String?)?.trim();
        if (did == null || did.isEmpty || !_isDid(did)) {
          lastError = StateError('resolveHandle payload missing DID for $handle via $host');
          continue;
        }

        return did;
      } catch (error) {
        lastError = error;
      }
    }

    throw StateError('Unable to resolve handle to DID: $handle error=$lastError');
  }

  Future<Map<String, dynamic>> _resolveDidDocument(String did) async {
    final uri = _didDocumentUri(did);
    final response = await _httpClient
        .get(uri, headers: const {'Accept': 'application/json', 'User-Agent': 'lazurite'})
        .timeout(_identityLookupTimeout);
    if (response.statusCode != HttpStatus.ok) {
      throw StateError('Failed to resolve DID document for $did: HTTP ${response.statusCode} (${uri.host})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('Invalid DID document payload for $did');
    }
    return decoded;
  }

  Uri _didDocumentUri(String did) {
    if (did.startsWith('did:plc:')) {
      return Uri.https('plc.directory', '/$did');
    }

    if (did.startsWith('did:web:')) {
      final encodedSegments = did.substring('did:web:'.length).split(':');
      if (encodedSegments.isEmpty || encodedSegments.first.isEmpty) {
        throw StateError('Invalid did:web identifier: $did');
      }

      final host = Uri.decodeComponent(encodedSegments.first);
      final pathSegments = encodedSegments.skip(1).map(Uri.decodeComponent).toList(growable: false);
      final path = pathSegments.isEmpty ? '/.well-known/did.json' : '/${pathSegments.join('/')}/did.json';
      return Uri.https(host, path);
    }

    throw StateError('Unsupported DID method for resolver: $did');
  }

  void _put(String actorKey, String didKey, ActorRepositoryServiceResolution resolution) {
    _cacheByActor[actorKey] = resolution;
    _cacheByDid[didKey] = resolution;

    if (_cacheByActor.length > _maxCacheEntries) {
      _cacheByActor.remove(_cacheByActor.keys.first);
    }
    if (_cacheByDid.length > _maxCacheEntries) {
      _cacheByDid.remove(_cacheByDid.keys.first);
    }
  }
}
