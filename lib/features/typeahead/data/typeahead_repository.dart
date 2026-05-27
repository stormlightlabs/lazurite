import 'dart:convert';
import 'dart:io' as io;

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
    return _searchBlueskyPublicHttp(query: query, limit: limit);
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
    return _parseTypeaheadResponse(
      response: response,
      uri: uri,
      providerLabel: 'Bluesky',
      invalidActorLogMessage: 'TypeaheadRepository: skipped invalid Bluesky actor payload.',
    );
  }

  Future<List<TypeaheadResult>> _searchCommunity({required String query, required int limit}) async {
    final uri = Uri.https(_communityHost, _communityPath, {'q': query, 'limit': limit.toString()});
    final response = await _httpClient.get(uri, headers: const {'X-Client': 'lazurite'});
    return _parseTypeaheadResponse(
      response: response,
      uri: uri,
      providerLabel: 'Community',
      invalidActorLogMessage: 'TypeaheadRepository: skipped invalid community actor payload.',
    );
  }

  List<TypeaheadResult> _parseTypeaheadResponse({
    required http.Response response,
    required Uri uri,
    required String providerLabel,
    required String invalidActorLogMessage,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw io.HttpException('$providerLabel typeahead request failed: HTTP ${response.statusCode}', uri: uri);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$providerLabel typeahead response was not a JSON object.');
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
        log.w(invalidActorLogMessage, error: error, stackTrace: stackTrace);
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
