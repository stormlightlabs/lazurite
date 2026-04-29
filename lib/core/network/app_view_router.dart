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
}
