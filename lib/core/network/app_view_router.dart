import 'package:lazurite/core/network/app_view_provider.dart';

class AppViewRouter {
  AppViewRouter({required this.provider});

  final AppViewProviderDescriptor provider;

  Map<String, String> appBskyProxyHeaders() => {'atproto-proxy': provider.serviceDid};

  Uri publicEndpoint(String xrpcPath, [Map<String, String> queryParameters = const {}]) {
    final normalizedPath = xrpcPath.startsWith('/') ? xrpcPath : '/$xrpcPath';
    return provider.publicBaseUrl.replace(path: normalizedPath, queryParameters: queryParameters);
  }

  Uri entrywayForAuth() => provider.entrywayUrl;

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

class TrendLinkResolution {
  const TrendLinkResolution({required this.inAppRoute, required this.externalUri});

  final String? inAppRoute;
  final Uri externalUri;
}
