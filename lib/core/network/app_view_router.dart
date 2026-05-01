import 'package:lazurite/core/network/app_view_provider.dart';
import 'package:lazurite/core/network/xrpc_network_interceptor.dart';

class AppViewRouter {
  AppViewRouter({required this.provider});

  final AppViewProviderDescriptor provider;

  Map<String, String> appBskyProxyHeaders() => {'atproto-proxy': provider.serviceDid};

  Uri publicEndpoint(String xrpcPath, [Map<String, String> queryParameters = const {}]) {
    final normalizedPath = xrpcPath.startsWith('/') ? xrpcPath : '/$xrpcPath';
    return provider.publicBaseUrl.replace(path: normalizedPath, queryParameters: queryParameters);
  }

  Uri entrywayForAuth() => provider.entrywayUrl;

  Future<AppViewHealth> probeProvider({Duration timeout = const Duration(seconds: 5)}) async {
    final checks = <AppViewCapabilityCheck>[
      const AppViewCapabilityCheck(
        endpointId: 'app.bsky.actor.getProfile',
        xrpcPath: '/xrpc/app.bsky.actor.getProfile',
        queryParameters: {'actor': 'bsky.app'},
        critical: false,
      ),
      const AppViewCapabilityCheck(
        endpointId: 'app.bsky.unspecced.getTrends',
        xrpcPath: '/xrpc/app.bsky.unspecced.getTrends',
        queryParameters: {'limit': '1'},
      ),
      const AppViewCapabilityCheck(
        endpointId: 'app.bsky.unspecced.getTrendingTopics',
        xrpcPath: '/xrpc/app.bsky.unspecced.getTrendingTopics',
        queryParameters: {'limit': '1'},
      ),
    ];
    final client = XrpcNetworkInterceptor.wrapGetClient();
    final results = <AppViewCapabilityResult>[];

    for (final check in checks) {
      final uri = publicEndpoint(check.xrpcPath, check.queryParameters);
      try {
        final response = await client(uri).timeout(timeout);
        results.add(
          AppViewCapabilityResult(
            endpointId: check.endpointId,
            statusCode: response.statusCode,
            supported: response.statusCode >= 200 && response.statusCode < 300,
            critical: check.critical,
          ),
        );
      } catch (error) {
        results.add(
          AppViewCapabilityResult(
            endpointId: check.endpointId,
            statusCode: null,
            supported: false,
            critical: check.critical,
            error: '$error',
          ),
        );
      }
    }

    return AppViewHealth(providerKey: provider.key, checkedAt: DateTime.now().toUtc(), checks: results);
  }

  Uri resolveWebLink(String relativeOrAbsolute) {
    final trimmed = relativeOrAbsolute.trim();
    if (trimmed.isEmpty) {
      return provider.webBaseUrl;
    }

    final parsed = Uri.tryParse(trimmed);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }

    return provider.webBaseUrl.resolve(trimmed);
  }

  TrendLinkResolution resolveTrendLink(String relativeOrAbsolute) {
    final externalUri = resolveWebLink(relativeOrAbsolute);
    final inAppRoute = _resolveInAppTrendRoute(externalUri);
    return TrendLinkResolution(inAppRoute: inAppRoute, externalUri: externalUri);
  }

  String? _resolveInAppTrendRoute(Uri externalUri) {
    if (externalUri.host.toLowerCase() != provider.webBaseUrl.host.toLowerCase()) {
      return null;
    }

    final segments = externalUri.pathSegments.where((segment) => segment.isNotEmpty).toList(growable: false);
    if (segments.length >= 4 && segments[0] == 'profile' && segments[2] == 'feed') {
      final actor = segments[1].trim();
      final rkey = segments[3].trim();
      if (actor.isNotEmpty && rkey.isNotEmpty) {
        return '/feed?actor=${Uri.encodeQueryComponent(actor)}&rkey=${Uri.encodeQueryComponent(rkey)}';
      }
    }

    if (segments.length >= 2 && segments[0] == 'topic') {
      final topic = segments[1].trim();
      if (topic.isNotEmpty) {
        return '/topic?topic=${Uri.encodeQueryComponent(topic)}';
      }
      return null;
    }

    return null;
  }
}

class AppViewHealth {
  const AppViewHealth({required this.providerKey, required this.checkedAt, required this.checks});

  final String providerKey;
  final DateTime checkedAt;
  final List<AppViewCapabilityResult> checks;

  int get supportedCount => checks.where((check) => check.supported).length;
  Iterable<AppViewCapabilityResult> get _criticalChecks => checks.where((check) => check.critical);
  int get criticalCount => _criticalChecks.length;
  int get criticalSupportedCount => _criticalChecks.where((check) => check.supported).length;

  bool get isHealthy => criticalCount > 0 && criticalSupportedCount == criticalCount;
  bool get isUnavailable => criticalSupportedCount == 0;

  String summary() {
    final criticalRatio = '$criticalSupportedCount/$criticalCount';
    final totalRatio = '$supportedCount/${checks.length}';
    if (isHealthy) {
      return 'Healthy ($criticalRatio critical, $totalRatio total)';
    }
    if (isUnavailable) {
      return 'Unavailable ($criticalRatio critical, $totalRatio total)';
    }
    return 'Degraded ($criticalRatio critical, $totalRatio total)';
  }
}

class AppViewCapabilityCheck {
  const AppViewCapabilityCheck({
    required this.endpointId,
    required this.xrpcPath,
    required this.queryParameters,
    this.critical = true,
  });

  final String endpointId;
  final String xrpcPath;
  final Map<String, String> queryParameters;
  final bool critical;
}

class AppViewCapabilityResult {
  const AppViewCapabilityResult({
    required this.endpointId,
    required this.statusCode,
    required this.supported,
    required this.critical,
    this.error,
  });

  final String endpointId;
  final int? statusCode;
  final bool supported;
  final bool critical;
  final String? error;
}

class TrendLinkResolution {
  const TrendLinkResolution({required this.inAppRoute, required this.externalUri});

  final String? inAppRoute;
  final Uri externalUri;
}
