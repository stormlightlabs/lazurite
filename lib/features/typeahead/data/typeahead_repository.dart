import 'dart:convert';
import 'dart:io' as io;

import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:http/http.dart' as http;
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/network/app_view_request_context.dart';
import 'package:lazurite/core/network/poptart_client_adapter.dart';
import 'package:lazurite/core/network/unauthorized_recovery_runner.dart';
import 'package:lazurite/core/network/xrpc_client_factory.dart';
import 'package:lazurite/features/auth/data/models/auth_models.dart';
import 'package:lazurite/features/moderation/data/moderation_service.dart';
import 'package:lazurite/features/typeahead/data/typeahead_result.dart';

class TypeaheadRepository {
  TypeaheadRepository({
    Bluesky? bluesky,
    String? provider,
    String Function()? providerResolver,
    String? appViewProvider,
    String Function()? appViewProviderResolver,
    ModerationService? moderationService,
    http.Client? httpClient,
    Future<AuthTokens?> Function()? onUnauthorized,
    Bluesky? Function(AuthTokens tokens)? blueskyClientFactory,
  }) : _provider = provider?.trim().toLowerCase(),
       _providerResolver = providerResolver,
       _moderationService = moderationService,
       _httpClient = httpClient ?? http.Client(),
       _appViewContext = AppViewRequestContext(
         appViewProvider: appViewProvider,
         appViewProviderResolver: appViewProviderResolver,
       ) {
    if (_provider == null && _providerResolver == null) {
      throw ArgumentError('Either a static provider or providerResolver must be supplied.');
    }

    if (_provider != null && !_isSupportedProvider(_provider)) {
      throw ArgumentError.value(provider, 'provider', 'Supported providers are "bluesky" and "community".');
    }

    _authRecovery = bluesky == null
        ? null
        : UnauthorizedRecoveryRunner<Bluesky>(
            initialClient: bluesky,
            onUnauthorized: onUnauthorized,
            clientFactory: blueskyClientFactory ?? createBlueskyClient,
          );
  }

  static const String blueskyProvider = 'bluesky';
  static const String communityProvider = 'community';

  static const String _communityHost = 'typeahead.waow.tech';
  static const String _communityPath = '/xrpc/app.bsky.actor.searchActorsTypeahead';
  static const String _searchActorsTypeaheadEndpoint = 'app.bsky.actor.searchActorsTypeahead';

  late final UnauthorizedRecoveryRunner<Bluesky>? _authRecovery;
  final String? _provider;
  final String Function()? _providerResolver;
  final ModerationService? _moderationService;
  final http.Client _httpClient;
  final AppViewRequestContext _appViewContext;

  Future<List<TypeaheadResult>> search({required String query, int limit = 10}) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final normalizedLimit = limit.clamp(1, 100);
    final provider = _resolveProvider();

    if (provider == blueskyProvider) {
      return _searchBluesky(query: normalizedQuery, limit: normalizedLimit);
    }

    try {
      return await _searchCommunity(query: normalizedQuery, limit: normalizedLimit);
    } catch (error, stackTrace) {
      if (_authRecovery == null) {
        rethrow;
      }

      log.w(
        'TypeaheadRepository: community provider failed; falling back to Bluesky provider.',
        error: error,
        stackTrace: stackTrace,
      );

      return _searchBluesky(query: normalizedQuery, limit: normalizedLimit);
    }
  }

  String _resolveProvider() {
    final resolver = _providerResolver;
    if (resolver == null) {
      return _provider!;
    }

    final resolvedProvider = resolver.call().trim().toLowerCase();
    if (_isSupportedProvider(resolvedProvider)) {
      return resolvedProvider;
    }

    if (resolvedProvider.isNotEmpty) {
      log.w(
        'TypeaheadRepository: unsupported provider "$resolvedProvider" from resolver; falling back to static/default provider.',
      );
    }

    return _provider ?? blueskyProvider;
  }

  Future<List<TypeaheadResult>> _searchBluesky({required String query, required int limit}) async {
    final authRecovery = _authRecovery;
    if (authRecovery == null) {
      return _searchBlueskyPublicHttp(query: query, limit: limit);
    }
    final headers = await _moderationService?.headersForRequest();

    final response = await authRecovery.run(
      (client) => client.actor.searchActorsTypeahead(
        q: query,
        limit: limit,
        $headers: _appViewContext.appBskyHeadersForEndpoint(_searchActorsTypeaheadEndpoint, headers),
      ),
    );

    final results = (response.data.actors as List)
        .whereType<ProfileViewBasic>()
        .map(TypeaheadResult.fromProfileViewBasic)
        .toList(growable: false);
    return _applyModeration(results);
  }

  Future<List<TypeaheadResult>> _searchBlueskyPublicHttp({required String query, required int limit}) async {
    final uri = Uri.https(_appViewContext.publicServiceHost(), '/xrpc/$_searchActorsTypeaheadEndpoint', {
      'q': query,
      'limit': limit.toString(),
    });
    final headers = _appViewContext.appBskyHeadersForEndpoint(_searchActorsTypeaheadEndpoint, {
      'X-Client': 'lazurite',
      ...?await _moderationService?.headersForRequest(),
    });
    final response = await _httpClient.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw io.HttpException('Bluesky typeahead request failed: HTTP ${response.statusCode}', uri: uri);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Bluesky typeahead response was not a JSON object.');
    }

    final actors = decoded['actors'];
    if (actors is! List) {
      return const [];
    }

    final results = <TypeaheadResult>[];
    for (final actor in actors) {
      if (actor is! Map<String, dynamic>) {
        continue;
      }

      try {
        results.add(TypeaheadResult.fromJson(actor));
      } catch (error, stackTrace) {
        log.w('TypeaheadRepository: skipped invalid Bluesky actor payload.', error: error, stackTrace: stackTrace);
      }
    }

    return _applyModeration(results);
  }

  Future<List<TypeaheadResult>> _searchCommunity({required String query, required int limit}) async {
    final uri = Uri.https(_communityHost, _communityPath, {'q': query, 'limit': limit.toString()});
    final response = await _httpClient.get(uri, headers: const {'X-Client': 'lazurite'});

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw io.HttpException('Community typeahead request failed: HTTP ${response.statusCode}', uri: uri);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Community typeahead response was not a JSON object.');
    }

    final actors = decoded['actors'];
    if (actors is! List) {
      return const [];
    }

    final results = <TypeaheadResult>[];
    for (final actor in actors) {
      if (actor is! Map<String, dynamic>) {
        continue;
      }

      try {
        results.add(TypeaheadResult.fromJson(actor));
      } catch (error, stackTrace) {
        log.w('TypeaheadRepository: skipped invalid community actor payload.', error: error, stackTrace: stackTrace);
      }
    }

    return _applyModeration(results);
  }

  List<TypeaheadResult> _applyModeration(List<TypeaheadResult> results) {
    final moderationService = _moderationService;
    if (moderationService == null) {
      return results;
    }

    return results
        .where((result) => !moderationService.shouldFilterProfileBasicInList(result.toProfileViewBasic()))
        .toList(growable: false);
  }

  static bool _isSupportedProvider(String provider) => provider == blueskyProvider || provider == communityProvider;
}
